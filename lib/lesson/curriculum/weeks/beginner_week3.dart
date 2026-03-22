import '../curriculum_models.dart';

class BeginnerWeek3 {
  static Stage stage() {
    return Stage(
      id: 'week_3',
      title: '3주차 도약 패턴 학습',
      description: '순서대로 켜지는 건반 흐름을 보며, 건너뛰는 음 패턴을 익혀요.',
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
      id: 'week3_day1',
      title: 'Day1 2음 점프 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '순서대로 켜지는 2음 점프 패턴을 따라 치며 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _twoJumpPatterns,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: '2음 점프 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _twoJumpPatterns,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: '2음 점프 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _twoJumpPatterns,
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
      id: 'week3_day2',
      title: 'Day2 3음 점멸 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '2음 점프 패턴을 다시 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _twoJumpPatterns,
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: '도-미-솔처럼 순서대로 이어지는 3음 점멸 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeJumpPatterns,
            totalQuestions: 9,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: '3음 점멸 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeJumpPatterns,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: '3음 점멸 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeJumpPatterns,
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
      id: 'week3_day3',
      title: 'Day3 역방향 점멸 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '3음 점멸 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _threeJumpPatterns,
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: '솔-미-도처럼 반대 방향으로 이어지는 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _reverseJumpPatterns,
            totalQuestions: 9,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '역방향 점멸 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _reverseJumpPatterns,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.74),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '역방향 점멸 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _reverseJumpPatterns,
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
      id: 'week3_day4',
      title: 'Day4 왕복 점멸 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '정방향과 역방향 패턴을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4ReviewMix,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_learn',
          title: '학습',
          description: '켜졌다가 다시 돌아오는 왕복 점멸 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceJumpPatterns,
            totalQuestions: 9,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_practice',
          title: '연습',
          description: '왕복 점멸 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceJumpPatterns,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_check',
          title: '확인',
          description: '왕복 점멸 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceJumpPatterns,
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
      id: 'week3_day5',
      title: 'Day5 넓은 점프 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.76),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '왕복 점멸 패턴을 짧게 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _bounceJumpPatterns,
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_learn',
          title: '학습',
          description: '도-솔, 레-라처럼 더 넓게 건너뛰는 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _wideJumpPatterns,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_practice',
          title: '연습',
          description: '넓은 점프 패턴을 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _wideJumpPatterns,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.76),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_check',
          title: '확인',
          description: '넓은 점프 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _wideJumpPatterns,
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
      id: 'week3_day6',
      title: 'Day6 랜덤 점멸 패턴',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '지금까지 배운 점프 패턴을 함께 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_learn',
          title: '학습',
          description: '여러 점멸 패턴을 랜덤으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_practice',
          title: '연습',
          description: '점멸 패턴을 랜덤으로 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day6_check',
          title: '확인',
          description: '랜덤 점멸 패턴을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
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
      id: 'week3_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '3주차 점멸 패턴을 전체 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
            totalQuestions: 10,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '최종 점검 전 점멸 흐름을 다시 정리해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
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
            sequences: _allJumpPatterns,
            totalQuestions: 16,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.78),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '3주차 점멸 패턴을 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _allJumpPatterns,
            totalQuestions: 18,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.8),
          guideEnabled: false,
        ),
      ],
    );
  }

  static const List<List<int>> _twoJumpPatterns = [
    [60], [64], // 도 미
    [62], [65], // 레 파
    [64], [67], // 미 솔
    [65], [69], // 파 라
    [67], [71], // 솔 시
  ];

  static const List<List<int>> _threeJumpPatterns = [
    [60], [64], [67], // 도 미 솔
    [62], [65], [69], // 레 파 라
    [64], [67], [71], // 미 솔 시
  ];

  static const List<List<int>> _reverseJumpPatterns = [
    [67], [64], [60], // 솔 미 도
    [69], [65], [62], // 라 파 레
    [71], [67], [64], // 시 솔 미
  ];

  static const List<List<int>> _bounceJumpPatterns = [
    [60], [64], [60], // 도 미 도
    [62], [65], [62], // 레 파 레
    [64], [67], [64], // 미 솔 미
    [65], [69], [65], // 파 라 파
  ];

  static const List<List<int>> _wideJumpPatterns = [
    [60], [67], // 도 솔
    [62], [69], // 레 라
    [64], [71], // 미 시
    [60], [64], [67], // 도 미 솔
    [60], [67], [64], // 도 솔 미
  ];

  static const List<List<int>> _day4ReviewMix = [
    [60], [64], [67],
    [67], [64], [60],
    [62], [65], [69],
    [69], [65], [62],
  ];

  static const List<List<int>> _allJumpPatterns = [
    [60], [64],
    [62], [65],
    [64], [67],
    [65], [69],
    [67], [71],

    [60], [64], [67],
    [62], [65], [69],
    [64], [67], [71],

    [67], [64], [60],
    [69], [65], [62],
    [71], [67], [64],

    [60], [64], [60],
    [62], [65], [62],
    [64], [67], [64],
    [65], [69], [65],

    [60], [67],
    [62], [69],
    [64], [71],
    [60], [67], [64],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[60]],
      totalQuestions: 1,
    );
  }
}