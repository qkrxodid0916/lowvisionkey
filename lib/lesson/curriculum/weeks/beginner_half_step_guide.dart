import '../curriculum_models.dart';

class BeginnerHalfStepGuide {
  static Stage stage() {
    return Stage(
      id: 'beginner_half_step_guide',
      title: '반음 가이드',
      description: '가운데 옥타브의 검은건반 C#4~A#4 위치와 소리를 익혀요.',
      lessons: [
        _guideLesson(),
      ],
    );
  }

  static CurriculumLesson _guideLesson() {
    return CurriculumLesson(
      id: 'beginner_half_step_guide_lesson',
      title: '반음 듣고 따라 치기',
      mode: LessonInputMode.both,
      octaveGuide: 2,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.9),
      steps: [
        LessonPlanStep(
          id: 'half_step_repeat',
          title: '듣고 따라 치기',
          description: '소리와 LED를 보고 가운데 옥타브의 반음을 3번 반복해서 따라 쳐요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _halfStepRepeat3,
            totalQuestions: 15,
            shuffleQuestions: false,
          ),
          passRule: const PassRule(minAccuracy: 0.9),
          guideEnabled: true,
        ),
      ],
    );
  }

  static const List<List<int>> _halfStepRepeat3 = [
    [61], // C#4
    [63], // D#4
    [66], // F#4
    [68], // G#4
    [70], // A#4

    [61], // C#4
    [63], // D#4
    [66], // F#4
    [68], // G#4
    [70], // A#4

    [61], // C#4
    [63], // D#4
    [66], // F#4
    [68], // G#4
    [70], // A#4
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[61]],
      totalQuestions: 1,
    );
  }
}