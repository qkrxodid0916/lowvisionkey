import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lowvision_key/app/dev_settings.dart';

import '../../data/lesson_results_repository.dart';
import '../../widgets/piano_keyboard.dart';
import 'lesson_result_screen.dart';
import '../curriculum/predefined_courses.dart';
import '../curriculum/curriculum_models.dart';
import '../engine/abstract_lesson_runner.dart';
import '../engine/ble_lesson_runner.dart';
import '../progress/course_progress_repository.dart';
import '../../ble/services/ble_esp32_manager.dart';

enum AccidentalStyle { sharp, flat }

enum _PromptVariant { solfege, letter, staff }

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.stageIndex,
    required this.lessonIndex,
    required this.lesson,
  });

  final String courseId;
  final int stageIndex;
  final int lessonIndex;
  final CurriculumLesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final MidiPro _midi = MidiPro();
  int? _sfId;
  bool _loading = true;

  int _minMidi = 60;
  int _maxMidi = 71;

  final Set<int> _pressedNotes = <int>{};

  late AbstractLessonRunner _runner;

  final LessonResultsRepository _lessonResultsRepo = LessonResultsRepository();
  final CourseProgressRepository _progressRepo = CourseProgressRepository();

  bool _flashWrong = false;
  String? _toastText;
  bool _toastWrong = true;
  bool _hintPulseOn = false;

  int _lessonSerial = 0;
  AccidentalStyle _accidentalStyle = AccidentalStyle.sharp;

  final MidiCommand _usbMidi = MidiCommand();
  StreamSubscription<MidiPacket>? _usbSub;
  MidiDevice? _connectedUsbDevice;

  VoidCallback? _completeListener;
  bool _handlingComplete = false;

  int _stepIndex = 0;

  late final MidiInputBuffer _inputBuffer;
  DateTime _acceptInputAfter = DateTime.fromMillisecondsSinceEpoch(0);

  Course get _course => _resolveCourse(widget.courseId);
  Stage get _stage => _course.stages[widget.stageIndex];
  List<LessonPlanStep> get _steps => widget.lesson.effectiveSteps;
  LessonPlanStep get _currentStep => _steps[_stepIndex];

  bool get _isLearnStep => _currentStep.id.contains('learn');
  bool get _isCheckStep => _currentStep.id.contains('check');

  CurriculumLesson _lessonForRunnerFromStep() {
    return CurriculumLesson(
      id: '${widget.lesson.id}:${_currentStep.id}',
      title: '${widget.lesson.title} · ${_currentStep.title}',
      mode: widget.lesson.mode,
      plan: _currentStep.plan,
      passRule: _currentStep.passRule,
      steps: const <LessonPlanStep>[],
    );
  }

  AbstractLessonRunner _buildRunnerForCurrentStep() {
    final lesson = _lessonForRunnerFromStep();
    return BleLessonRunner(lesson);
  }

  @override
  void initState() {
    super.initState();

    _runner = _buildRunnerForCurrentStep();

    _inputBuffer = MidiInputBuffer(
      onChordReady: (notes) {
        _submitInput(notes);
      },
    );

    _completeListener = () async {
      if (!mounted) return;
      if (_runner.isCompleted.value != true) return;
      if (_handlingComplete) return;

      _handlingComplete = true;
      await _onStepCompleted();
      _handlingComplete = false;
    };
    _runner.isCompleted.addListener(_completeListener!);

    _initUsbMidi();

    _initSoundFont().then((_) {
      if (!mounted) return;
      _startCurrentStep();
    });
  }

  @override
  void dispose() {
    // ESP32 LED 가이드 초기화
    // ignore: discarded_futures
    BleEsp32Manager.I.sendReset();

    _disposeUsbMidi();
    _inputBuffer.dispose();

    if (_completeListener != null) {
      _runner.isCompleted.removeListener(_completeListener!);
    }

    _runner.dispose();
    super.dispose();
  }

  Future<void> _initUsbMidi() async {
    try {
      final devices = await _usbMidi.devices;

      if (devices == null || devices.isEmpty) {
        debugPrint('USB MIDI 장치 없음');
        return;
      }

      debugPrint('MIDI devices: ${devices.map((e) => e.name).toList()}');

      _connectedUsbDevice = devices.first;
      await _usbMidi.connectToDevice(_connectedUsbDevice!);

      await _usbSub?.cancel();
      _usbSub = _usbMidi.onMidiDataReceived?.listen((packet) {
        final data = packet.data;
        if (data == null || data.isEmpty) return;

        final status = data[0] & 0xF0;

        if (status == 0x90 && data.length >= 3) {
          final midi = data[1];
          final velocity = data[2];

          if (velocity == 0) {
            _handleNoteOff(midi);
          } else {
            debugPrint('USB MIDI NoteOn: $midi vel=$velocity');
            _handleNoteOn(midi, velocity: velocity);
          }
        }

        if (status == 0x80 && data.length >= 2) {
          final midi = data[1];
          debugPrint('USB MIDI NoteOff: $midi');
          _handleNoteOff(midi);
        }
      });

      debugPrint('USB MIDI 연결 완료: ${_connectedUsbDevice?.name}');
    } catch (e) {
      debugPrint('USB MIDI 초기화 실패: $e');
    }
  }

  Future<void> _disposeUsbMidi() async {
    await _usbSub?.cancel();
    _usbSub = null;

    try {
      if (_connectedUsbDevice != null) {
        _usbMidi.disconnectDevice(_connectedUsbDevice!);
      }
    } catch (e) {
      debugPrint('USB MIDI 해제 실패: $e');
    }

    _connectedUsbDevice = null;
  }

  void _resetInputGate() {
    _inputBuffer.reset();
    _acceptInputAfter = DateTime.now().add(const Duration(milliseconds: 80));
  }

  void _startCurrentStep() {
    _lessonSerial += 1;
    _accidentalStyle = _styleFromProgress();

    _minMidi = 60;
    _maxMidi = 71;

    _resetInputGate();
    _runner.start();

    // 레슨 시작마다 LED를 강제로 초기화하지 않음.
    // 가이드 전송은 BleLessonRunner의 onGuideNotesChanged가 처리함.

    _toastText = null;
    _flashWrong = false;
    _hintPulseOn = false;

    setState(() {});
  }

  Future<void> _onStepCompleted() async {
    final result = _runner.finish();

    final stepRule = _currentStep.passRule;
    final passed = result.accuracy >= stepRule.minAccuracy &&
        (stepRule.maxFails == null || result.wrong <= stepRule.maxFails!);

    if (!DevSettings.disableResultSaving) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _lessonResultsRepo.saveLessonResult(uid: uid, result: result);
        }
      } catch (e) {
        debugPrint('saveLessonResult failed: $e');
      }

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final isLastStep = _stepIndex == _steps.length - 1;

          await _progressRepo.applyResult(
            uid: uid,
            courseId: widget.courseId,
            lessonIndex: _currentLessonLinearIndex(),
            stepKey: _currentProgressNodeKey(),
            accuracy: result.accuracy,
            passed: passed,
            advanceUnlock: passed && isLastStep,
          );
        }
      } catch (e) {
        debugPrint('applyResult failed: $e');
      }
    }

    if (!mounted) return;

    if (!passed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonResultScreen(
            result: result,
            onRestart: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    courseId: widget.courseId,
                    stageIndex: widget.stageIndex,
                    lessonIndex: widget.lessonIndex,
                    lesson: widget.lesson,
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (_stepIndex + 1 < _steps.length) {
      setState(() {
        _stepIndex += 1;
      });
      _switchRunner(restart: true);
      return;
    }

    Navigator.of(context).pop(true);
  }

  void _switchRunner({required bool restart}) {
    if (_completeListener != null) {
      _runner.isCompleted.removeListener(_completeListener!);
    }

    _runner.dispose();
    _runner = _buildRunnerForCurrentStep();

    if (_completeListener != null) {
      _runner.isCompleted.addListener(_completeListener!);
    }

    _resetInputGate();

    if (restart) {
      _startCurrentStep();
    } else {
      _runner.start();

      // 스텝 전환 때도 LED를 강제로 초기화하지 않음.
      // 가이드 전송은 BleLessonRunner가 처리함.

      setState(() {});
    }
  }

  Future<void> _initSoundFont() async {
    try {
      final int sfId = await _midi.loadSoundfontAsset(
        assetPath: 'assets/sf2/Piano.sf2',
        bank: 0,
        program: 0,
      );

      await _midi.selectInstrument(
        sfId: sfId,
        channel: 0,
        bank: 0,
        program: 0,
      );

      if (!mounted) return;
      setState(() {
        _sfId = sfId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sfId = null;
        _loading = false;
      });
      debugPrint('SoundFont load failed: $e');
    }
  }

  AccidentalStyle _styleFromProgress() {
    return (_lessonSerial >= 6) ? AccidentalStyle.flat : AccidentalStyle.sharp;
  }

  void _play(int midi, {int velocity = 110}) {
    final sfId = _sfId;
    if (sfId == null) return;
    _midi.playNote(sfId: sfId, channel: 0, key: midi, velocity: velocity);
  }

  void _stop(int midi) {
    final sfId = _sfId;
    if (sfId == null) return;
    _midi.stopNote(sfId: sfId, channel: 0, key: midi);
  }

  Future<void> _playWrongBeep() async {
    final sfId = _sfId;
    if (sfId == null) return;

    const int beepMidi = 96;
    _midi.playNote(sfId: sfId, channel: 0, key: beepMidi, velocity: 60);
    await Future.delayed(const Duration(milliseconds: 90));
    _midi.stopNote(sfId: sfId, channel: 0, key: beepMidi);
  }

  Future<void> _showWrongFlash() async {
    if (!mounted) return;
    setState(() => _flashWrong = true);
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() => _flashWrong = false);
  }

  Future<void> _showToast(String text, {bool wrong = true}) async {
    if (!mounted) return;
    setState(() {
      _toastText = text;
      _toastWrong = wrong;
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _toastText = null);
  }

  Future<void> _pulseHint() async {
    if (!mounted) return;
    for (int i = 0; i < 2; i++) {
      setState(() => _hintPulseOn = true);
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      setState(() => _hintPulseOn = false);
      await Future.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
    }
  }

  Future<void> _submitInput(List<int> notes) async {
    if (notes.isEmpty) return;
    if (_runner.isCompleted.value == true) return;

    final expectedBeforeInput = _runner.currentExpected.value;

    debugPrint('SUBMIT INPUT -> $notes');

    _runner.onInput(notes);

    if (_runner.lastHit.value == false) {
      debugPrint('LESSON WRONG -> count=${_runner.wrongCountOnStep.value}');
      debugPrint('EXPECTED -> $expectedBeforeInput');

      // 오답 LED: 항상 전체 빨강 2번 점멸
      // ignore: discarded_futures
      BleEsp32Manager.I.sendWrong();

      // 2번 이상 틀렸을 때만 정답 가이드 표시
      if (_runner.wrongCountOnStep.value >= 2 &&
          expectedBeforeInput != null &&
          expectedBeforeInput.isNotEmpty) {

        debugPrint('SEND TARGET!');

        // ignore: discarded_futures
        BleEsp32Manager.I.sendTarget(expectedBeforeInput);
      }

      _playWrongBeep();
      _showWrongFlash();

      if (_runner.wrongCountOnStep.value >= 2 && _currentStep.guideEnabled) {
        await _pulseHint();
        _showToast('힌트가 나왔어요', wrong: true);
      } else {
        _showToast('틀렸어요! 다시 해볼까요?', wrong: true);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  int _normalizeTouchMidiToExpectedOctave(int playedMidi) {
    final expected = _runner.currentExpected.value;
    if (expected == null || expected.isEmpty) return playedMidi;

    final expectedMidi = expected.first;

    if (playedMidi % 12 == expectedMidi % 12) {
      return expectedMidi;
    }

    return playedMidi;
  }

  bool _isChordQuestion() {
    final expected = _runner.currentExpected.value;
    if (expected == null) return false;
    return expected.length > 1;
  }

  Widget _buildToastOverlay({required bool isTablet}) {
    if (_toastText == null) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _toastWrong ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 4),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Text(
            _toastText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopProgressBar({required bool isTablet}) {
    final current = (_runner.currentIndex + 1).clamp(0, _runner.totalQuestions);
    final total = max(1, _runner.totalQuestions);
    final progress = current / total;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, isTablet ? 18 : 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_stage.title} · ${widget.lesson.title} · ${_currentStep.title}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$current / $total',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: isTablet ? 14 : 10,
              backgroundColor: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptArea({required bool isTablet}) {
    return ValueListenableBuilder<List<int>?>(
      valueListenable: _runner.currentExpected,
      builder: (context, expected, __) {
        final done = _runner.isCompleted.value;
        final midi = (expected == null || expected.isEmpty) ? 60 : expected.first;

        if (done) {
          return Expanded(
            child: Center(
              child: Text(
                '완료!',
                style: TextStyle(
                  fontSize: isTablet ? 72 : 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                ),
              ),
            ),
          );
        }

        return Expanded(
          child: Container(
            width: double.infinity,
            color: _flashWrong ? Colors.red.withOpacity(0.08) : const Color(0xFFF6F8FC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLearnStep
                ? _buildAllPromptView(midi: midi, isTablet: isTablet)
                : _buildSinglePromptView(
              midi: midi,
              isTablet: isTablet,
              variant: _promptVariantForCurrentQuestion(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllPromptView({
    required int midi,
    required bool isTablet,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _solfegeForMidi(midi),
              style: TextStyle(
                fontSize: isTablet ? 76 : 56,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _letterForMidi(midi),
              style: TextStyle(
                fontSize: isTablet ? 30 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 520 : 360,
                    maxHeight: isTablet ? 120 : 95,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: CustomPaint(
                    painter: _SimpleStaffPainter(
                      midiNotes: [midi],
                      currentIndex: 0,
                      done: false,
                      accidentalStyle: _accidentalStyle,
                    ),
                    size: const Size(double.infinity, double.infinity),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSinglePromptView({
    required int midi,
    required bool isTablet,
    required _PromptVariant variant,
  }) {
    switch (variant) {
      case _PromptVariant.solfege:
        return Center(
          child: Text(
            _solfegeForMidi(midi),
            style: TextStyle(
              fontSize: isTablet ? 96 : 70,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        );

      case _PromptVariant.letter:
        return Center(
          child: Text(
            _letterForMidi(midi),
            style: TextStyle(
              fontSize: isTablet ? 96 : 70,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        );

      case _PromptVariant.staff:
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 520 : 360,
              maxHeight: isTablet ? 160 : 120,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: CustomPaint(
              painter: _SimpleStaffPainter(
                midiNotes: [midi],
                currentIndex: 0,
                done: false,
                accidentalStyle: _accidentalStyle,
              ),
              size: const Size(double.infinity, double.infinity),
            ),
          ),
        );
    }
  }

  Widget _buildKeyboardArea({required bool isTablet}) {
    return ValueListenableBuilder<int>(
      valueListenable: _runner.wrongCountOnStep,
      builder: (context, wrongCount, _) {
        final guideOn = _currentStep.guideEnabled;
        final targetSet = guideOn ? _runner.highlightedNotes() : <int>{};

        final showHint = guideOn && wrongCount >= 2;
        final highlighted = showHint ? (_hintPulseOn ? targetSet : <int>{}) : targetSet;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            child: PianoKeyboard(
              minMidi: _minMidi,
              maxMidi: _maxMidi,
              pressedNotes: _pressedNotes,
              highlightedNotes: highlighted,
              onNoteOn: (midi, velocity) async {
                final normalizedMidi = _normalizeTouchMidiToExpectedOctave(midi);
                await _handleNoteOn(normalizedMidi, velocity: velocity);
              },
              onNoteOff: (midi) {
                _handleNoteOff(midi);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonLayout({required bool isTablet}) {
    return Column(
      children: [
        _buildTopProgressBar(isTablet: isTablet),
        _buildPromptArea(isTablet: isTablet),
        _buildKeyboardArea(isTablet: isTablet),
      ],
    );
  }

  Future<void> _handleNoteOn(int midi, {required int velocity}) async {
    debugPrint('입력 MIDI: $midi');

    if (DateTime.now().isBefore(_acceptInputAfter)) {
      return;
    }

    _play(midi, velocity: velocity);
    setState(() => _pressedNotes.add(midi));

    if (_isChordQuestion()) {
      _inputBuffer.addNote(midi);
      return;
    }

    await _submitInput([midi]);
  }

  void _handleNoteOff(int midi) {
    _stop(midi);
    setState(() => _pressedNotes.remove(midi));
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    return Scaffold(
      appBar: null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_sfId == null)
          ? const Center(
        child: Text(
          'SoundFont 로딩 실패\nassets/sf2/Piano.sf2 경로와 pubspec assets 설정을 확인하세요.',
          textAlign: TextAlign.center,
        ),
      )
          : Stack(
        children: [
          _buildLessonLayout(isTablet: isTablet),
          _buildToastOverlay(isTablet: isTablet),
        ],
      ),
    );
  }

  Course _resolveCourse(String courseId) {
    switch (courseId) {
      case 'beginner':
      default:
        return PredefinedCourses.beginner();
    }
  }

  String _currentProgressNodeKey() {
    return '${widget.lesson.id}:${_currentStep.id}';
  }

  int _currentLessonLinearIndex() {
    int index = 0;

    for (int s = 0; s < _course.stages.length; s++) {
      final stage = _course.stages[s];
      for (int l = 0; l < stage.lessons.length; l++) {
        if (s == widget.stageIndex && l == widget.lessonIndex) {
          return index;
        }
        index += 1;
      }
    }

    return index;
  }

  _NextLessonTarget? _findNextLessonTarget() {
    final currentStage = _course.stages[widget.stageIndex];
    final nextLessonIndex = widget.lessonIndex + 1;

    if (nextLessonIndex < currentStage.lessons.length) {
      return _NextLessonTarget(
        stageIndex: widget.stageIndex,
        lessonIndex: nextLessonIndex,
        lesson: currentStage.lessons[nextLessonIndex],
      );
    }

    final nextStageIndex = widget.stageIndex + 1;
    if (nextStageIndex < _course.stages.length &&
        _course.stages[nextStageIndex].lessons.isNotEmpty) {
      return _NextLessonTarget(
        stageIndex: nextStageIndex,
        lessonIndex: 0,
        lesson: _course.stages[nextStageIndex].lessons.first,
      );
    }

    return null;
  }

  _PromptVariant _promptVariantForCurrentQuestion() {
    final seed =
    _currentStep.id.hashCode ^ _runner.currentIndex ^ widget.lesson.id.hashCode;
    final random = Random(seed);
    return _PromptVariant.values[random.nextInt(_PromptVariant.values.length)];
  }

  String _solfegeForMidi(int midi) {
    switch (midi % 12) {
      case 0:
        return '도';
      case 2:
        return '레';
      case 4:
        return '미';
      case 5:
        return '파';
      case 7:
        return '솔';
      case 9:
        return '라';
      case 11:
        return '시';
      default:
        return '?';
    }
  }

  String _letterForMidi(int midi) {
    switch (midi % 12) {
      case 0:
        return 'C';
      case 2:
        return 'D';
      case 4:
        return 'E';
      case 5:
        return 'F';
      case 7:
        return 'G';
      case 9:
        return 'A';
      case 11:
        return 'B';
      default:
        return '?';
    }
  }
}

class _NextLessonTarget {
  final int stageIndex;
  final int lessonIndex;
  final CurriculumLesson lesson;

  const _NextLessonTarget({
    required this.stageIndex,
    required this.lessonIndex,
    required this.lesson,
  });
}

class MidiInputBuffer {
  MidiInputBuffer({
    required this.onChordReady,
    this.chordWindow = const Duration(milliseconds: 100),
  });

  final void Function(List<int> notes) onChordReady;
  final Duration chordWindow;

  final Set<int> _pendingNotes = <int>{};
  Timer? _flushTimer;

  void addNote(int midi) {
    _pendingNotes.add(midi);

    _flushTimer?.cancel();
    _flushTimer = Timer(chordWindow, _flush);
  }

  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_pendingNotes.isEmpty) return;

    final played = _pendingNotes.toList()..sort();
    _pendingNotes.clear();

    onChordReady(played);
  }

  void reset() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingNotes.clear();
  }

  void dispose() {
    reset();
  }
}

class _SimpleStaffPainter extends CustomPainter {
  final List<int> midiNotes;
  final int currentIndex;
  final bool done;
  final AccidentalStyle accidentalStyle;

  _SimpleStaffPainter({
    required this.midiNotes,
    required this.currentIndex,
    required this.done,
    required this.accidentalStyle,
  });

  bool _isNaturalPc(int pc) => const {0, 2, 4, 5, 7, 9, 11}.contains(pc);
  bool _needsAccidental(int pc) => !_isNaturalPc(pc);

  int _naturalPcForDisplay(int pc) {
    const naturals = <int>[0, 2, 4, 5, 7, 9, 11];
    if (naturals.contains(pc)) return pc;

    if (accidentalStyle == AccidentalStyle.sharp) {
      final down = (pc - 1) % 12;
      if (naturals.contains(down)) return down;
    } else {
      final up = (pc + 1) % 12;
      if (naturals.contains(up)) return up;
    }

    int best = naturals.first;
    int bestDist = 99;
    for (final n in naturals) {
      final d = (pc - n).abs();
      if (d < bestDist) {
        bestDist = d;
        best = n;
      }
    }
    return best;
  }

  int _naturalPcToDiatonic(int pc) {
    switch (pc) {
      case 0:
        return 0;
      case 2:
        return 1;
      case 4:
        return 2;
      case 5:
        return 3;
      case 7:
        return 4;
      case 9:
        return 5;
      case 11:
        return 6;
      default:
        return 0;
    }
  }

  int _midiToDiatonicStepDisplay(int midi) {
    final octave = (midi ~/ 12) - 1;
    final pc = midi % 12;

    final naturalPc = _naturalPcForDisplay(pc);
    final diat = _naturalPcToDiatonic(naturalPc);

    const baseOct = 4;
    const baseDiat = 0;
    return (octave - baseOct) * 7 + (diat - baseDiat);
  }

  bool _useBassClef() {
    if (midiNotes.isEmpty) return false;
    final avg = midiNotes.reduce((a, b) => a + b) / midiNotes.length;
    return avg < 60;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final staffPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final notePaint = Paint()..color = Colors.black;
    final currentPaint = Paint()..color = Colors.blue;

    final staffHeight = size.height * 0.55;
    final staffTop = (size.height - staffHeight) / 2;
    final lineGap = staffHeight / 4;

    final staffLeft = 20.0;
    final staffRight = size.width - 16.0;

    final useBassClef = _useBassClef();

    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * lineGap;
      canvas.drawLine(
        Offset(staffLeft, y),
        Offset(staffRight, y),
        staffPaint,
      );
    }

    final clefPainter = TextPainter(
      text: TextSpan(
        text: useBassClef ? '𝄢' : '𝄞',
        style: TextStyle(
          fontSize: useBassClef ? 38 : 44,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final clefX = useBassClef ? staffLeft - 2 : staffLeft;
    final clefY = useBassClef ? staffTop - 10 : staffTop - 18;
    clefPainter.paint(canvas, Offset(clefX, clefY));

    final n = midiNotes.isEmpty ? 1 : midiNotes.length.clamp(1, 64);

    final left = staffLeft + 68.0;
    final right = staffRight;
    final dx = (right - left) / (n + 0.6);

    final halfStepY = lineGap / 2;
    final bottomLineY = staffTop + 4 * lineGap;
    final topLineY = staffTop;

    final baseStep = useBassClef
        ? _midiToDiatonicStepDisplay(43)
        : _midiToDiatonicStepDisplay(64);

    double yForMidi(int midi) {
      final s = _midiToDiatonicStepDisplay(midi);
      final diff = s - baseStep;
      return bottomLineY - diff * halfStepY;
    }

    final accText = (accidentalStyle == AccidentalStyle.sharp) ? '♯' : '♭';
    final accTP = TextPainter(
      text: TextSpan(
        text: accText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    for (int i = 0; i < n; i++) {
      final midi = midiNotes[i];
      final x = left + dx * (i + 0.8);
      final y = yForMidi(midi);

      final isCurrent = !done && i == currentIndex;
      final isCompleted = done ? true : (i < currentIndex);

      final r = isCurrent ? 10.0 : 8.0;
      final noteWidth = r * 2.8;

      final pc = midi % 12;
      if (_needsAccidental(pc)) {
        accTP.paint(canvas, Offset(x - (r * 2.2) - 8, y - 12));
      }

      if (y > bottomLineY + halfStepY) {
        for (double ledgerY = bottomLineY + lineGap;
        ledgerY <= y + 0.1;
        ledgerY += lineGap) {
          canvas.drawLine(
            Offset(x - noteWidth / 2, ledgerY),
            Offset(x + noteWidth / 2, ledgerY),
            staffPaint,
          );
        }
      }

      if (y < topLineY - halfStepY) {
        for (double ledgerY = topLineY - lineGap;
        ledgerY >= y - 0.1;
        ledgerY -= lineGap) {
          canvas.drawLine(
            Offset(x - noteWidth / 2, ledgerY),
            Offset(x + noteWidth / 2, ledgerY),
            staffPaint,
          );
        }
      }

      if (!isCompleted && !isCurrent) {
        final outline = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withOpacity(0.35);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: r * 2,
            height: r * 1.6,
          ),
          outline,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: r * 2,
            height: r * 1.6,
          ),
          isCurrent ? currentPaint : notePaint,
        );
      }

      if (isCurrent) {
        final arrowPaint = Paint()..color = Colors.blue;
        final ay = staffTop - 2;
        final path = Path()
          ..moveTo(x, ay)
          ..lineTo(x - 10, ay - 18)
          ..lineTo(x + 10, ay - 18)
          ..close();
        canvas.drawPath(path, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleStaffPainter oldDelegate) {
    return oldDelegate.midiNotes != midiNotes ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.done != done ||
        oldDelegate.accidentalStyle != accidentalStyle;
  }
}