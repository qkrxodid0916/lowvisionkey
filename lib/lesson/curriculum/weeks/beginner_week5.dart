import '../curriculum_models.dart';

class BeginnerWeek5 {
  static Stage stage() {
    return Stage(
      id: 'week_5',
      title: '5주차 양손 번갈아 학습',
      description: '왼손과 오른손이 번갈아 켜지는 흐름을 따라 치며 양손 전환을 익혀요.',
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
      title: 'Day1 같은 음 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '왼손과 오른손이 같은 음을 번갈아 누르는 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _sameNoteAlternate,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: '같은 음 번갈아 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _sameNoteAlternate,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: '같은 음 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _sameNoteAlternate,
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
      title: 'Day2 가까운 음 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '같은 음 번갈아 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _sameNoteAlternate,
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: '가까운 음을 양손으로 번갈아 누르는 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _nearAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: '가까운 음 번갈아 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _nearAlternate,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: '가까운 음 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _nearAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day3() {
    return CurriculumLesson(
      id: 'week5_day3',
      title: 'Day3 점프 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '가까운 음 번갈아 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _nearAlternate,
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: '점프하는 음을 양손으로 번갈아 누르는 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _jumpAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '점프 번갈아 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _jumpAlternate,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.74),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '점프 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _jumpAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.74),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day4() {
    return CurriculumLesson(
      id: 'week5_day4',
      title: 'Day4 왕복 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '점프 번갈아 패턴을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _jumpAlternate,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_learn',
          title: '학습',
          description: '양손이 번갈아 오가며 반복되는 왕복 흐름을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_practice',
          title: '연습',
          description: '왕복 번갈아 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceAlternate,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_check',
          title: '확인',
          description: '왕복 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceAlternate,
            totalQuestions: 10,
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
      title: 'Day5 3음 흐름 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.76),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '왕복 번갈아 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceAlternate,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_learn',
          title: '학습',
          description: '왼손과 오른손이 3음 흐름으로 번갈아 이어지는 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeFlowAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_practice',
          title: '연습',
          description: '3음 흐름 번갈아 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeFlowAlternate,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.76),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_check',
          title: '확인',
          description: '3음 흐름 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeFlowAlternate,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.76),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day6() {
    return CurriculumLesson(
      id: 'week5_day6',
      title: 'Day6 랜덤 양손 번갈아',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '지금까지 배운 양손 번갈아 패턴을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_learn',
          title: '학습',
          description: '여러 양손 번갈아 패턴을 랜덤으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_practice',
          title: '연습',
          description: '양손 번갈아 패턴을 랜덤으로 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_check',
          title: '확인',
          description: '랜덤 양손 번갈아 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
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
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '5주차 양손 번갈아 패턴을 전체 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '최종 점검 전 양손 흐름을 다시 정리해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 10,
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
            sequences: _allAlternatePatterns,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '5주차 양손 번갈아 패턴을 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allAlternatePatterns,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.8),
          guideEnabled: false,
        ),
      ],
    );
  }

  /// LH=C3~B3 / RH=C4~B4
  static const List<List<int>> _sameNoteAlternate = [
    [48], [60], // 도
    [50], [62], // 레
    [52], [64], // 미
    [53], [65], // 파
    [55], [67], // 솔
  ];

  static const List<List<int>> _nearAlternate = [
    [48], [62], // LH 도 -> RH 레
    [50], [64], // LH 레 -> RH 미
    [52], [65], // LH 미 -> RH 파
    [53], [67], // LH 파 -> RH 솔
    [55], [69], // LH 솔 -> RH 라
  ];

  static const List<List<int>> _jumpAlternate = [
    [48], [64], // LH 도 -> RH 미
    [50], [65], // LH 레 -> RH 파
    [52], [67], // LH 미 -> RH 솔
    [53], [69], // LH 파 -> RH 라
    [55], [71], // LH 솔 -> RH 시
  ];

  static const List<List<int>> _bounceAlternate = [
    [48], [60], [48], // 도
    [50], [62], [50], // 레
    [52], [64], [52], // 미
    [53], [65], [53], // 파
  ];

  static const List<List<int>> _threeFlowAlternate = [
    [48], [60], [52], [64], [55], [67], // 도-도-미-미-솔-솔 느낌
    [50], [62], [53], [65], [57], [69],
    [52], [64], [55], [67], [59], [71],
  ];

  static const List<List<int>> _allAlternatePatterns = [
    [48], [60],
    [50], [62],
    [52], [64],
    [53], [65],
    [55], [67],

    [48], [62],
    [50], [64],
    [52], [65],
    [53], [67],
    [55], [69],

    [48], [64],
    [50], [65],
    [52], [67],
    [53], [69],
    [55], [71],

    [48], [60], [48],
    [50], [62], [50],
    [52], [64], [52],

    [48], [60], [52], [64], [55], [67],
    [50], [62], [53], [65], [57], [69],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[48]],
      totalQuestions: 1,
    );
  }
}