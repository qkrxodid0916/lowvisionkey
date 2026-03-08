import 'package:flutter/foundation.dart';
import '../curriculum/curriculum_models.dart';
import '../models/lesson_result.dart';
import '../models/progress_models.dart';

abstract class AbstractLessonRunner {
  final CurriculumLesson lesson;
  final ProgressState progress = ProgressState();

  /// ✅ 기대값(문제)이 바뀔 때 외부로 알려주는 훅 (ESP32 LED 가이드용)
  final Future<void> Function(Set<int> notes)? onGuideNotesChanged;

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

    final first = _expectedNow();
    currentExpected.value = first;

    // ✅ 시작 시: 이번 레슨에서 등장하는 노트들 기록(Plan 수정 없이 임시로)
    progress.lastNewNotes = _collectAllNotesInPlan();

    // ✅ 첫 문제 가이드 송신(없으면 빈 셋)
    onGuideNotesChanged?.call(first?.toSet() ?? <int>{});
  }

  List<int>? _expectedNow() {
    if (_currentIndex >= lesson.plan.totalQuestions) return null;
    return lesson.plan.sequences[_currentIndex % lesson.plan.sequences.length];
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

      // ✅ Progress 누적(정답) - 단음/화음 모두 처리
      for (final m in expected) {
        progress.of(m).success++;
      }

      onCorrect(expected);

      _currentIndex++;

      if (_currentIndex >= lesson.plan.totalQuestions) {
        currentExpected.value = null;
        isCompleted.value = true;

        // ✅ 완료 시 가이드 끄기
        onGuideNotesChanged?.call(<int>{});
      } else {
        final next = _expectedNow();
        currentExpected.value = next;

        // ✅ 다음 문제 가이드 송신
        onGuideNotesChanged?.call(next?.toSet() ?? <int>{});
      }
    } else {
      _wrong++;
      lastHit.value = false;
      wrongCountOnStep.value = wrongCountOnStep.value + 1;

      // ✅ Progress 누적(오답) - 단음/화음 모두 처리
      for (final m in expected) {
        progress.of(m).fail++;
      }

      // ✅ 최근 실패 노트(화음이면 화음 구성음 전체)
      // (중복 제거 + 정렬해서 UI/리포트에서 쓰기 좋게)
      progress.lastFailedNotes = expected.toSet().toList()..sort();

      // ✅ 리포트용 wrongByMidi 집계(기존 로직 유지: 대표키는 첫 음)
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