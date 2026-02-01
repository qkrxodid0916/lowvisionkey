class NoteStats {
  int success = 0;
  int fail = 0;

  double get accuracy {
    final total = success + fail;
    if (total == 0) return 0;
    return success / total;
  }
}

class ProgressState {
  /// ✅ 레슨에서 사용할 옥타브 인덱스
  /// 0 = C4~B4, +1 = C5~B5, -1 = C3~B3 ...
  int octaveIndex = 0;

  final Map<int, NoteStats> stats = {};

  List<int> lastNewNotes = [];
  List<int> lastFailedNotes = [];

  NoteStats of(int midi) => stats.putIfAbsent(midi, () => NoteStats());
}