import 'lesson_models.dart';
import 'progress_models.dart';

class LessonGenerator {
  /// C 기준 한 옥타브 흰건반(도레미파솔라시)
  List<int> _whiteScaleForOctave(int baseC) {
    return [
      baseC,       // 도
      baseC + 2,   // 레
      baseC + 4,   // 미
      baseC + 5,   // 파
      baseC + 7,   // 솔
      baseC + 9,   // 라
      baseC + 11,  // 시
    ];
  }

  Lesson generate({
    required ProgressState progress,
    required LessonSettings settings,
  }) {
    final int octave = progress.octaveIndex;
    final int baseC = 60 + (12 * octave);    // C4 기준 이동
    final List<int> scale = _whiteScaleForOctave(baseC);

    return Lesson(
      lessonId: 'L-${DateTime.now().millisecondsSinceEpoch}',
      level: 0,
      settings: settings,
      notePool: scale,
      newNotes: scale,
      tasks: [
        _buildOrderedTask(scale), // 1️⃣ 순서대로 한 번씩
        _buildRandomTask(scale),  // 2️⃣ 랜덤
      ],
    );
  }

  /// 1️⃣ 도→레→미→… 순서대로 입력
  Task _buildOrderedTask(List<int> scale) {
    return Task(
      taskId: "ORDERED",
      phase: Phase.warmup,
      type: TaskType.followSequence,
      rules: const {"order": "fixed"},
      steps: List.generate(scale.length, (i) {
        return StepItem(
          stepId: "O-${i + 1}",
          targetNotes: [scale[i]],
          hint: Hint(
            ledMode: LedMode.hold,
            audioPrompt: null,
          ),
          judge: JudgeSpec(
            mode: JudgeMode.press,
            attempts: 3,
          ),
        );
      }),
    );
  }

  /// 2️⃣ 랜덤 입력(한 바퀴)
  Task _buildRandomTask(List<int> scale) {
    final shuffled = List<int>.from(scale)..shuffle();

    return Task(
      taskId: "RANDOM",
      phase: Phase.practice,
      type: TaskType.findPress,
      rules: const {"order": "random"},
      steps: List.generate(shuffled.length, (i) {
        return StepItem(
          stepId: "R-${i + 1}",
          targetNotes: [shuffled[i]],
          hint: Hint(
            ledMode: LedMode.hold,
            audioPrompt: null,
          ),
          judge: JudgeSpec(
            mode: JudgeMode.press,
            attempts: 3,
          ),
        );
      }),
    );
  }
}