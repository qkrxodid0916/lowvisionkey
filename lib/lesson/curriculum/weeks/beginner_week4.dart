import '../curriculum_models.dart';

class BeginnerWeek4 {
  static Stage stage() {
    return Stage(
      id: 'week_4',
      title: '4주차 높은 옥타브 단음 학습',
      description: '높은 옥타브 C5~B5의 건반 위치를 익혀요.',
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
      title: 'Day1 hi C hi D hi E',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '높은 도(hi C), 높은 레(hi D), 높은 미(hi E)를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: 'hi C, hi D, hi E를 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
            ],
            totalQuestions: 15,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: 'hi C, hi D, hi E를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
            ],
            totalQuestions: 12,
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
      title: 'Day2 hi F hi G',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: 'hi C, hi D, hi E를 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: '높은 파(hi F), 높은 솔(hi G)을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [77],
              [79],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: 'hi C~hi G까지 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
              [77],
              [79],
            ],
            totalQuestions: 15,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: 'hi C~hi G를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
              [77],
              [79],
            ],
            totalQuestions: 12,
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
      title: 'Day3 hi A hi B',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: 'hi C~hi G를 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [72],
              [74],
              [76],
              [77],
              [79],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: '높은 라(hi A), 높은 시(hi B)를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [81],
              [83],
            ],
            totalQuestions: 8,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: 'hi C~hi B까지 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 15,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: 'hi C~hi B를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 12,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day4() {
    return _fullRangeLesson(
      id: 'week4_day4',
      title: 'Day4 전체 복습',
      description: 'hi C~hi B 전체를 복습해요.',
      practiceQuestions: 15,
      checkQuestions: 12,
      minAccuracy: 0.75,
      shuffleQuestions: false,
    );
  }

  static CurriculumLesson _day5() {
    return _fullRangeLesson(
      id: 'week4_day5',
      title: 'Day5 랜덤 인식',
      description: 'hi C~hi B를 랜덤으로 인식해요.',
      practiceQuestions: 15,
      checkQuestions: 12,
      minAccuracy: 0.75,
      shuffleQuestions: true,
    );
  }

  static CurriculumLesson _day6() {
    return _fullRangeLesson(
      id: 'week4_day6',
      title: 'Day6 보완 연습',
      description: '어려운 높은 음을 포함해 전체를 다시 연습해요.',
      practiceQuestions: 15,
      checkQuestions: 12,
      minAccuracy: 0.78,
      shuffleQuestions: true,
    );
  }

  static CurriculumLesson _day7() {
    return CurriculumLesson(
      id: 'week4_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '최종 테스트 전 높은 옥타브 전체 복습이에요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 8,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '새로운 음 없이 높은 옥타브 최종 점검을 준비해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 8,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_practice',
          title: '연습',
          description: '최종 테스트 전 연습이에요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 15,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '높은 옥타브 hi C~hi B를 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 20,
            shuffleQuestions: true,
          ),
          passRule: const PassRule(minAccuracy: 0.8),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _fullRangeLesson({
    required String id,
    required String title,
    required String description,
    required int practiceQuestions,
    required int checkQuestions,
    required double minAccuracy,
    bool shuffleQuestions = false,
  }) {
    return CurriculumLesson(
      id: id,
      title: title,
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: PassRule(minAccuracy: minAccuracy),
      steps: [
        LessonPlanStep(
          id: '${id}_review',
          title: '복습',
          description: description,
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 8,
            shuffleQuestions: shuffleQuestions,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_learn',
          title: '학습',
          description: '새로운 음 없이 높은 옥타브 전체 범위를 다시 익혀요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 8,
            shuffleQuestions: shuffleQuestions,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_practice',
          title: '연습',
          description: '높은 옥타브 전체 범위를 반복 연습해요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: practiceQuestions,
            shuffleQuestions: shuffleQuestions,
          ),
          passRule: PassRule(minAccuracy: minAccuracy),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_check',
          title: '확인',
          description: '높은 옥타브 전체 범위를 확인해요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: checkQuestions,
            shuffleQuestions: shuffleQuestions,
          ),
          passRule: PassRule(minAccuracy: minAccuracy),
          guideEnabled: false,
        ),
      ],
    );
  }

  static const List<List<int>> _fullRange = [
    [72],
    [74],
    [76],
    [77],
    [79],
    [81],
    [83],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[72]],
      totalQuestions: 1,
    );
  }
}
