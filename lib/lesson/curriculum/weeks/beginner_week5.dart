import '../curriculum_models.dart';

class BeginnerWeek5 {
  static Stage stage() {
    return Stage(
      id: 'week_5',
      title: '5주차 높은 옥타브 음 이동 학습',
      description: '높은 옥타브 C5~B5 안에서 음의 상행·하행 이동을 익혀요.',
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

  static CurriculumLesson _day1() {
    return CurriculumLesson(
      id: 'week5_day1',
      title: 'Day1 hi C~hi G 상행',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: 'hi C에서 hi G까지 위로 올라가는 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72], [74], [76], [77], [79],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: 'hi C~hi G 상행을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72], [74], [76], [77], [79],
            ],
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: 'hi C~hi G 상행 흐름을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72], [74], [76], [77], [79],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day2() {
    return CurriculumLesson(
      id: 'week5_day2',
      title: 'Day2 hi C~hi B 상행',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: 'hi C~hi G 상행을 다시 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72], [74], [76], [77], [79],
            ],
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: 'hi C에서 hi B까지 높은 옥타브 상행을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeAsc,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: 'hi C~hi B 상행을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeAsc,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: '높은 옥타브 상행을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeAsc,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day3() {
    return CurriculumLesson(
      id: 'week5_day3',
      title: 'Day3 높은 옥타브 하행',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '높은 옥타브 상행 흐름을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeAsc,
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: 'hi B에서 hi C까지 내려오는 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeDesc,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '높은 옥타브 하행 이동을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeDesc,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '높은 옥타브 하행 흐름을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRangeDesc,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day4() {
    return CurriculumLesson(
      id: 'week5_day4',
      title: 'Day4 높은 옥타브 상·하행',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '높은 옥타브 상행과 하행을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _ascDescMix,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_learn',
          title: '학습',
          description: '높은 옥타브에서 오르내리는 흐름을 자연스럽게 연결해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _ascDescMix,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_practice',
          title: '연습',
          description: '높은 옥타브 상행과 하행이 섞인 흐름을 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _ascDescMix,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_check',
          title: '확인',
          description: '높은 옥타브 상·하행 결합을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _ascDescMix,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day5() {
    return CurriculumLesson(
      id: 'week5_day5',
      title: 'Day5 높은 옥타브 도약',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '높은 옥타브에서 붙어 있는 음 이동을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _ascDescMix,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_learn',
          title: '학습',
          description: '높은 옥타브에서 한 칸 건너 뛰는 도약 이동을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _skipMoves,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_practice',
          title: '연습',
          description: '높은 옥타브 도약 이동을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _skipMoves,
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_check',
          title: '확인',
          description: '높은 옥타브 도약 이동을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _skipMoves,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day6() {
    return CurriculumLesson(
      id: 'week5_day6',
      title: 'Day6 높은 옥타브 랜덤 이동',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '높은 옥타브 상행, 하행, 도약 이동을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_learn',
          title: '학습',
          description: '높은 옥타브의 다양한 이동 패턴을 랜덤으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_practice',
          title: '연습',
          description: '높은 옥타브 안에서 랜덤 이동을 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_check',
          title: '확인',
          description: '높은 옥타브 랜덤 이동을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 12,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day7() {
    return CurriculumLesson(
      id: 'week5_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '5주차 높은 옥타브 이동 패턴을 전체 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '최종 점검 전 높은 옥타브 흐름을 한 번 더 정리해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_practice',
          title: '연습',
          description: '최종 테스트 전 높은 옥타브 이동을 충분히 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '높은 옥타브 음 이동을 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _movementMixed,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.8),
          guideEnabled: false,
        ),
      ],
    );
  }

  static const List<List<int>> _fullRangeAsc = [
    [72], [74], [76], [77], [79], [81], [83],
  ];

  static const List<List<int>> _fullRangeDesc = [
    [83], [81], [79], [77], [76], [74], [72],
  ];

  static const List<List<int>> _ascDescMix = [
    [72], [74], [76], [77], [79], [77], [76], [74],
    [76], [77], [79], [81], [83], [81], [79], [77],
  ];

  static const List<List<int>> _skipMoves = [
    [72], [76], [74], [77], [76], [79], [77], [81], [79], [83],
    [83], [79], [81], [77], [79], [76], [77], [74], [76], [72],
  ];

  static const List<List<int>> _movementMixed = [
    [72], [74], [76], [77], [79], [81], [83],
    [83], [81], [79], [77], [76], [74], [72],
    [72], [76], [74], [77], [76], [79], [77], [81], [79], [83],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[72]],
      totalQuestions: 1,
    );
  }
}