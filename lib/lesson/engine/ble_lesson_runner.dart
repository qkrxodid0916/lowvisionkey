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
          final b = ble ?? BleEsp32Manager.I;

          // notes는 MIDI 번호(Set<int>)일 수 있음
          // ESP32가 MIDI -> LED 매핑 처리하므로 그대로 보냄
          await b.sendTarget(notes);
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
    // 필요하면 나중에 성공 피드백 명령 추가
    // 예: _ble.sendRaw('C:${expected.join(',')}');
  }

  @override
  void onWrong(List<int> expected) {
    // 필요하면 나중에 오답 피드백 명령 추가
    // 예: _ble.sendRaw('W:${expected.join(',')}');
  }

  @override
  void dispose() {
    super.dispose();
  }
}