import '../curriculum_models.dart';

class BeginnerWeek6 {
  static Stage stage() {
    return Stage(
      id: 'week_6',
      title: '6주차 높은 옥타브 도약 패턴 학습',
      description: '높은 옥타브 C5~B5에서 건너뛰는 음 패턴을 익혀요.',
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
      id: 'week6_day1',
      title: 'Day1 높은 2음 점프 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '높은 옥타브에서 순서대로 켜지는 2음 점프 패턴을 따라 치며 익혀요.',
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
          description: '높은 옥타브 2음 점프 패턴을 반복 연습해요.',
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
          description: '높은 옥타브 2음 점프 패턴을 확인해요.',
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
      id: 'week6_day2',
      title: 'Day2 높은 3음 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '높은 옥타브 2음 점프 패턴을 다시 확인해요.',
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
          description: 'hi C-hi E-hi G처럼 순서대로 이어지는 높은 3음 점멸 패턴을 익혀요.',
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
          description: '높은 옥타브 3음 점멸 패턴을 반복 연습해요.',
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
          description: '높은 옥타브 3음 점멸 패턴을 확인해요.',
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
      id: 'week6_day3',
      title: 'Day3 높은 역방향 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '높은 옥타브 3음 점멸 패턴을 짧게 복습해요.',
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
          description: 'hi G-hi E-hi C처럼 반대 방향으로 이어지는 높은 패턴을 익혀요.',
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
          description: '높은 옥타브 역방향 점멸 패턴을 반복 연습해요.',
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
          description: '높은 옥타브 역방향 점멸 패턴을 확인해요.',
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
      id: 'week6_day4',
      title: 'Day4 높은 왕복 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '높은 옥타브 정방향과 역방향 패턴을 함께 복습해요.',
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
          description: '높은 옥타브에서 켜졌다가 다시 돌아오는 왕복 점멸 패턴을 익혀요.',
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
          description: '높은 옥타브 왕복 점멸 패턴을 반복 연습해요.',
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
          description: '높은 옥타브 왕복 점멸 패턴을 확인해요.',
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
      id: 'week6_day5',
      title: 'Day5 높은 넓은 점프 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.76),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '높은 옥타브 왕복 점멸 패턴을 짧게 복습해요.',
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
          description: 'hi C-hi G, hi D-hi A처럼 더 넓게 건너뛰는 높은 패턴을 익혀요.',
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
          description: '높은 옥타브 넓은 점프 패턴을 반복 연습해요.',
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
          description: '높은 옥타브 넓은 점프 패턴을 확인해요.',
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
      id: 'week6_day6',
      title: 'Day6 높은 랜덤 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '지금까지 배운 높은 옥타브 점프 패턴을 함께 복습해요.',
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
          description: '여러 높은 옥타브 점멸 패턴을 랜덤으로 익혀요.',
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
          description: '높은 옥타브 점멸 패턴을 랜덤으로 반복 연습해요.',
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
          description: '높은 옥타브 랜덤 점멸 패턴을 확인해요.',
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
      id: 'week6_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '6주차 높은 옥타브 점멸 패턴을 전체 복습해요.',
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
          description: '최종 점검 전 높은 옥타브 점멸 흐름을 다시 정리해요.',
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
          description: '최종 테스트 전 높은 옥타브 패턴을 충분히 연습해요.',
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
          description: '6주차 높은 옥타브 점멸 패턴을 최종 확인해요.',
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
    [72], [76], // hi C hi E
    [74], [77], // hi D hi F
    [76], [79], // hi E hi G
    [77], [81], // hi F hi A
    [79], [83], // hi G hi B
  ];

  static const List<List<int>> _threeJumpPatterns = [
    [72], [76], [79], // hi C hi E 솔
    [74], [77], [81], // hi D hi F 라
    [76], [79], [83], // hi E hi G 시
  ];

  static const List<List<int>> _reverseJumpPatterns = [
    [79], [76], [72], // hi G hi E hi C
    [81], [77], [74], // hi A hi F hi D
    [83], [79], [76], // hi B hi G hi E
  ];

  static const List<List<int>> _bounceJumpPatterns = [
    [72], [76], [72], // hi C hi E 도
    [74], [77], [74], // hi D hi F 레
    [76], [79], [76], // hi E hi G 미
    [77], [81], [77], // hi F hi A 파
  ];

  static const List<List<int>> _wideJumpPatterns = [
    [72], [79], // hi C hi G
    [74], [81], // hi D hi A
    [76], [83], // hi E hi B
    [72], [76], [79], // hi C hi E 솔
    [72], [79], [76], // hi C hi G 미
  ];

  static const List<List<int>> _day4ReviewMix = [
    [72], [76], [79],
    [79], [76], [72],
    [74], [77], [81],
    [81], [77], [74],
  ];

  static const List<List<int>> _allJumpPatterns = [
    [72], [76],
    [74], [77],
    [76], [79],
    [77], [81],
    [79], [83],

    [72], [76], [79],
    [74], [77], [81],
    [76], [79], [83],

    [79], [76], [72],
    [81], [77], [74],
    [83], [79], [76],

    [72], [76], [72],
    [74], [77], [74],
    [76], [79], [76],
    [77], [81], [77],

    [72], [79],
    [74], [81],
    [76], [83],
    [72], [79], [76],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[72]],
      totalQuestions: 1,
    );
  }
}