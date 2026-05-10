import '../curriculum_models.dart';

class BeginnerWeek9 {
  static Stage stage() {
    return Stage(
      id: 'week_9',
      title: '9주차 낮은 옥타브 도약 패턴 학습',
      description: '낮은 옥타브 C3~B3에서 건너뛰는 음 패턴을 익혀요.',
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
      id: 'week9_day1',
      title: 'Day1 낮은 2음 점프 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '낮은 옥타브에서 순서대로 켜지는 2음 점프 패턴을 따라 치며 익혀요.',
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
          description: '낮은 옥타브 2음 점프 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 2음 점프 패턴을 확인해요.',
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
      id: 'week9_day2',
      title: 'Day2 낮은 3음 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '낮은 옥타브 2음 점프 패턴을 다시 확인해요.',
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
          description: 'low C-low E-low G처럼 순서대로 이어지는 낮은 3음 점멸 패턴을 익혀요.',
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
          description: '낮은 옥타브 3음 점멸 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 3음 점멸 패턴을 확인해요.',
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
      id: 'week9_day3',
      title: 'Day3 낮은 역방향 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '낮은 옥타브 3음 점멸 패턴을 짧게 복습해요.',
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
          description: 'low G-low E-low C처럼 반대 방향으로 이어지는 낮은 패턴을 익혀요.',
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
          description: '낮은 옥타브 역방향 점멸 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 역방향 점멸 패턴을 확인해요.',
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
      id: 'week9_day4',
      title: 'Day4 낮은 왕복 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '낮은 옥타브 정방향과 역방향 패턴을 함께 복습해요.',
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
          description: '낮은 옥타브에서 켜졌다가 다시 돌아오는 왕복 점멸 패턴을 익혀요.',
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
          description: '낮은 옥타브 왕복 점멸 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 왕복 점멸 패턴을 확인해요.',
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
      id: 'week9_day5',
      title: 'Day5 낮은 넓은 점프 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.76),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '낮은 옥타브 왕복 점멸 패턴을 짧게 복습해요.',
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
          description: 'low C-low G, low D-low A처럼 더 넓게 건너뛰는 낮은 패턴을 익혀요.',
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
          description: '낮은 옥타브 넓은 점프 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 넓은 점프 패턴을 확인해요.',
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
      id: 'week9_day6',
      title: 'Day6 낮은 랜덤 점멸 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '지금까지 배운 낮은 옥타브 점프 패턴을 함께 복습해요.',
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
          description: '여러 낮은 옥타브 점멸 패턴을 랜덤으로 익혀요.',
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
          description: '낮은 옥타브 점멸 패턴을 랜덤으로 반복 연습해요.',
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
          description: '낮은 옥타브 랜덤 점멸 패턴을 확인해요.',
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
      id: 'week9_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '9주차 낮은 옥타브 점멸 패턴을 전체 복습해요.',
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
          description: '최종 점검 전 낮은 옥타브 점멸 흐름을 다시 정리해요.',
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
          description: '최종 테스트 전 낮은 옥타브 패턴을 충분히 연습해요.',
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
          description: '9주차 낮은 옥타브 점멸 패턴을 최종 확인해요.',
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
    [48], [52], // low C low E
    [50], [53], // low D low F
    [52], [55], // low E low G
    [53], [57], // low F low A
    [55], [59], // low G low B
  ];

  static const List<List<int>> _threeJumpPatterns = [
    [48], [52], [55], // low C low E 솔
    [50], [53], [57], // low D low F 라
    [52], [55], [59], // low E low G 시
  ];

  static const List<List<int>> _reverseJumpPatterns = [
    [55], [52], [48], // low G low E low C
    [57], [53], [50], // low A low F low D
    [59], [55], [52], // low B low G low E
  ];

  static const List<List<int>> _bounceJumpPatterns = [
    [48], [52], [48], // low C low E 도
    [50], [53], [50], // low D low F 레
    [52], [55], [52], // low E low G 미
    [53], [57], [53], // low F low A 파
  ];

  static const List<List<int>> _wideJumpPatterns = [
    [48], [55], // low C low G
    [50], [57], // low D low A
    [52], [59], // low E low B
    [48], [52], [55], // low C low E 솔
    [48], [55], [52], // low C low G 미
  ];

  static const List<List<int>> _day4ReviewMix = [
    [48], [52], [55],
    [55], [52], [48],
    [50], [53], [57],
    [57], [53], [50],
  ];

  static const List<List<int>> _allJumpPatterns = [
    [48], [52],
    [50], [53],
    [52], [55],
    [53], [57],
    [55], [59],

    [48], [52], [55],
    [50], [53], [57],
    [52], [55], [59],

    [55], [52], [48],
    [57], [53], [50],
    [59], [55], [52],

    [48], [52], [48],
    [50], [53], [50],
    [52], [55], [52],
    [53], [57], [53],

    [48], [55],
    [50], [57],
    [52], [59],
    [48], [55], [52],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[48]],
      totalQuestions: 1,
    );
  }
}