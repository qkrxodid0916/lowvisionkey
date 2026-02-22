import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

// ✅ 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/lesson_results_repository.dart';

import '../widgets/piano_keyboard.dart';
import '../utils/solfege.dart';

import '../lesson/lesson_generator.dart';
import '../lesson/lesson_models.dart';
import '../lesson/lesson_runner.dart';
import '../lesson/progress_models.dart';
import '../lesson/lesson_result.dart';

import '../utils/ble_midi_manager.dart';
import 'lesson_result_screen.dart';

/// 흑건반 표기 정책
enum AccidentalStyle { sharp, flat }

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

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

  final ProgressState _progress = ProgressState();
  final LessonGenerator _generator = LessonGenerator();
  late final LessonRunner _runner;

  // ✅ 추가: Firestore 저장용 repo
  final LessonResultsRepository _lessonResultsRepo = LessonResultsRepository();

  // 오답 피드백(화면 플래시 + 토스트)
  bool _flashWrong = false;
  String? _toastText;
  bool _toastWrong = true;

  // 힌트 깜빡임(2회 이상 오답 시)
  bool _hintPulseOn = false;

  // 흑건반 ( #  →  ♭ )
  int _lessonSerial = 0;
  AccidentalStyle _accidentalStyle = AccidentalStyle.sharp;

  // ===== BLE 입력 모드(옵션) =====
  bool _useBleInput = false;
  bool _openedModeSheetOnce = false;
  bool _prevConnected = false;

  StreamSubscription<int>? _bleOnSub;
  StreamSubscription<int>? _bleOffSub;

  // ===== 결과 화면 이동/결과 생성 =====
  VoidCallback? _completeListener;
  bool _navigatingToResult = false;
  DateTime? _lessonStartedAt;

  @override
  void initState() {
    super.initState();

    _runner = LessonRunner(progress: _progress);

    // ✅ 레슨 완료 감지 → 결과 화면 이동 (+ Firestore 저장)
    _completeListener = () async {
      if (!mounted) return;
      if (_runner.isCompleted.value != true) return;
      if (_navigatingToResult) return;

      _navigatingToResult = true;

      final result = _buildLessonResult();

      // ✅ 여기서 세션 결과를 Firestore에 저장
      // - 저장 실패해도 결과 화면은 보여주는 게 UX가 좋음
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _lessonResultsRepo.saveLessonResult(uid: uid, result: result);
        }
      } catch (e) {
        debugPrint("saveLessonResult failed: $e");
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonResultScreen(
            result: result,
            onRestart: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LessonScreen()),
              );
            },
          ),
        ),
      );
    };
    _runner.isCompleted.addListener(_completeListener!);

    // ✅ LessonScreen은 BLE 타입 몰라도 됨: bool로만 감지
    _prevConnected = BleMidiManager.I.isConnected;
    BleMidiManager.I.connectionState.addListener(_onBleConnChanged);

    _initSoundFont().then((_) {
      if (!mounted) return;
      _startNewLesson();
    });
  }

  @override
  void dispose() {
    _detachBleInput();
    BleMidiManager.I.connectionState.removeListener(_onBleConnChanged);

    if (_completeListener != null) {
      _runner.isCompleted.removeListener(_completeListener!);
    }

    _runner.dispose();
    super.dispose();
  }

  // ===== BLE 연결 변화 처리 (bool 기반) =====
  void _onBleConnChanged() {
    final isConnected = BleMidiManager.I.isConnected;
    final wasConnected = _prevConnected;

    _prevConnected = isConnected;

    // disconnected -> connected 순간: 입력 모드 선택 메뉴 오픈
    if (!wasConnected && isConnected) {
      if (_openedModeSheetOnce) return; // 세션당 1회만(원하면 삭제)
      _openedModeSheetOnce = true;

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _showInputModeSheet();
      });
    }

    // connected -> disconnected 순간: BLE 입력 모드였다면 자동 복귀
    if (wasConnected && !isConnected && _useBleInput) {
      setState(() => _useBleInput = false);
      _detachBleInput();
      _showToast("연결이 끊겨 터치 입력으로 전환됐어요", wrong: true);
    }
  }

  void _showInputModeSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        bool temp = _useBleInput;

        return StatefulBuilder(
          builder: (context, setSheet) {
            final connected = BleMidiManager.I.isConnected;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "입력 모드 선택",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(connected ? "기기가 연결됐어요. 어떤 방식으로 연습할까요?" : "연결 상태가 아니에요."),
                  const SizedBox(height: 12),
                  RadioListTile<bool>(
                    title: const Text("터치(화면 피아노)"),
                    value: false,
                    groupValue: temp,
                    onChanged: (v) => setSheet(() => temp = v!),
                  ),
                  RadioListTile<bool>(
                    title: const Text("BLE(실제 피아노)"),
                    subtitle: Text(connected ? "연결됨" : "연결 필요"),
                    value: true,
                    groupValue: temp,
                    onChanged: connected ? (v) => setSheet(() => temp = v!) : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyInputMode(temp);
                      },
                      child: const Text("확인"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applyInputMode(bool useBle) {
    final connected = BleMidiManager.I.isConnected;

    if (useBle && !connected) {
      _showToast("BLE가 연결되지 않았어요. 터치 모드로 진행할게요.", wrong: true);
      setState(() => _useBleInput = false);
      _detachBleInput();
      return;
    }

    setState(() => _useBleInput = useBle);

    if (useBle) {
      _attachBleInput();
      _showToast("BLE 입력 모드로 전환!", wrong: false);
    } else {
      _detachBleInput();
      _showToast("터치 입력 모드로 전환!", wrong: false);
    }
  }

  void _attachBleInput() {
    _detachBleInput();

    try {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      BleMidiManager.I.startListening();

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _bleOnSub = BleMidiManager.I.noteOnStream.listen((midi) async {
        await _handleNoteOn(midi, velocity: 110);
      });

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _bleOffSub = BleMidiManager.I.noteOffStream.listen((midi) {
        _handleNoteOff(midi);
      });
    } catch (_) {
      // 수신 기능이 아직 없거나 구현 중이면:
      // BLE 모드 선택은 가능하지만 입력은 들어오지 않음
    }
  }

  void _detachBleInput() {
    _bleOnSub?.cancel();
    _bleOnSub = null;
    _bleOffSub?.cancel();
    _bleOffSub = null;

    try {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      BleMidiManager.I.stopListening();
    } catch (_) {}
  }

  Future<void> _initSoundFont() async {
    try {
      final int sfId = await _midi.loadSoundfontAsset(
        assetPath: 'assets/sf2/Piano.sf2',
        bank: 0,
        program: 0,
      );

      await _midi.selectInstrument(sfId: sfId, channel: 0, bank: 0, program: 0);

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

  void _startNewLesson() {
    // ✅ 레슨 시작 횟수 = 진행도(간단 버전)
    _lessonSerial += 1;
    _accidentalStyle = _styleFromProgress();

    final lesson = _generator.generate(
      progress: _progress,
      settings: const LessonSettings(
        newNotesMax: 1,
        lengthMultiplier: 1.0,
        enableRhythm: false, // ✅ 지금은 순서+랜덤만
      ),
    );

    // ✅ 화면 키보드 범위는 항상 1옥타브로 고정
    final baseC = 60 + (12 * _progress.octaveIndex); // C4 기준 + 옥타브 이동
    _minMidi = baseC; // C
    _maxMidi = baseC + 11; // B

    _runner.start(lesson);

    // ✅ 결과용 시작 시각 + 이동 플래그 리셋
    _lessonStartedAt = DateTime.now();
    _navigatingToResult = false;

    // UI 상태 리셋
    _toastText = null;
    _flashWrong = false;
    _hintPulseOn = false;

    setState(() {});
  }

  LessonResult _buildLessonResult() {
    final started = _lessonStartedAt ?? DateTime.now();
    final finished = DateTime.now();

    int correct = 0;
    int wrong = 0;
    final wrongByMidi = <int, int>{};

    _progress.stats.forEach((midi, ns) {
      correct += ns.success;
      wrong += ns.fail;
      if (ns.fail > 0) wrongByMidi[midi] = ns.fail;
    });

    final total = correct + wrong;
    final acc = total == 0 ? 0.0 : (correct / total);

    return LessonResult(
      startedAt: started,
      finishedAt: finished,
      total: total,
      correct: correct,
      wrong: wrong,
      accuracy: acc,
      newNotes: List<int>.from(_progress.lastNewNotes),
      wrongByMidi: wrongByMidi,
    );
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

    const int beepMidi = 96; // C7 근처
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
    setState(() {
      _toastText = null;
    });
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

  List<StepItem> _currentTaskSteps() {
    final lesson = _runner.lesson;
    final taskId = _runner.currentTaskId;
    if (lesson == null || taskId == null) return const <StepItem>[];

    final task = lesson.tasks.firstWhere(
          (t) => t.taskId == taskId,
      orElse: () => lesson.tasks.first,
    );
    return task.steps;
  }

  int _currentStepIndexInTask() {
    final step = _runner.currentStep.value;
    if (step == null) return -1;

    final steps = _currentTaskSteps();
    final idx = steps.indexWhere((s) => s.stepId == step.stepId);
    return idx;
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
              BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x33000000)),
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

  Widget _buildSheetCard({required bool isTablet}) {
    return ValueListenableBuilder(
      valueListenable: _runner.currentStep,
      builder: (context, step, _) {
        final steps = _currentTaskSteps();
        if (steps.isEmpty) return const SizedBox.shrink();

        final idxRaw = _currentStepIndexInTask();
        final done = (step == null);
        final idx = done ? (steps.length - 1) : idxRaw.clamp(0, steps.length - 1);

        final notes = steps.map((s) => s.targetNotes.first).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          color: _flashWrong ? Colors.red : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "아래 음을 연주해보세요 ▼",
                      style: TextStyle(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w900,
                        color: _flashWrong ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // ✅ 연결돼 있을 때만 “현재 입력 모드” 버튼 노출
                  ValueListenableBuilder(
                    valueListenable: BleMidiManager.I.connectionState,
                    builder: (context, _, __) {
                      final connected = BleMidiManager.I.isConnected;
                      if (!connected) return const SizedBox.shrink();
                      return TextButton(
                        onPressed: _showInputModeSheet,
                        child: Text(_useBleInput ? "BLE 입력" : "터치 입력"),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _flashWrong ? Colors.white : Colors.blue,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: isTablet ? 120 : 100,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SimpleStaffPainter(
                      midiNotes: notes,
                      currentIndex: idx,
                      done: done,
                      accidentalStyle: _accidentalStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleNoteOn(int midi, {required int velocity}) async {
    _play(midi, velocity: velocity);
    setState(() => _pressedNotes.add(midi));

    _runner.onNoteOn(midi);

    if (_runner.lastHit.value == false) {
      _playWrongBeep();
      _showWrongFlash();

      if (_runner.wrongCountOnStep.value >= 2) {
        await _pulseHint();
        _showToast("힌트가 나왔어요", wrong: true);
      } else {
        _showToast("틀렸어요! 다시 해볼까요?", wrong: true);
      }
    }

    setState(() {});
  }

  void _handleNoteOff(int midi) {
    _stop(midi);
    setState(() => _pressedNotes.remove(midi));
  }

  Widget _buildKeyboardArea({required bool isTablet}) {
    return ValueListenableBuilder(
      valueListenable: _runner.wrongCountOnStep,
      builder: (context, wrongCount, _) {
        final step = _runner.currentStep.value;
        final targetSet = (step == null) ? <int>{} : _runner.highlightedNotes();

        final bool showHint = wrongCount >= 2;
        final highlighted = showHint ? (_hintPulseOn ? targetSet : <int>{}) : targetSet;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            child: IgnorePointer(
              ignoring: _useBleInput, // ✅ BLE 모드면 터치 입력 잠금
              child: PianoKeyboard(
                minMidi: _minMidi,
                maxMidi: _maxMidi,
                pressedNotes: _pressedNotes,
                highlightedNotes: highlighted,
                onNoteOn: (midi, velocity) async {
                  await _handleNoteOn(midi, velocity: velocity);
                },
                onNoteOff: (midi) {
                  _handleNoteOff(midi);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonLayout({required bool isTablet}) {
    return Column(
      children: [
        _buildSheetCard(isTablet: isTablet),
        Expanded(child: _buildKeyboardArea(isTablet: isTablet)),
      ],
    );
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
          : OrientationBuilder(
        builder: (context, orientation) {
          final content = _buildLessonLayout(isTablet: isTablet);
          return Stack(
            children: [
              content,
              _buildToastOverlay(isTablet: isTablet),
            ],
          );
        },
      ),
    );
  }
}

/// ✅ 악보(오선+음표+현재 화살표) 렌더링
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
        return 0; // C
      case 2:
        return 1; // D
      case 4:
        return 2; // E
      case 5:
        return 3; // F
      case 7:
        return 4; // G
      case 9:
        return 5; // A
      case 11:
        return 6; // B
      default:
        return 0;
    }
  }

  int _midiToDiatonicStepDisplay(int midi) {
    final octave = (midi ~/ 12) - 1;
    final pc = midi % 12;

    final naturalPc = _naturalPcForDisplay(pc);
    final diat = _naturalPcToDiatonic(naturalPc);

    const baseOct = 4; // C4
    const baseDiat = 0; // C
    return (octave - baseOct) * 7 + (diat - baseDiat);
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
    final staffLeft = 12.0;
    final staffRight = size.width - 12.0;

    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * lineGap;
      canvas.drawLine(Offset(staffLeft, y), Offset(staffRight, y), staffPaint);
    }

    final clefPainter = TextPainter(
      text: const TextSpan(
        text: "𝄞",
        style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    clefPainter.paint(canvas, Offset(staffLeft, staffTop - 18));

    final n = midiNotes.isEmpty ? 1 : midiNotes.length.clamp(1, 64);
    final left = staffLeft + 52.0;
    final right = staffRight;
    final dx = (right - left) / (n + 0.6);

    final halfStepY = lineGap / 2;

    // 5선(높은음자리표) 맨 아래 줄 = E4
    final e4Step = _midiToDiatonicStepDisplay(64);
    final bottomLineY = staffTop + 4 * lineGap;

    double yForMidi(int midi) {
      final s = _midiToDiatonicStepDisplay(midi);
      final diff = s - e4Step;
      return bottomLineY - diff * halfStepY;
    }

    final accText = (accidentalStyle == AccidentalStyle.sharp) ? "♯" : "♭";
    final accTP = TextPainter(
      text: TextSpan(
        text: accText,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    for (int i = 0; i < n; i++) {
      final midi = midiNotes[i];
      final x = left + dx * (i + 0.8);
      final y = yForMidi(midi);

      final isCurrent = (!done && i == currentIndex);
      final isCompleted = done ? true : (i < currentIndex);

      final r = isCurrent ? 10.0 : 8.0;

      final pc = midi % 12;
      if (_needsAccidental(pc)) {
        accTP.paint(canvas, Offset(x - (r * 2.2) - 8, y - 12));
      }

      if (!isCompleted && !isCurrent) {
        final outline = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withOpacity(0.35);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 1.6),
          outline,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 1.6),
          isCurrent ? currentPaint : notePaint,
        );
      }

      if (isCurrent) {
        final arrowPaint = Paint()..color = Colors.blue;
        final ay = staffTop - 8;
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
