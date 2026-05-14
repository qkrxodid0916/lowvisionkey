import '../curriculum_models.dart';

class BeginnerWeek12 {
  static Stage stage() {
    return Stage(
      id: 'week_12',
      title: '12주차 낮은 옥타브 반음 학습',
      description: '낮은 옥타브의 검은 건반(low C#~low A#)을 집중적으로 익혀요.',
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

  // ── Day 1 : low C# low D# 집중 ──────────────────────────────────────────
  static CurriculumLesson _day1() {
    return CurriculumLesson(
      id: 'week12_day1',
      title: 'Day1 low C# low D#',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: 'low C#과 low D# 검은 건반을 LED 가이드를 보며 익혀요.',
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
          description: 'low C#, low D# 검은 건반과 주변 흰 건반을 함께 연습해요.',
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
          description: 'low C#, low D# 검은 건반 인식을 확인해요.',
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

  // ── Day 2 : low F# low G# low A# 집중 ──────────────────────────────────
  static CurriculumLesson _day2() {
    return CurriculumLesson(
      id: 'week12_day2',
      title: 'Day2 low F# low G# low A#',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: 'low C#, low D# 검은 건반을 짧게 복습해요.',
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
          description: 'low F#, low G#, low A# 검은 건반을 LED 가이드를 보며 익혀요.',
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
          description: 'low F#, low G#, low A# 검은 건반과 주변 흰 건반을 함께 연습해요.',
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
          description: 'low F#, low G#, low A# 검은 건반 인식을 확인해요.',
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
      id: 'week12_day3',
      title: 'Day3 저음 검은 건반 전체',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '낮은 옥타브 검은 건반 5개를 순서대로 복습해요.',
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
          description: 'low C#부터 low A#까지 검은 건반 5개를 전체적으로 익혀요.',
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
          description: '낮은 옥타브 검은 건반 5개를 랜덤으로 반복 연습해요.',
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
          description: '낮은 옥타브 검은 건반 5개 인식을 확인해요.',
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
      id: 'week12_day4',
      title: 'Day4 저음 흰+검은 혼합',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '낮은 옥타브 검은 건반 5개를 랜덤으로 복습해요.',
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
          description: '낮은 옥타브 흰 건반과 검은 건반을 섞어서 익혀요.',
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
          description: '낮은 옥타브 흰+검은 건반 혼합을 반복 연습해요.',
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
          description: '낮은 옥타브 흰+검은 건반 혼합 인식을 확인해요.',
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
      id: 'week12_day5',
      title: 'Day5 저음 반음 이동 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '낮은 옥타브 흰+검은 건반 혼합을 짧게 복습해요.',
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
          description: '낮은 옥타브에서 흰 건반과 인접한 검은 건반을 오가는 반음 이동 패턴을 익혀요.',
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
          description: '낮은 옥타브 반음 이동 패턴을 반복 연습해요.',
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
          description: '낮은 옥타브 반음 이동 패턴 인식을 확인해요.',
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
      id: 'week12_day6',
      title: 'Day6 저음 랜덤',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '낮은 옥타브 반음 이동 패턴을 짧게 복습해요.',
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
          description: '낮은 옥타브 흰+검은 건반 전체를 랜덤으로 익혀요.',
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
          description: '낮은 옥타브 전체 건반을 랜덤으로 연습해요.',
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
          description: '낮은 옥타브 전체 건반 랜덤 인식을 확인해요.',
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
      id: 'week12_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '12주차 낮은 옥타브 반음 전체 내용을 복습해요.',
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
          description: '최종 점검 전 낮은 옥타브 검은 건반 중심으로 정리해요.',
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
          description: '낮은 옥타브 검은 건반 70% 비율로 최종 확인해요.',
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
  // 낮은 옥타브 MIDI (검은 건반 70% / 흰 건반 30%)
  // 검은 건반: 49(low C#), 51(low D#), 54(low F#), 56(low G#), 58(low A#)
  // 흰 건반:   48(low C),  50(low D),  52(low E),  53(low F),  55(low G), 57(low A), 59(low B)
  // ════════════════════════════════════════════════════════════════════════

  static const List<List<int>> _day1Learn = [
    [49], [49], [51], [49], [51],
    [48], [49], [50], [51], [52],
  ];

  static const List<List<int>> _day1Practice = [
    [49], [48], [49], [50], [49], [51], [52], [51],
    [49], [51], [49], [51], [50], [49], [48], [51],
    [51], [49], [52], [51],
  ];

  static const List<List<int>> _day2Learn = [
    [54], [54], [56], [54], [56],
    [53], [54], [55], [56], [58],
  ];

  static const List<List<int>> _day2Practice = [
    [54], [53], [54], [55], [54], [56], [57], [56],
    [54], [56], [54], [58], [55], [56], [53], [58],
    [58], [54], [57], [56],
  ];

  static const List<List<int>> _allBlackKeys = [
    [49], [51], [54], [56], [58],
    [58], [56], [54], [51], [49],
  ];

  static const List<List<int>> _day3Learn = [
    [49], [51], [54], [56], [58],
    [58], [56], [54], [51], [49],
    [49], [54], [58], [51], [56],
    [48], [51], [53], [56], [59],
    [49], [54],
  ];

  static const List<List<int>> _day4Mixed = [
    [49], [48], [51], [50], [54],
    [53], [56], [55], [58], [57],
    [49], [51], [54], [56], [58],
    [52], [49], [59], [56], [49],
    [51], [58],
  ];

  static const List<List<int>> _day5HalfStepMove = [
    [48], [49], [48],
    [50], [49], [51],
    [52], [51], [52],
    [53], [54], [53],
    [55], [54], [56],
    [57], [56], [58],
    [59], [58], [59],
    [49], [48], [49],
    [51], [50], [51],
    [54], [55], [54],
    [56], [55], [56],
    [58], [57], [58],
  ];

  static const List<List<int>> _day6FullRandom = [
    [49], [51], [54], [56], [58],
    [48], [51], [50], [54], [53],
    [56], [55], [58], [57], [59],
    [49], [54], [49], [56], [51],
    [58], [52], [56], [49], [58],
    [54], [51], [49], [58], [56],
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[49]],
      totalQuestions: 1,
    );
  }
}
