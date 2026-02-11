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
    final int baseC = 60 + (12 * octave); // C4 기준 이동
    final List<int> scale = _whiteScaleForOctave(baseC);

    // ✅ learned / newCandidates 분리
    final learned = <int>[];
    final newCandidates = <int>[];

    for (final midi in scale) {
      final s = progress.stats[midi];
      final hasAny = s != null && (s.success + s.fail) > 0;
      if (hasAny) {
        learned.add(midi);
      } else {
        newCandidates.add(midi);
      }
    }

    // ✅ 이번 레슨 새 음 선정
    final int maxNew = settings.newNotesMax.clamp(0, scale.length);
    final newNotes = <int>[];

    if (maxNew > 0 && newCandidates.isNotEmpty) {
      final shuffled = List<int>.from(newCandidates)..shuffle();
      newNotes.addAll(shuffled.take(maxNew));
    }

    // ✅ notePool 구성: learned + newNotes (최소 1개 보장)
    final pool = <int>{
      ...learned,
      ...newNotes,
    }.toList()
      ..sort();

    if (pool.isEmpty) {
      // 완전 초기(기록도 없고 newNotesMax=0 같은 예외) 방어
      pool.add(scale.first);
      newNotes
        ..clear()
        ..add(scale.first);
    }

    // ✅ 태스크 길이(설정 반영)
    final double mult = settings.lengthMultiplier;
    final int mixLen = (12 * mult).round().clamp(8, 24);
    final int focusLen = (10 * mult).round().clamp(6, 20);

    final tasks = <Task>[];

    // 0) 새 음 소개(있을 때만)
    if (newNotes.isNotEmpty) {
      tasks.add(_buildNewIntroTask(newNotes));
    }

    // 1) 섞기(기본)
    tasks.add(_buildReviewMixTask(pool, count: mixLen));

    // 2) 오답 집중(기본)
    tasks.add(_buildErrorFocusTask(pool, progress, count: focusLen));

    // 3) 초반 재미/정렬 감각(선택)
    // learned가 거의 없고(초반) pool이 작을 때만 ORDERED 한 바퀴
    if (pool.length <= 4) {
      tasks.insert(0, _buildOrderedTask(pool));
    } else {
      tasks.add(_buildRandomTask(pool));
    }

    return Lesson(
      lessonId: 'L-${DateTime.now().millisecondsSinceEpoch}',
      level: 0,
      settings: settings,
      notePool: pool,
      newNotes: newNotes,
      tasks: tasks,
    );
  }

  /// NEW_INTRO: 새 음만 짧게 소개(반복 2회씩)
  Task _buildNewIntroTask(List<int> newNotes) {
    final steps = <StepItem>[];
    int k = 0;

    for (final midi in newNotes) {
      for (int rep = 0; rep < 1; rep++) {
        k++;
        steps.add(
          StepItem(
            stepId: "N-$k",
            targetNotes: [midi],
            hint: Hint(
              ledMode: LedMode.hold,
              audioPrompt: null,
            ),
            judge: JudgeSpec(
              mode: JudgeMode.press,
              attempts: 3,
            ),
          ),
        );
      }
    }

    return Task(
      taskId: "NEW_INTRO",
      phase: Phase.warmup,
      type: TaskType.findPress,
      rules: const {"intro": "new_notes"},
      steps: steps,
    );
  }

  /// ORDERED: 순서대로 한 번씩
  Task _buildOrderedTask(List<int> pool) {
    return Task(
      taskId: "ORDERED",
      phase: Phase.warmup,
      type: TaskType.followSequence,
      rules: const {"order": "fixed"},
      steps: List.generate(pool.length, (i) {
        return StepItem(
          stepId: "O-${i + 1}",
          targetNotes: [pool[i]],
          hint: Hint(ledMode: LedMode.hold, audioPrompt: null),
          judge: JudgeSpec(mode: JudgeMode.press, attempts: 3),
        );
      }),
    );
  }

  /// RANDOM: 풀에서 랜덤(한 바퀴)
  Task _buildRandomTask(List<int> pool) {
    final shuffled = List<int>.from(pool)..shuffle();
    return Task(
      taskId: "RANDOM",
      phase: Phase.practice,
      type: TaskType.findPress,
      rules: const {"order": "random"},
      steps: List.generate(shuffled.length, (i) {
        return StepItem(
          stepId: "R-${i + 1}",
          targetNotes: [shuffled[i]],
          hint: Hint(ledMode: LedMode.hold, audioPrompt: null),
          judge: JudgeSpec(mode: JudgeMode.press, attempts: 3),
        );
      }),
    );
  }

  /// REVIEW_MIX: 풀에서 섞어 뽑기(연속 중복 방지)
  Task _buildReviewMixTask(List<int> pool, {required int count}) {
    final steps = <StepItem>[];
    int last = -999;

    for (int i = 0; i < count; i++) {
      final shuffled = List<int>.from(pool)..shuffle();
      int pick = shuffled.first;

      if (pick == last && pool.length > 1) {
        pick = shuffled.firstWhere((n) => n != last, orElse: () => pick);
      }

      last = pick;

      steps.add(
        StepItem(
          stepId: "M-${i + 1}",
          targetNotes: [pick],
          hint: Hint(ledMode: LedMode.hold, audioPrompt: null),
          judge: JudgeSpec(mode: JudgeMode.press, attempts: 3),
        ),
      );
    }

    return Task(
      taskId: "REVIEW_MIX",
      phase: Phase.practice,
      type: TaskType.findPress,
      rules: const {"mix": "review"},
      steps: steps,
    );
  }

  /// ERROR_FOCUS: fail 많은 음을 더 자주(가중치)
  Task _buildErrorFocusTask(
      List<int> pool,
      ProgressState progress, {
        required int count,
      }) {
    final weights = <int, int>{};
    for (final midi in pool) {
      final s = progress.stats[midi];
      final fail = s?.fail ?? 0;
      weights[midi] = fail + 1; // 최소 1
    }

    int last = -999;
    final steps = <StepItem>[];

    for (int i = 0; i < count; i++) {
      int pick = _weightedPick(pool, weights);

      if (pick == last && pool.length > 1) {
        final again = _weightedPick(pool, weights);
        if (again != last) pick = again;
      }

      last = pick;

      steps.add(
        StepItem(
          stepId: "E-${i + 1}",
          targetNotes: [pick],
          hint: Hint(ledMode: LedMode.hold, audioPrompt: null),
          judge: JudgeSpec(mode: JudgeMode.press, attempts: 3),
        ),
      );
    }

    return Task(
      taskId: "ERROR_FOCUS",
      phase: Phase.practice,
      type: TaskType.findPress,
      rules: const {"mix": "error_focus"},
      steps: steps,
    );
  }

  int _weightedPick(List<int> pool, Map<int, int> weights) {
    int total = 0;
    for (final m in pool) {
      total += (weights[m] ?? 1);
    }
    if (total <= 0) return pool.first;

    final r = DateTime.now().microsecondsSinceEpoch % total;
    int acc = 0;
    for (final m in pool) {
      acc += (weights[m] ?? 1);
      if (r < acc) return m;
    }
    return pool.last;
  }
}
