import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReport {
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
    required this.learningTimeSec,
    required this.dailyAccuracy, // ✅ 추가
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int sessions;

  final int total;
  final int correct;
  final int wrong;
  final double accuracy;

  final List<int> newNotesUnique;
  final Map<int, int> wrongByMidiSum;
  final List<int> topWrongMidis;

  final int learningTimeSec;

  /// ✅ 7개(0~1): rangeStart~rangeEnd 일별 정확도
  final List<double> dailyAccuracy;

  Map<String, dynamic> toJson() => {
    'rangeStart': Timestamp.fromDate(rangeStart),
    'rangeEnd': Timestamp.fromDate(rangeEnd),
    'sessions': sessions,
    'total': total,
    'correct': correct,
    'wrong': wrong,
    'accuracy': accuracy,
    'newNotesUnique': newNotesUnique,
    'wrongByMidiSum': wrongByMidiSum.map((k, v) => MapEntry(k.toString(), v)),
    'topWrongMidis': topWrongMidis,
    'learningTimeSec': learningTimeSec,
    'dailyAccuracy': dailyAccuracy, // ✅ 추가
  };
}