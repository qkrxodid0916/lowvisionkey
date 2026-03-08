import 'abstract_lesson_runner.dart';
import '../curriculum/curriculum_models.dart';

class AppLessonRunner extends AbstractLessonRunner {
  AppLessonRunner(CurriculumLesson lesson) : super(lesson);

  @override
  void onCorrect(List<int> expected) {
    // TODO: UI 이펙트, 사운드 등
  }

  @override
  void onWrong(List<int> expected) {
    // TODO: 오답 표시
  }
}