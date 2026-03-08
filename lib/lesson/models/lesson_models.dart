import 'lesson_behavior_models.dart';
import 'lesson_hint_models.dart';
import 'lesson_judge_models.dart';

enum Phase {
  review,
  learn,
  practice,
  check,
}

enum PromptType {
  solfege, // 도
  letter,  // C
  staff,   // 오선지
  keyboard, // 건반 표시
}

class Lesson {
  final String lessonId;
  final String title;
  final int level;
  final List<int> notePool;
  final List<int> newNotes;
  final List<Task> tasks;

  const Lesson({
    required this.lessonId,
    required this.title,
    required this.level,
    required this.notePool,
    required this.newNotes,
    required this.tasks,
  });
}

class Task {
  final String taskId;
  final Phase phase;
  final TaskBehavior behavior;
  final List<StepItem> steps;

  const Task({
    required this.taskId,
    required this.phase,
    required this.behavior,
    required this.steps,
  });
}

class StepItem {
  final String stepId;

  /// 단음이면 길이 1, 화음/시퀀스 확장 가능
  final List<int> targetNotes;

  /// 문제 표시 방식
  final PromptType promptType;

  /// 새 음 소개 단계에서
  /// 도 / C / 오선지 / 건반을 함께 보여줄 때 사용
  final bool showAllPromptsFirst;

  /// 확장용
  final JudgeSpec? judge;
  final HintSpec? hint;

  const StepItem({
    required this.stepId,
    required this.targetNotes,
    required this.promptType,
    this.showAllPromptsFirst = false,
    this.judge,
    this.hint,
  });

  int get primaryMidi => targetNotes.first;
}