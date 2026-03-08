import 'dart:async';
import 'abstract_lesson_runner.dart';
import '../curriculum/curriculum_models.dart';
import '../../ble/services/ble_midi_manager.dart';

class BleLessonRunner extends AbstractLessonRunner {
  BleLessonRunner(
      CurriculumLesson lesson, {
        BleMidiManager? ble,
        Duration chordWindow = const Duration(milliseconds: 150),
      })  : _ble = ble ?? BleMidiManager.I,
        _chordWindow = chordWindow,
        super(
        lesson,
        // ✅ 문제가 바뀔 때: ESP32로 가이드 노트 송신(guideChannel)
        onGuideNotesChanged: (notes) async {
          final b = ble ?? BleMidiManager.I;

          // 1) 기존 가이드 끄기(안정)
          await b.sendAllNotesOff(
            channel: BleMidiManager.guideChannel,
            fallbackSweep: true,
          );

          // 2) 새 목표 켜기
          for (final n in notes) {
            await b.sendNoteOn(
              n,
              velocity: 100,
              channel: BleMidiManager.guideChannel,
            );
          }
        },
      );

  final BleMidiManager _ble;

  // ---- 입력 버퍼(화음 묶기) ----
  final Duration _chordWindow;
  final Set<int> _pendingNotes = <int>{};
  Timer? _flushTimer;

  StreamSubscription<int>? _noteOnSub;

  /// ✅ ESP32가 키보드 입력을 BLE-MIDI로 notify 해주는 구조 대비
  /// - noteOn을 일정 시간 묶어서 onInput([..]) 호출
  Future<void> startBleInput() async {
    _ble.listenChannel = BleMidiManager.inputChannel;
    await _ble.startListening();

    _noteOnSub ??= _ble.noteOnStream.listen(_onIncomingNoteOn);
  }

  Future<void> stopBleInput() async {
    await _noteOnSub?.cancel();
    _noteOnSub = null;

    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingNotes.clear();

    await _ble.stopListening();
  }

  void _onIncomingNoteOn(int midi) {
    // 이미 완료면 입력 무시(엔진에서도 막지만 여기서도 한번 더)
    if (isCompleted.value) return;

    _pendingNotes.add(midi);

    // 첫 노트가 들어온 순간 타이머 시작/리셋
    _flushTimer?.cancel();
    _flushTimer = Timer(_chordWindow, _flushPendingNotes);
  }

  void _flushPendingNotes() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_pendingNotes.isEmpty) return;

    // Set → List (정렬은 AbstractLessonRunner가 내부에서 하니 굳이 안 해도 되지만,
    // 디버그/재현성을 위해 정렬해두면 좋음)
    final played = _pendingNotes.toList()..sort();
    _pendingNotes.clear();

    // ✅ 여기서 한 번에 판정
    onInput(played);
  }

  @override
  void onCorrect(List<int> expected) {
    // TODO: 성공 패턴 필요하면 CC로 추가 가능
  }

  @override
  void onWrong(List<int> expected) {
    // TODO: 오답 패턴 필요하면 CC로 추가 가능
  }

  @override
  void dispose() {
    // stop은 Future라 dispose에서 await 못 하니까 fire-and-forget로 처리
    // ignore: discarded_futures
    stopBleInput();
    super.dispose();
  }
}