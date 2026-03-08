// lib/lesson/curriculum/weeks/beginner_week1.dart

import '../curriculum_models.dart';

class BeginnerWeek1 {
  static Stage stage() {
    return Stage(
      id: 'week_1',
      title: '1주차 단음 학습',
      description: '중앙 옥타브 C4~B4의 건반 위치를 익혀요.',
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
      id: 'week1_day1',
      title: 'Day1 C D E',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: '도(C), 레(D), 미(E)를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60],
              [62],
              [64],
            ],
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: '도, 레, 미를 반복 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60],
              [62],
              [64],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_check',
          title: '확인',
          description: '도, 레, 미를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60],
              [62],
              [64],
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
      id: 'week1_day2',
      title: 'Day2 F G',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: '도, 레, 미를 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64],
            ],
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_learn',
          title: '학습',
          description: '파(F), 솔(G)을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [65], [67],
            ],
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_practice',
          title: '연습',
          description: '도~솔까지 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64], [65], [67],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day2_check',
          title: '확인',
          description: '도~솔을 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64], [65], [67],
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
      id: 'week1_day3',
      title: 'Day3 A B',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '도~솔을 복습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64], [65], [67],
            ],
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_learn',
          title: '학습',
          description: '라(A), 시(B)를 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [69], [71],
            ],
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '도~시까지 연습해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64], [65], [67], [69], [71],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_check',
          title: '확인',
          description: '도~시를 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: [
              [60], [62], [64], [65], [67], [69], [71],
            ],
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.7),
          guideEnabled: false,
        ),
      ],
    );
  }

  static CurriculumLesson _day4() {
    return _fullRangeLesson(
      id: 'week1_day4',
      title: 'Day4 전체 복습',
      description: '도~시 전체를 복습해요.',
      practiceQuestions: 10,
      checkQuestions: 10,
      minAccuracy: 0.75,
    );
  }

  static CurriculumLesson _day5() {
    return _fullRangeLesson(
      id: 'week1_day5',
      title: 'Day5 랜덤 인식',
      description: '도~시를 랜덤으로 인식해요.',
      practiceQuestions: 10,
      checkQuestions: 10,
      minAccuracy: 0.75,
    );
  }

  static CurriculumLesson _day6() {
    return _fullRangeLesson(
      id: 'week1_day6',
      title: 'Day6 보완 연습',
      description: '어려운 음을 포함해 전체를 다시 연습해요.',
      practiceQuestions: 10,
      checkQuestions: 10,
      minAccuracy: 0.78,
    );
  }

  static CurriculumLesson _day7() {
    return CurriculumLesson(
      id: 'week1_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '최종 테스트 전 전체 복습이에요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_learn',
          title: '학습',
          description: '새로운 음 없이 최종 점검을 준비해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 5,
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
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.75),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day7_check',
          title: '확인',
          description: '중앙 옥타브 도~시를 최종 확인해요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 15,
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
  }) {
    return CurriculumLesson(
      id: id,
      title: title,
      mode: LessonInputMode.both,
      plan: _dummyPlan(),
      passRule: PassRule(minAccuracy: minAccuracy),
      steps: [
        LessonPlanStep(
          id: '${id}_review',
          title: '복습',
          description: description,
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_learn',
          title: '학습',
          description: '새로운 음 없이 전체 범위를 다시 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: 5,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_practice',
          title: '연습',
          description: '전체 범위를 반복 연습해요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: practiceQuestions,
          ),
          passRule: PassRule(minAccuracy: minAccuracy),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: '${id}_check',
          title: '확인',
          description: '전체 범위를 확인해요.',
          plan: LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _fullRange,
            totalQuestions: checkQuestions,
          ),
          passRule: PassRule(minAccuracy: minAccuracy),
          guideEnabled: false,
        ),
      ],
    );
  }

  static const List<List<int>> _fullRange = [
    [60], [62], [64], [65], [67], [69], [71],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[60]],
      totalQuestions: 1,
    );
  }
}