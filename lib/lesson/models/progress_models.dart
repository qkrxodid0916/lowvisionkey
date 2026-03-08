class NoteStats {
  int success;
  int fail;

  NoteStats({this.success = 0, this.fail = 0});

  int get total => success + fail;

  double get accuracy {
    final t = total;
    if (t == 0) return 0.0;
    return success / t;
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'fail': fail,
  };

  factory NoteStats.fromJson(Map<String, dynamic> json) {
    return NoteStats(
      success: (json['success'] ?? 0) as int,
      fail: (json['fail'] ?? 0) as int,
    );
  }
}

class ProgressState {
  /// ✅ 레슨에서 사용할 옥타브 인덱스
  /// 0 = C4~B4, +1 = C5~B5, -1 = C3~B3 ...
  int octaveIndex;

  /// midi -> 통계
  final Map<int, NoteStats> stats;

  /// 최근 레슨에서 "등장(학습)한 음" (현재는 레슨 플랜 기준으로 채움)
  List<int> lastNewNotes;

  /// 최근 레슨에서 "틀린 음" (화음이면 구성음 전체)
  List<int> lastFailedNotes;

  ProgressState({
    this.octaveIndex = 0,
    Map<int, NoteStats>? stats,
    List<int>? lastNewNotes,
    List<int>? lastFailedNotes,
  })  : stats = stats ?? <int, NoteStats>{},
        lastNewNotes = lastNewNotes ?? <int>[],
        lastFailedNotes = lastFailedNotes ?? <int>[];

  NoteStats of(int midi) => stats.putIfAbsent(midi, () => NoteStats());

  /// ✅ 최근 실패 노트 설정(중복 제거 + 정렬)
  void setLastFailed(Iterable<int> midis) {
    final s = midis.toSet().toList()..sort();
    lastFailedNotes = s;
  }

  /// ✅ 최근 새 노트 설정(중복 제거 + 정렬)
  void setLastNew(Iterable<int> midis) {
    final s = midis.toSet().toList()..sort();
    lastNewNotes = s;
  }

  /// ✅ 약한 노트 TOP N (정확도 낮은 순, 최소 시도횟수 적용)
  List<int> weakestNotes({
    int topN = 5,
    int minTrials = 3,
  }) {
    final items = stats.entries
        .where((e) => e.value.total >= minTrials)
        .toList();

    items.sort((a, b) {
      final da = a.value.accuracy;
      final db = b.value.accuracy;
      final c = da.compareTo(db); // 낮을수록 먼저
      if (c != 0) return c;
      // 정확도 같으면 시도횟수 많은 걸 우선(더 신뢰 가능)
      return b.value.total.compareTo(a.value.total);
    });

    return items.take(topN).map((e) => e.key).toList();
  }

  /// ✅ 특정 풀(pool) 안에서만 약한 노트 뽑기
  List<int> weakestNotesInPool(
      List<int> pool, {
        int topN = 5,
        int minTrials = 3,
      }) {
    final poolSet = pool.toSet();
    final items = stats.entries
        .where((e) => poolSet.contains(e.key) && e.value.total >= minTrials)
        .toList();

    items.sort((a, b) {
      final c = a.value.accuracy.compareTo(b.value.accuracy);
      if (c != 0) return c;
      return b.value.total.compareTo(a.value.total);
    });

    return items.take(topN).map((e) => e.key).toList();
  }

  /// ✅ 가중치 맵 생성(개인화 랜덤 출제에 바로 사용)
  /// - 정확도가 낮을수록 weight가 커짐
  /// - 시도횟수 적으면 기본값에 가깝게(과적합 방지)
  Map<int, double> buildWeightsForPool(
      List<int> pool, {
        double base = 1.0,
        double boostMax = 2.5, // 최대 추가 가중치
        int minTrials = 3,
      }) {
    final weights = <int, double>{};

    for (final midi in pool) {
      final s = stats[midi];
      if (s == null || s.total < minTrials) {
        weights[midi] = base;
        continue;
      }

      // accuracy: 1.0이면 boost 0, 0.0이면 boostMax
      final boost = (1.0 - s.accuracy) * boostMax;
      weights[midi] = base + boost;
    }

    return weights;
  }

  Map<String, dynamic> toJson() {
    return {
      'octaveIndex': octaveIndex,
      'stats': {
        for (final e in stats.entries) e.key.toString(): e.value.toJson(),
      },
      'lastNewNotes': List<int>.from(lastNewNotes),
      'lastFailedNotes': List<int>.from(lastFailedNotes),
    };
  }

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    final rawStats = (json['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    final parsedStats = <int, NoteStats>{};
    for (final e in rawStats.entries) {
      final midi = int.tryParse(e.key);
      if (midi == null) continue;
      final val = (e.value as Map).cast<String, dynamic>();
      parsedStats[midi] = NoteStats.fromJson(val);
    }

    return ProgressState(
      octaveIndex: (json['octaveIndex'] ?? 0) as int,
      stats: parsedStats,
      lastNewNotes: ((json['lastNewNotes'] as List?) ?? const [])
          .map((e) => e as int)
          .toList(),
      lastFailedNotes: ((json['lastFailedNotes'] as List?) ?? const [])
          .map((e) => e as int)
          .toList(),
    );
  }
}