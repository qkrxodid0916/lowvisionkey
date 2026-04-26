import 'abstract_lesson_runner.dart';
import '../curriculum/curriculum_models.dart';
import '../../ble/services/ble_esp32_manager.dart';

class BleLessonRunner extends AbstractLessonRunner {
  BleLessonRunner(
      CurriculumLesson lesson, {
        BleEsp32Manager? ble,
      })  : _ble = ble ?? BleEsp32Manager.I,
        super(
        lesson,
        onGuideNotesChanged: (notes) async {
          // 자동 가이드 전송 안 함
        },
      );

  final BleEsp32Manager _ble;

  Future<void> resetGuide() async {
    await _ble.sendReset();
  }

  Future<void> testGuide() async {
    await _ble.sendTest();
  }

  @override
  void onCorrect(List<int> expected) {
    // 정답 LED 피드백 없음
  }

  @override
  void onWrong(List<int> expected) {
    // LED 오답 처리는 LessonScreen에서 직접 처리
  }

  @override
  void dispose() {
    super.dispose();
  }
}