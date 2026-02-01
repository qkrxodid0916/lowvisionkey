import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

import '../widgets/piano_keyboard.dart';
import '../utils/solfege.dart';

import '../lesson/lesson_generator.dart';
import '../lesson/lesson_models.dart';
import '../lesson/lesson_runner.dart';
import '../lesson/progress_models.dart';

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

  // ✅ 레슨 notePool 기준으로 화면 범위를 매번 갱신 (1옥타브 흰건반 7개가 기본)
  int _minMidi = 60;
  int _maxMidi = 71;

  final Set<int> _pressedNotes = <int>{};

  final ProgressState _progress = ProgressState();
  final LessonGenerator _generator = LessonGenerator();
  late final LessonRunner _runner;

  // 오답 피드백(화면 플래시 + 토스트)
  bool _flashWrong = false;
  String? _toastText;
  bool _toastWrong = true;

  // 힌트 깜빡임(2회 이상 오답 시)
  bool _hintPulseOn = false;

  // ✅ “진행도 기반” 흑건반 표기 정책 (초반 # 위주 → 진행되면 ♭ 도입)
  int _lessonSerial = 0;
  AccidentalStyle _accidentalStyle = AccidentalStyle.sharp;

  @override
  void initState() {
    super.initState();
    _runner = LessonRunner(progress: _progress);
    _initSoundFont().then((_) {
      if (!mounted) return;
      _startNewLesson();
    });
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

  /// ✅ 진행도 기반 정책:
  /// - 1~N회차: sharp 기반 (#)
  /// - 그 이후: flat 기반 (♭)
  ///
  /// 나중에 ProgressState/Generator에서 “조성”이나 “표기정책”을 직접 내려주면
  /// 이 함수만 그 값으로 교체하면 됨.
  AccidentalStyle _styleFromProgress() {
    // 예: 6번째 레슨부터 ♭ 도입
    // (너 취향에 맞게 숫자만 바꾸면 됨)
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

    // ✅ notePool로 화면 범위 자동 설정(1옥타브)
    final pool = lesson.notePool;
    _minMidi = pool.reduce((a, b) => a < b ? a : b);
    _maxMidi = pool.reduce((a, b) => a > b ? a : b);

    _runner.start(lesson);

    // UI 상태 리셋
    _toastText = null;
    _flashWrong = false;
    _hintPulseOn = false;

    setState(() {});
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

  /// ✅ 2회 이상 오답 시, 정답 건반을 "깜빡이게" 해서 힌트
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

  /// 현재 태스크의 steps를 가져온다 (ORDERED / RANDOM)
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

  /// ✅ 토스트(팝업 느낌) 오버레이
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

  /// ✅ 상단: 안내 문구 + 악보(오선/음표/현재 화살표)
  /// - 이전/처음으로 같은 버튼 없음
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
              Text(
                "아래 음을 연주해보세요 ▼",
                style: TextStyle(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.w900,
                  color: _flashWrong ? Colors.white : Colors.black,
                ),
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
                      accidentalStyle: _accidentalStyle, // ✅ 진행도 기반 #/♭ 전환
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

  Widget _buildKeyboardArea({required bool isTablet}) {
    return ValueListenableBuilder(
      valueListenable: _runner.wrongCountOnStep,
      builder: (context, wrongCount, _) {
        final step = _runner.currentStep.value;
        final targetSet = (step == null) ? <int>{} : _runner.highlightedNotes();

        final bool showHint = wrongCount >= 2;

        final highlighted = showHint ? (_hintPulseOn ? targetSet : <int>{}) : targetSet;

        return Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                child: PianoKeyboard(
                  minMidi: _minMidi,
                  maxMidi: _maxMidi,
                  pressedNotes: _pressedNotes,
                  highlightedNotes: highlighted,
                  onNoteOn: (midi, velocity) async {
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
                  },
                  onNoteOff: (midi) {
                    _stop(midi);
                    setState(() => _pressedNotes.remove(midi));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ✅ 가로/세로 공통: 상단 악보 + 피아노(화면 대부분)
  Widget _buildLessonLayout({required bool isTablet}) {
    return Column(
      children: [
        _buildSheetCard(isTablet: isTablet),
        Expanded(child: _buildKeyboardArea(isTablet: isTablet)),
      ],
    );
  }

  @override
  void dispose() {
    _runner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    return Scaffold(
      appBar: null, // ✅ AppBar 제거
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
/// - 위치(y)는 “자연음” 기준
/// - 흑건반은 ♯ 또는 ♭를 음표 왼쪽에 표시
/// - ♭일 때는 “바로 위 자연음(예: Bb는 B가 아니라 A 위치 + ♭)”에 붙여 표기
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
      // 아래 자연음으로: C#(1)->C(0)
      final down = (pc - 1) % 12;
      if (naturals.contains(down)) return down;
    } else {
      // 위 자연음으로: Db(1)->D(2) (표기상 D에 ♭가 붙는 느낌)
      final up = (pc + 1) % 12;
      if (naturals.contains(up)) return up;
    }

    // 안전장치(가장 가까운 자연음)
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

    // 오선 중앙 배치
    final staffHeight = size.height * 0.55;
    final staffTop = (size.height - staffHeight) / 2;
    final lineGap = staffHeight / 4;
    final staffLeft = 12.0;
    final staffRight = size.width - 12.0;

    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * lineGap;
      canvas.drawLine(Offset(staffLeft, y), Offset(staffRight, y), staffPaint);
    }

    // 클레프
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

      // 흑건반이면 ♯/♭ 기호 표시
      final pc = midi % 12;
      if (_needsAccidental(pc)) {
        accTP.paint(canvas, Offset(x - (r * 2.2) - 8, y - 12));
      }

      // 음표 본체
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

      // 현재 위치 화살표(▼)
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