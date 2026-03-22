import '../curriculum_models.dart';

class BeginnerWeek4 {
  static Stage stage() {
    return Stage(
      id: 'week_4',
      title: '4주차 왼손 패턴 학습',
      description: '왼손으로 C3~B3 범위의 건반과 패턴을 익혀요.',
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
      id: 'week4_day1',
      title: 'Day1 왼손 단음',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '왼손 도, 레, 미를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
            ],
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: '왼손 도, 레, 미를 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: '왼손 도, 레, 미를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day2() {
    return CurriculumLesson(
      id: 'week4_day2',
      title: 'Day2 왼손 확장',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '왼손 도, 레, 미를 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
            ],
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: '왼손 파, 솔을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [53],
              [55],
            ],
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: '왼손 도~솔을 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
              [53],
              [55],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: '왼손 도~솔을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [48],
              [50],
              [52],
              [53],
              [55],
            ],
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
      id: 'week4_day3',
      title: 'Day3 왼손 전체',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: '왼손 라, 시를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [57],
              [59],
            ],
            totalQuestions: 6,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '왼손 도~시를 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _leftFullRange,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '왼손 전체 범위를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _leftFullRange,
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.72),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day4() {
    return _patternLesson(
      id: 'week4_day4',
      title: 'Day4 왼손 이동',
      description: '왼손 음 이동을 연습해요.',
      sequences: _leftMoves,
    );
  }

  static CurriculumLesson _day5() {
    return _patternLesson(
      id: 'week4_day5',
      title: 'Day5 왼손 점프',
      description: '왼손 점프 패턴을 연습해요.',
      sequences: _leftJumps,
    );
  }

  static CurriculumLesson _day6() {
    return _patternLesson(
      id: 'week4_day6',
      title: 'Day6 랜덤 왼손',
      description: '왼손 랜덤 패턴을 연습해요.',
      sequences: _leftMixed,
      shuffle: true,
    );
  }

  static CurriculumLesson _day7() {
    return _patternLesson(
      id: 'week4_day7',
      title: 'Day7 최종 확인',
      description: '왼손 패턴을 최종 확인해요.',
      sequences: _leftMixed,
      shuffle: true,
      questions: 16,
      accuracy: 0.8,
    );
  }

  static CurriculumLesson _patternLesson({
    required String id,
    required String title,
    required String description,
    required List<List<int>> sequences,
    bool shuffle = false,
    int questions = 12,
    double accuracy = 0.75,
  }) {
    return CurriculumLesson(
      id: id,
      title: title,
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: PassRule(minAccuracy: accuracy),
      steps: [
        LessonPlanStep(
          id: '${id}_practice',
          title: '연습',
          description: description,
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: sequences,
            totalQuestions: questions,
            shuffleQuestions: shuffle,
          ),
          passRule: PassRule(minAccuracy: accuracy),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_check',
          title: '확인',
          description: '패턴을 확인해요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: sequences,
            totalQuestions: questions,
            shuffleQuestions: shuffle,
          ),
          passRule: PassRule(minAccuracy: accuracy),
          guideEnabled: false,
        ),
      ],
    );
  }

  static const List<List<int>> _leftFullRange = [
    [48],
    [50],
    [52],
    [53],
    [55],
    [57],
    [59],
  ];

  static const List<List<int>> _leftMoves = [
    [48], [50], [52],
    [52], [53], [55],
    [55], [57], [59],
  ];

  static const List<List<int>> _leftJumps = [
    [48], [52],
    [50], [53],
    [52], [55],
    [53], [57],
  ];

  static const List<List<int>> _leftMixed = [
    [48], [50], [52],
    [52], [55],
    [50], [53],
    [55], [59],
    [48], [55],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[48]],
      totalQuestions: 1,
    );
  }
}