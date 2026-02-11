import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReport {
  final DateTime rangeStart;
  final DateTime rangeEnd;

  final int sessions;
  final int total;
  final int correct;
  final int wrong;
  final double accuracy;

  final List<int> newNotesUnique;         // 이번 주 새로 등장한 음(중복 제거)
  final Map<int, int> wrongByMidiSum;     // midi별 오답 합산
  final List<int> topWrongMidis;          // 오답 상위 midi(최대 8)

  WeeklyReport({
    required this.rangeStart,
    required this.rangeEnd,
    required this.sessions,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.accuracy,
    required this.newNotesUnique,
    required this.wrongByMidiSum,
    required this.topWrongMidis,
  });

  Map<String, dynamic> toJson() => {
    "rangeStart": Timestamp.fromDate(rangeStart),
    "rangeEnd": Timestamp.fromDate(rangeEnd),

    "sessions": sessions,
    "total": total,
    "correct": correct,
    "wrong": wrong,
    "accuracy": accuracy,

    "newNotesUnique": newNotesUnique,
    "wrongByMidiSum": wrongByMidiSum.map((k, v) => MapEntry(k.toString(), v)),
    "topWrongMidis": topWrongMidis,
  };
}
