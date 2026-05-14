import '../curriculum_models.dart';

class BeginnerWeek11 {
  static Stage stage() {
    return Stage(
      id: 'week_11',
      title: '11주차 높은 옥타브 반음 학습',
      description: '높은 옥타브의 검은 건반(hi C#~hi A#)을 집중적으로 익혀요.',
      lessons: [
        _day1(),
        _day2(),
        _day3(),
        _day4(),
        _day5(),
        _day6(),
        _day7(),
      ],
    );
  }

  // ── Day 1 : hi C# hi D# 집중 ────────────────────────────────────────────
  static CurriculumLesson _day1() {
    return CurriculumLesson(
      id: 'week11_day1',
      title: 'Day1 hi C# hi D#',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: 'hi C#과 hi D# 검은 건반을 LED 가이드를 보며 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day1Learn,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: 'hi C#, hi D# 검은 건반과 주변 흰 건반을 함께 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day1Practice,
            totalQuestions: 16,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: 'hi C#, hi D# 검은 건반 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day1Practice,
            totalQuestions: 13,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 2 : hi F# hi G# hi A# 집중 ─────────────────────────────────────
  static CurriculumLesson _day2() {
    return CurriculumLesson(
      id: 'week11_day2',
      title: 'Day2 hi F# hi G# hi A#',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: 'hi C#, hi D# 검은 건반을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day1Learn,
            totalQuestions: 8,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: 'hi F#, hi G#, hi A# 검은 건반을 LED 가이드를 보며 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day2Learn,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: 'hi F#, hi G#, hi A# 검은 건반과 주변 흰 건반을 함께 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day2Practice,
            totalQuestions: 16,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: 'hi F#, hi G#, hi A# 검은 건반 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day2Practice,
            totalQuestions: 13,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 3 : 검은 건반 5개 전체 ──────────────────────────────────────────
  static CurriculumLesson _day3() {
    return CurriculumLesson(
      id: 'week11_day3',
      title: 'Day3 고음 검은 건반 전체',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '높은 옥타브 검은 건반 5개를 순서대로 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allBlackKeys,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: 'hi C#부터 hi A#까지 검은 건반 5개를 전체적으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day3Learn,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '높은 옥타브 검은 건반 5개를 랜덤으로 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day3Learn,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '높은 옥타브 검은 건반 5개 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day3Learn,
            totalQuestions: 14,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 4 : 흰 건반 + 반음 혼합 ─────────────────────────────────────────
  static CurriculumLesson _day4() {
    return CurriculumLesson(
      id: 'week11_day4',
      title: 'Day4 고음 흰+검은 혼합',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '높은 옥타브 검은 건반 5개를 랜덤으로 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day3Learn,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_learn',
          title: '학습',
          description: '높은 옥타브 흰 건반과 검은 건반을 섞어서 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4Mixed,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_practice',
          title: '연습',
          description: '높은 옥타브 흰+검은 건반 혼합을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4Mixed,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.74),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_check',
          title: '확인',
          description: '높은 옥타브 흰+검은 건반 혼합 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4Mixed,
            totalQuestions: 14,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.74),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 5 : 반음 이동 패턴 ──────────────────────────────────────────────
  static CurriculumLesson _day5() {
    return CurriculumLesson(
      id: 'week11_day5',
      title: 'Day5 고음 반음 이동 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '높은 옥타브 흰+검은 건반 혼합을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4Mixed,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_learn',
          title: '학습',
          description: '높은 옥타브에서 흰 건반과 인접한 검은 건반을 오가는 반음 이동 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day5HalfStepMove,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_practice',
          title: '연습',
          description: '높은 옥타브 반음 이동 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day5HalfStepMove,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_check',
          title: '확인',
          description: '높은 옥타브 반음 이동 패턴 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day5HalfStepMove,
            totalQuestions: 14,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 6 : 전체 랜덤 ───────────────────────────────────────────────────
  static CurriculumLesson _day6() {
    return CurriculumLesson(
      id: 'week11_day6',
      title: 'Day6 고음 랜덤',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '높은 옥타브 반음 이동 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day5HalfStepMove,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_learn',
          title: '학습',
          description: '높은 옥타브 흰+검은 건반 전체를 랜덤으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 14,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_practice',
          title: '연습',
          description: '높은 옥타브 전체 건반을 랜덤으로 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 20,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_check',
          title: '확인',
          description: '높은 옥타브 전체 건반 랜덤 인식을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ── Day 7 : 최종 확인 ────────────────────────────────────────────────────
  static CurriculumLesson _day7() {
    return CurriculumLesson(
      id: 'week11_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '11주차 높은 옥타브 반음 전체 내용을 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 12,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '최종 점검 전 높은 옥타브 검은 건반 중심으로 정리해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 12,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_practice',
          title: '연습',
          description: '최종 테스트 전 충분히 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 20,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '높은 옥타브 검은 건반 70% 비율로 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day6FullRandom,
            totalQuestions: 20,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.8),
          guideEnabled: false,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 높은 옥타브 MIDI (검은 건반 70% / 흰 건반 30%)
  // 검은 건반: 73(hi C#), 75(hi D#), 78(hi F#), 80(hi G#), 82(hi A#)
  // 흰 건반:   72(hi C),  74(hi D),  76(hi E),  77(hi F),  79(hi G), 81(hi A), 83(hi B)
  // ════════════════════════════════════════════════════════════════════════

  static const List<List<int>> _day1Learn = [
    [73], [73], [75], [73], [75],
    [72], [73], [74], [75], [76],
  ];

  static const List<List<int>> _day1Practice = [
    [73], [72], [73], [74], [73], [75], [76], [75],
    [73], [75], [73], [75], [74], [73], [72], [75],
    [75], [73], [76], [75],
  ];

  static const List<List<int>> _day2Learn = [
    [78], [78], [80], [78], [80],
    [77], [78], [79], [80], [82],
  ];

  static const List<List<int>> _day2Practice = [
    [78], [77], [78], [79], [78], [80], [81], [80],
    [78], [80], [78], [82], [79], [80], [77], [82],
    [82], [78], [81], [80],
  ];

  static const List<List<int>> _allBlackKeys = [
    [73], [75], [78], [80], [82],
    [82], [80], [78], [75], [73],
  ];

  static const List<List<int>> _day3Learn = [
    [73], [75], [78], [80], [82],
    [82], [80], [78], [75], [73],
    [73], [78], [82], [75], [80],
    [72], [75], [77], [80], [83],
    [73], [78],
  ];

  static const List<List<int>> _day4Mixed = [
    [73], [72], [75], [74], [78],
    [77], [80], [79], [82], [81],
    [73], [75], [78], [80], [82],
    [76], [73], [83], [80], [73],
    [75], [82],
  ];

  static const List<List<int>> _day5HalfStepMove = [
    [72], [73], [72],
    [74], [73], [75],
    [76], [75], [76],
    [77], [78], [77],
    [79], [78], [80],
    [81], [80], [82],
    [83], [82], [83],
    [73], [72], [73],
    [75], [74], [75],
    [78], [79], [78],
    [80], [79], [80],
    [82], [81], [82],
  ];

  static const List<List<int>> _day6FullRandom = [
    [73], [75], [78], [80], [82],
    [72], [75], [74], [78], [77],
    [80], [79], [82], [81], [83],
    [73], [78], [73], [80], [75],
    [82], [76], [80], [73], [82],
    [78], [75], [73], [82], [80],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[73]],
      totalQuestions: 1,
    );
  }
}
