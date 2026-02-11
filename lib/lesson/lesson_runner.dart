import 'package:flutter/foundation.dart';
import 'lesson_models.dart';
import 'progress_models.dart';
import '../utils/tts_service.dart';

class LessonRunner {
  final ProgressState progress;

  LessonRunner({required this.progress});

  Lesson? _lesson;
  int _taskIndex = 0;
  int _stepIndex = 0;

  final ValueNotifier<StepItem?> currentStep = ValueNotifier<StepItem?>(null);
  final ValueNotifier<bool> isCompleted = ValueNotifier<bool>(false);

  /// ✅ 마지막 입력이 정답인지
  final ValueNotifier<bool?> lastHit = ValueNotifier<bool?>(null);

  /// ✅ "현재 step"에서 틀린 횟수
  final ValueNotifier<int> wrongCountOnStep = ValueNotifier<int>(0);

  /// ✅ TTS
  final _tts = TtsService.I;

  Lesson? get lesson => _lesson;

  /// UI에서 단계 구분용(ORDERED / RANDOM)
  String? get currentTaskId {
    final l = _lesson;
    if (l == null) return null;
    if (_taskIndex < 0 || _taskIndex >= l.tasks.length) return null;
    return l.tasks[_taskIndex].taskId;
  }

  void start(Lesson lesson) {
    _lesson = lesson;
    _taskIndex = 0;
    _stepIndex = 0;
    isCompleted.value = false;

    lastHit.value = null;
    wrongCountOnStep.value = 0;

    _emitCurrent();
  }

  void onNoteOn(int midi) {
    final step = currentStep.value;
    if (step == null) return;

    final target = step.targetNotes.first;
    final ok = (midi == target);

    if (ok) {
      lastHit.value = true;
      progress.of(target).success++;
      _tts.speak("정답");
      _advance();
    } else {
      lastHit.value = false;
      wrongCountOnStep.value = wrongCountOnStep.value + 1;
      progress.of(target).fail++;

      // ✅ 1회: "다시" / 2회 이상: "정답은 ~"
      if (wrongCountOnStep.value >= 2) {
        _tts.speak("정답은 ${_midiToKo(target)}");
        // 실패 표시 없이 그대로 유지(재시도)
      } else {
        _tts.speak("다시");
      }
    }
  }

  void onNoteOff(int midi) {
    // MVP에서는 비워둬도 됨
  }

  /// ✅ 기본 하이라이트(현재 목표)
  Set<int> highlightedNotes() {
    final step = currentStep.value;
    if (step == null) return {};
    return step.targetNotes.toSet();
  }

  void _advance() {
    final l = _lesson;
    if (l == null) return;

    final task = l.tasks[_taskIndex];
    _stepIndex++;

    if (_stepIndex >= task.steps.length) {
      _taskIndex++;
      _stepIndex = 0;

      if (_taskIndex >= l.tasks.length) {
        isCompleted.value = true;
        currentStep.value = null;
        progress.lastNewNotes = List<int>.from(l.newNotes);
        _tts.speak("레슨 완료");
        return;
      }
    }

    // ✅ 다음 step으로 넘어가면 step 오답 카운트 리셋
    wrongCountOnStep.value = 0;

    _emitCurrent();
  }

  void _emitCurrent() {
    final l = _lesson;
    if (l == null) {
      currentStep.value = null;
      return;
    }

    final step = l.tasks[_taskIndex].steps[_stepIndex];
    currentStep.value = step;

    // ✅ 새 step 목표 안내 (현재는 단음 기준)
    final target = step.targetNotes.first;
    _tts.speak(_midiToKo(target));
  }

  String _midiToKo(int midi) {
    const names = ["도", "도#", "레", "레#", "미", "파", "파#", "솔", "솔#", "라", "라#", "시"];
    return names[midi % 12];
  }

  void dispose() {
    currentStep.dispose();
    isCompleted.dispose();
    lastHit.dispose();
    wrongCountOnStep.dispose();
  }
}
