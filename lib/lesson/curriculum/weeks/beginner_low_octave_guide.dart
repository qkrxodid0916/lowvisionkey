import '../curriculum_models.dart';

class BeginnerLowOctaveGuide {
  static Stage stage() {
    return Stage(
      id: 'beginner_low_octave_guide',
      title: '낮은 옥타브 가이드',
      description: '4주차를 시작하기 전에 C3~B3 위치와 소리를 먼저 익혀요.',
      lessons: [
        _guideLesson(),
      ],
    );
  }

  static CurriculumLesson _guideLesson() {
    return CurriculumLesson(
      id: 'beginner_low_octave_guide_lesson',
      title: '낮은 옥타브 입문',
      mode: LessonInputMode.both,
      octaveGuide: 1,
      plan: _dummyPlan(),
      passRule: const PassRule(minAccuracy: 0.9),
      steps: [
        LessonPlanStep(
          id: 'low_octave_repeat',
          title: '듣고 따라 치기',
          description: '소리와 LED를 보고 낮은 옥타브 C3~B3를 3번 반복해서 따라 쳐요.',
          plan: const LessonPlan(
            type: LessonPlanType.singleNotes,
            sequences: _lowOctaveRepeat3,
            totalQuestions: 21,
            shuffleQuestions: false,
          ),
          passRule: const PassRule(minAccuracy: 0.9),
          guideEnabled: true,
        ),
      ],
    );
  }

  static const List<List<int>> _lowOctaveRepeat3 = [
    [48], // C3
    [50], // D3
    [52], // E3
    [53], // F3
    [55], // G3
    [57], // A3
    [59], // B3

    [48], // C3
    [50], // D3
    [52], // E3
    [53], // F3
    [55], // G3
    [57], // A3
    [59], // B3

    [48], // C3
    [50], // D3
    [52], // E3
    [53], // F3
    [55], // G3
    [57], // A3
    [59], // B3
  ];

  static LessonPlan _dummyPlan() {
    return const LessonPlan(
      type: LessonPlanType.singleNotes,
      sequences: [[48]],
      totalQuestions: 1,
    );
  }
}