import '../curriculum_models.dart';

class BeginnerMiddleOctaveGuide {
  static Stage stage() {
    return Stage(
      id: 'beginner_middle_octave_guide',
      title: '가운데 옥타브 가이드',
      description: '1주차를 시작하기 전에 C4~B4 위치와 소리를 먼저 익혀요.',
      lessons: [
        _guideLesson(),
      ],
    );
  }

  static CurriculumLesson _guideLesson() {
    return CurriculumLesson(
      id: 'beginner_middle_octave_guide_lesson',
      title: '가운데 옥타브 듣고 따라 치기',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.9),
      steps: [
        LessonPlanStep(
          id: 'middle_octave_repeat',
          title: '듣고 따라 치기',
          description: '소리와 LED를 보고 가운데 옥타브 C4~B4를 3번 반복해서 따라 쳐요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _middleOctaveRepeat3,
            totalQuestions: 21,
            shuffleQuestions: false,
          ),
          passRule: const PassRule(minAccuracy: 0.9),
          guideEnabled: true,
        ),
      ],
    );
  }

  static const List<List<int>> _middleOctaveRepeat3 = [
    [60], // C4
    [62], // D4
    [64], // E4
    [65], // F4
    [67], // G4
    [69], // A4
    [71], // B4

    [60], // C4
    [62], // D4
    [64], // E4
    [65], // F4
    [67], // G4
    [69], // A4
    [71], // B4

    [60], // C4
    [62], // D4
    [64], // E4
    [65], // F4
    [67], // G4
    [69], // A4
    [71], // B4
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[60]],
      totalQuestions: 1,
    );
  }
}