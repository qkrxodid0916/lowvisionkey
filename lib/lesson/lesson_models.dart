enum Phase { warmup, practice, apply, check }
enum TaskType { findPress, followSequence, tapOnBeat, recall }
enum JudgeMode { press, sequence, beat, recall }

class LessonSettings {
  final int newNotesMax;          // 추천 1
  final double lengthMultiplier;  // 0.5 / 1.0 / 1.5
  final bool enableRhythm;

  const LessonSettings({
    this.newNotesMax = 1,
    this.lengthMultiplier = 1.0,
    this.enableRhythm = true,
  });
}

class Lesson {
  final String lessonId;
  final int level;
  final LessonSettings settings;
  final List<int> notePool;   // MIDI notes
  final List<int> newNotes;   // MIDI notes
  final List<Task> tasks;

  Lesson({
    required this.lessonId,
    required this.level,
    required this.settings,
    required this.notePool,
    required this.newNotes,
    required this.tasks,
  });
}

class Task {
  final String taskId;
  final Phase phase;
  final TaskType type;
  final Map<String, dynamic> rules;
  final List<StepItem> steps;

  Task({
    required this.taskId,
    required this.phase,
    required this.type,
    required this.rules,
    required this.steps,
  });
}

class StepItem {
  final String stepId;
  final List<int> targetNotes; // 화음 대비 배열
  final Hint hint;
  final JudgeSpec judge;

  StepItem({
    required this.stepId,
    required this.targetNotes,
    required this.hint,
    required this.judge,
  });
}

enum LedMode { hold, blinkOnce, off }

class Hint {
  final LedMode ledMode;      // 지금은 UI 하이라이트용으로만 사용
  final int? ledBlinkMs;      // blinkOnce일 때
  final String? audioPrompt;  // TTS용(지금은 표시만 해도 됨)

  Hint({required this.ledMode, this.ledBlinkMs, this.audioPrompt});
}

class JudgeSpec {
  final JudgeMode mode;
  final int? windowMs; // beat/recall 타이밍 창
  final int attempts;

  JudgeSpec({
    required this.mode,
    this.windowMs,
    this.attempts = 2,
  });
}