import '../curriculum_models.dart';

class BeginnerHighOctaveGuide {
  static Stage stage() {
    return Stage(
      id: 'beginner_high_octave_guide',
      title: '높은 옥타브 가이드',
      description: '높은 옥타브 C5~B5 위치와 소리를 먼저 익혀요.',
      lessons: [
        _guideLesson(),
      ],
    );
  }

  static CurriculumLesson _guideLesson() {
    return CurriculumLesson(
      id: 'beginner_high_octave_guide_lesson',
      title: '높은 옥타브 입문',
      mode: LessonInputMode.both,
      octaveGuide: 3,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.9),
      steps: [
        LessonPlanStep(
          id: 'high_octave_repeat',
          title: '듣고 따라 치기',
          description: '소리와 LED를 보고 높은 옥타브 C5~B5를 3번 반복해서 따라 쳐요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _highOctaveRepeat3,
            totalQuestions: 21,
            shuffleQuestions: false,
          ),
          passRule: const PassRule(minAccuracy: 0.9),
          guideEnabled: true,
        ),
      ],
    );
  }

  static const List<List<int>> _highOctaveRepeat3 = [
    [72], // C5
    [74], // D5
    [76], // E5
    [77], // F5
    [79], // G5
    [81], // A5
    [83], // B5

    [72], // C5
    [74], // D5
    [76], // E5
    [77], // F5
    [79], // G5
    [81], // A5
    [83], // B5

    [72], // C5
    [74], // D5
    [76], // E5
    [77], // F5
    [79], // G5
    [81], // A5
    [83], // B5
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[72]],
      totalQuestions: 1,
    );
  }
}