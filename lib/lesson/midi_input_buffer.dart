import 'dart:async';

class MidiInputBuffer {
  MidiInputBuffer({
    required this.onChordReady,
    this.chordWindow = const Duration(milliseconds: 100),
  });

  /// 화음 완성되면 호출됨
  final void Function(List<int> notes) onChordReady;

  /// 화음 묶는 시간
  final Duration chordWindow;

  final Set<int> _pendingNotes = <int>{};
  Timer? _flushTimer;

  /// 노트 추가 (note on 들어올 때 호출)
  void addNote(int midi) {
    _pendingNotes.add(midi);

    // 기존 타이머 취소하고 다시 시작
    _flushTimer?.cancel();
    _flushTimer = Timer(chordWindow, _flush);
  }

  /// 일정 시간 지나면 화음으로 확정
  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_pendingNotes.isEmpty) return;

    final played = _pendingNotes.toList()..sort();
    _pendingNotes.clear();

    onChordReady(played);
  }

  /// 문제 바뀔 때 호출 (🔥 중요)
  void reset() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingNotes.clear();
  }

  void dispose() {
    reset();
  }
}