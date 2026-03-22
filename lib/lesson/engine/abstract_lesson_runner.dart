import 'dart:math';
import 'package:flutter/foundation.dart';
import '../curriculum/curriculum_models.dart';
import '../models/lesson_result.dart';
import '../models/progress_models.dart';

abstract class AbstractLessonRunner {
  final CurriculumLesson lesson;
  final ProgressState progress = ProgressState();

  /// ✅ 기대값(문제)이 바뀔 때 외부로 알려주는 훅 (ESP32 LED 가이드용)
  final Future<void> Function(Set<int> notes)? onGuideNotesChanged;

  final Random _random = Random();
  late List<List<int>> _questionQueue;

  int _currentIndex = 0;
  int _correct = 0;
  int _wrong = 0;

  final Map<int, int> _wrongByMidi = {};
  DateTime? _startedAt;

  /// ✅ LessonScreen이 사용하는 상태들
  final ValueNotifier<List<int>?> currentExpected =
  ValueNotifier<List<int>?>(null);

  final ValueNotifier<bool?> lastHit =
  ValueNotifier<bool?>(null);

  final ValueNotifier<int> wrongCountOnStep =
  ValueNotifier<int>(0);

  final ValueNotifier<bool> isCompleted =
  ValueNotifier<bool>(false);

  AbstractLessonRunner(this.lesson, {this.onGuideNotesChanged});

  int get currentIndex => _currentIndex;
  int get totalQuestions => lesson.plan.totalQuestions;

  void start() {
    _startedAt = DateTime.now();

    _currentIndex = 0;
    _correct = 0;
    _wrong = 0;
    _wrongByMidi.clear();

    lastHit.value = null;
    wrongCountOnStep.value = 0;
    isCompleted.value = false;

    _questionQueue = _buildQuestionQueue();

    final first = _expectedNow();
    currentExpected.value = first;

    // ✅ 시작 시: 이번 레슨에서 등장하는 노트들 기록
    progress.lastNewNotes = _collectAllNotesInPlan();

    // ✅ 첫 문제 가이드 송신(없으면 빈 셋)
    onGuideNotesChanged?.call(first?.toSet() ?? <int>{});
  }

  List<List<int>> _buildQuestionQueue() {
    if (lesson.plan.sequences.isEmpty || lesson.plan.totalQuestions <= 0) {
      return <List<int>>[];
    }

    final source = lesson.plan.sequences;
    final total = lesson.plan.totalQuestions;
    final result = <List<int>>[];

    if (lesson.plan.shuffleQuestions) {
      for (int i = 0; i < total; i++) {
        final picked = source[_random.nextInt(source.length)];
        result.add(List<int>.from(picked));
      }
    } else {
      for (int i = 0; i < total; i++) {
        final picked = source[i % source.length];
        result.add(List<int>.from(picked));
      }
    }

    return result;
  }

  List<int>? _expectedNow() {
    if (_currentIndex >= _questionQueue.length) return null;
    return _questionQueue[_currentIndex];
  }

  /// 이번 레슨 플랜에 등장하는 모든 노트(중복 제거)
  List<int> _collectAllNotesInPlan() {
    final set = <int>{};
    for (final seq in lesson.plan.sequences) {
      set.addAll(seq);
    }
    final list = set.toList()..sort();
    return list;
  }

  Set<int> highlightedNotes() {
    final e = currentExpected.value;
    if (e == null) return <int>{};
    return e.toSet();
  }

  void onInput(List<int> playedNotes) {
    if (isCompleted.value) return;

    final expected = _expectedNow();
    if (expected == null) return;

    final ok = _compare(expected, playedNotes);

    if (ok) {
      _correct++;
      lastHit.value = true;
      wrongCountOnStep.value = 0;

      for (final m in expected) {
        progress.of(m).success++;
      }

      onCorrect(expected);

      _currentIndex++;

      if (_currentIndex >= _questionQueue.length) {
        currentExpected.value = null;
        isCompleted.value = true;
        onGuideNotesChanged?.call(<int>{});
      } else {
        final next = _expectedNow();
        currentExpected.value = next;
        onGuideNotesChanged?.call(next?.toSet() ?? <int>{});
      }
    } else {
      _wrong++;
      lastHit.value = false;
      wrongCountOnStep.value = wrongCountOnStep.value + 1;

      for (final m in expected) {
        progress.of(m).fail++;
      }

      progress.lastFailedNotes = expected.toSet().toList()..sort();

      final key = expected.isNotEmpty ? expected.first : -1;
      _wrongByMidi[key] = (_wrongByMidi[key] ?? 0) + 1;

      onWrong(expected);
    }
  }

  LessonResult finish() {
    final startedAt = _startedAt ?? DateTime.now();
    final finishedAt = DateTime.now();

    final total = _correct + _wrong;
    final double accuracy = total == 0 ? 0.0 : (_correct / total);

    return LessonResult(
      startedAt: startedAt,
      finishedAt: finishedAt,
      total: total,
      correct: _correct,
      wrong: _wrong,
      accuracy: accuracy,
      newNotes: List<int>.from(progress.lastNewNotes),
      wrongByMidi: Map<int, int>.from(_wrongByMidi),
    );
  }

  bool _compare(List<int> expected, List<int> played) {
    if (expected.length != played.length) return false;

    final e = [...expected]..sort();
    final p = [...played]..sort();

    for (int i = 0; i < e.length; i++) {
      if (e[i] != p[i]) return false;
    }
    return true;
  }

  void dispose() {
    currentExpected.dispose();
    lastHit.dispose();
    wrongCountOnStep.dispose();
    isCompleted.dispose();
  }

  void onCorrect(List<int> expected) {}
  void onWrong(List<int> expected) {}
}