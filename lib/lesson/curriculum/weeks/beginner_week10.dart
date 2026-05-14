import '../curriculum_models.dart';

class BeginnerWeek10 {
  static Stage stage() {
    return Stage(
      id: 'week_10',
      title: '10주차 반음 학습',
      description: '가운데 옥타브의 검은 건반(C#~A#)을 집중적으로 익혀요.',
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

  // ── Day 1 : C# D# 집중 ──────────────────────────────────────────────────
  static CurriculumLesson _day1() {
    return CurriculumLesson(
      id: 'week10_day1',
      title: 'Day1 C# D# 익히기',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day1_learn',
          title: '학습',
          description: 'C#과 D# 검은 건반을 LED 가이드를 보며 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day1Learn, // 검은 건반 70%
            totalQuestions: 10,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day1_practice',
          title: '연습',
          description: 'C#, D# 검은 건반과 주변 흰 건반을 함께 연습해요.',
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
          description: 'C#, D# 검은 건반 인식을 확인해요.',
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

  // ── Day 2 : F# G# A# 집중 ───────────────────────────────────────────────
  static CurriculumLesson _day2() {
    return CurriculumLesson(
      id: 'week10_day2',
      title: 'Day2 F# G# A# 익히기',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.7),
      steps: [
        LessonPlanStep(
          id: 'day2_review',
          title: '복습',
          description: 'C#, D# 검은 건반을 짧게 복습해요.',
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
          description: 'F#, G#, A# 검은 건반을 LED 가이드를 보며 익혀요.',
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
          description: 'F#, G#, A# 검은 건반과 주변 흰 건반을 함께 연습해요.',
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
          description: 'F#, G#, A# 검은 건반 인식을 확인해요.',
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
      id: 'week10_day3',
      title: 'Day3 검은 건반 5개 전체',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.72),
      steps: [
        LessonPlanStep(
          id: 'day3_review',
          title: '복습',
          description: '검은 건반 5개를 순서대로 복습해요.',
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
          description: 'C#부터 A#까지 검은 건반 5개를 전체적으로 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day3Learn,  // 검은 건반 70%
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.6),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day3_practice',
          title: '연습',
          description: '검은 건반 5개를 랜덤으로 반복 연습해요.',
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
          description: '검은 건반 5개 인식을 확인해요.',
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
      id: 'week10_day4',
      title: 'Day4 흰 건반 + 반음 혼합',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.74),
      steps: [
        LessonPlanStep(
          id: 'day4_review',
          title: '복습',
          description: '검은 건반 5개를 랜덤으로 복습해요.',
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
          description: '흰 건반과 검은 건반을 섞어서 익혀요. 검은 건반이 더 자주 나와요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day4Mixed,  // 검은 건반 70%, 흰 건반 30%
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day4_practice',
          title: '연습',
          description: '흰 건반과 검은 건반 혼합을 반복 연습해요.',
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
          description: '흰 건반과 검은 건반 혼합 인식을 확인해요.',
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
      id: 'week10_day5',
      title: 'Day5 반음 이동 패턴',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.75),
      steps: [
        LessonPlanStep(
          id: 'day5_review',
          title: '복습',
          description: '흰 건반 + 검은 건반 혼합을 짧게 복습해요.',
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
          description: '흰 건반과 인접한 검은 건반을 오가는 반음 이동 패턴을 익혀요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _day5HalfStepMove, // 검은 건반 70%
            totalQuestions: 14,
          ),
          passRule: const PassRule(minAccuracy: 0.65),
          guideEnabled: true,
        ),
        LessonPlanStep(
          id: 'day5_practice',
          title: '연습',
          description: '반음 이동 패턴을 반복 연습해요.',
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
          description: '반음 이동 패턴 인식을 확인해요.',
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

  // ── Day 6 : 전체 랜덤 (검은 건반 70%) ──────────────────────────────────
  static CurriculumLesson _day6() {
    return CurriculumLesson(
      id: 'week10_day6',
      title: 'Day6 전체 랜덤',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.78),
      steps: [
        LessonPlanStep(
          id: 'day6_review',
          title: '복습',
          description: '반음 이동 패턴을 짧게 복습해요.',
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
          description: '흰 건반과 검은 건반 전체를 랜덤으로 익혀요. 검은 건반이 70% 비율로 나와요.',
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
          description: '흰 건반 + 검은 건반 전체를 랜덤으로 연습해요.',
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
          description: '전체 건반 랜덤 인식을 확인해요.',
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
      id: 'week10_day7',
      title: 'Day7 최종 확인',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.8),
      steps: [
        LessonPlanStep(
          id: 'day7_review',
          title: '복습',
          description: '10주차 전체 내용을 복습해요.',
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
          description: '최종 점검 전 검은 건반 중심으로 한 번 더 정리해요.',
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
          description: '검은 건반 70% 비율로 최종 확인해요.',
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
  // 시퀀스 데이터 (검은 건반 70% / 흰 건반 30%)
  // 검은 건반: 61(C#), 63(D#), 66(F#), 68(G#), 70(A#)
  // 흰 건반:   60(C),  62(D),  64(E),  65(F),  67(G), 69(A), 71(B)
  // ════════════════════════════════════════════════════════════════════════

  // Day1 학습: C#, D# 집중 (검은 건반 70%)
  // 10개 중 7개 검은(C#×4, D#×3), 3개 흰(C, D, E)
  static const List<List<int>> _day1Learn = [
    [61], [61], [63], [61], [63], // C# C# D# C# D#
    [60], [61], [62], [63], [64], // C  C# D  D# E
  ];

  // Day1 연습: C#, D# + 주변 흰 건반 (검은 건반 70%)
  // 20개 중 14개 검은(C#×7, D#×7), 6개 흰
  static const List<List<int>> _day1Practice = [
    [61], [60], [61], [62], [61], [63], [64], [63], // C# C C# D C# D# E D#
    [61], [63], [61], [63], [62], [61], [60], [63], // C# D# C# D# D C# C D#
    [63], [61], [64], [63],                         // D# C# E D#
  ];

  // Day2 학습: F#, G#, A# 집중 (검은 건반 70%)
  // 10개 중 7개 검은(F#×3, G#×2, A#×2), 3개 흰(F, G, A)
  static const List<List<int>> _day2Learn = [
    [66], [66], [68], [66], [68], // F# F# G# F# G#
    [65], [66], [67], [68], [70], // F  F# G  G# A#
  ];

  // Day2 연습: F#, G#, A# + 주변 흰 건반 (검은 건반 70%)
  static const List<List<int>> _day2Practice = [
    [66], [65], [66], [67], [66], [68], [69], [68], // F# F F# G F# G# A G#
    [66], [68], [66], [70], [67], [68], [65], [70], // F# G# F# A# G G# F A#
    [70], [66], [69], [68],                         // A# F# A G#
  ];

  // 검은 건반 5개 전체 (순서대로 + 역순)
  static const List<List<int>> _allBlackKeys = [
    [61], [63], [66], [68], [70], // C# D# F# G# A#
    [70], [68], [66], [63], [61], // A# G# F# D# C#
  ];

  // Day3 학습: 검은 건반 5개 전체 (검은 건반 70%)
  // 20개 중 14개 검은, 6개 흰
  static const List<List<int>> _day3Learn = [
    [61], [63], [66], [68], [70], // C# D# F# G# A#
    [70], [68], [66], [63], [61], // A# G# F# D# C#
    [61], [66], [70], [63], [68], // C# F# A# D# G#
    [60], [63], [65], [68], [71], // C  D# F  G# B  (흰건반 30%)
    [61], [66],                   // C# F#
  ];

  // Day4 혼합: 흰 건반 + 검은 건반 (검은 건반 70%)
  // 20개 중 14개 검은, 6개 흰
  static const List<List<int>> _day4Mixed = [
    [61], [60], [63], [62], [66], // C# C D# D F#
    [65], [68], [67], [70], [69], // F  G# G A# A
    [61], [63], [66], [68], [70], // C# D# F# G# A#
    [64], [61], [71], [68], [61], // E  C# B  G# C#
    [63], [70],                   // D# A#
  ];

  // Day5 반음 이동 패턴 (흰-검-흰, 검-흰-검 패턴, 검은 건반 70%)
  // 각 3개 그룹에서 검은 건반 2개, 흰 건반 1개
  static const List<List<int>> _day5HalfStepMove = [
    [60], [61], [60], // C  C# C
    [62], [61], [63], // D  C# D#
    [64], [63], [64], // E  D# E
    [65], [66], [65], // F  F# F
    [67], [66], [68], // G  F# G#
    [69], [68], [70], // A  G# A#
    [71], [70], [71], // B  A# B
    [61], [60], [61], // C# C  C#
    [63], [62], [63], // D# D  D#
    [66], [67], [66], // F# G  F#
    [68], [67], [68], // G# G  G#
    [70], [69], [70], // A# A  A#
  ];

  // Day6/7 전체 랜덤 (검은 건반 70%)
  // 30개 중 21개 검은, 9개 흰
  static const List<List<int>> _day6FullRandom = [
    [61], [63], [66], [68], [70], // C# D# F# G# A#
    [60], [63], [62], [66], [65], // C  D# D  F# F
    [68], [67], [70], [69], [71], // G# G  A# A  B
    [61], [66], [61], [68], [63], // C# F# C# G# D#
    [70], [64], [68], [61], [70], // A# E  G# C# A#
    [66], [63], [61], [70], [68], // F# D# C# A# G#
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[61]],
      totalQuestions: 1,
    );
  }
}
