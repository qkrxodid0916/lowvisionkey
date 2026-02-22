import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  DailyReport({
    required this.dateId, // yyyy-MM-dd
    required this.total,
    required this.correct,
    required this.wrong,
    required this.accuracy,
    required this.learningTimeSec, // ✅ 일일: 한 줄로 표시
    required this.topWrongMidis,   // ✅ TOP3
    required this.coachLine,       // ✅ 1줄 코칭
  });

  final String dateId;

  final int total;
  final int correct;
  final int wrong;
  final double accuracy;

  final int learningTimeSec;
  final List<int> topWrongMidis;
  final String coachLine;

  Map<String, dynamic> toJson() => {
    'dateId': dateId,
    'total': total,
    'correct': correct,
    'wrong': wrong,
    'accuracy': accuracy,
    'learningTimeSec': learningTimeSec,
    'topWrongMidis': topWrongMidis,
    'coachLine': coachLine,
  };
}