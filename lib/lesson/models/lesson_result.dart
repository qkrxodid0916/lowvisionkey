import 'package:cloud_firestore/cloud_firestore.dart';

class LessonResult {
  final DateTime startedAt;
  final DateTime finishedAt;

  final int total;
  final int correct;
  final int wrong;

  final double accuracy;

  final List<int> newNotes;
  final Map<int, int> wrongByMidi;

  LessonResult({
    required this.startedAt,
    required this.finishedAt,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.accuracy,
    required this.newNotes,
    required this.wrongByMidi,
  });

  /// ✅ Firestore 저장용
  Map<String, dynamic> toJson() => {
    "startedAt": Timestamp.fromDate(startedAt),
    "finishedAt": Timestamp.fromDate(finishedAt),
    "total": total,
    "correct": correct,
    "wrong": wrong,
    "accuracy": accuracy,
    "newNotes": newNotes,
    "wrongByMidi": wrongByMidi.map(
          (k, v) => MapEntry(k.toString(), v),
    ),
  };

  /// ✅ Firestore에서 다시 읽을 때 사용 (리포트 만들 때 필요)
  factory LessonResult.fromJson(Map<String, dynamic> json) {
    final startedTs = json["startedAt"] as Timestamp;
    final finishedTs = json["finishedAt"] as Timestamp;

    final wrongMapRaw =
    Map<String, dynamic>.from(json["wrongByMidi"] ?? {});

    final wrongByMidi = <int, int>{};
    wrongMapRaw.forEach((key, value) {
      final midi = int.tryParse(key);
      if (midi != null) {
        wrongByMidi[midi] = (value as num).toInt();
      }
    });

    return LessonResult(
      startedAt: startedTs.toDate(),
      finishedAt: finishedTs.toDate(),
      total: (json["total"] as num).toInt(),
      correct: (json["correct"] as num).toInt(),
      wrong: (json["wrong"] as num).toInt(),
      accuracy: (json["accuracy"] as num).toDouble(),
      newNotes:
      (json["newNotes"] as List).map((e) => (e as num).toInt()).toList(),
      wrongByMidi: wrongByMidi,
    );
  }
}
