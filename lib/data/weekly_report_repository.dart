import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson/weekly_report.dart';

class WeeklyReportRepository {
  WeeklyReportRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) =>
      _db.collection('lesson_results').doc(uid).collection('sessions');

  DocumentReference<Map<String, dynamic>> _weeklyDoc(String uid, String reportId) =>
      _db.collection('lesson_reports').doc(uid).collection('weekly').doc(reportId);

  /// ✅ 최근 7일 세션을 합산해서 주간 리포트 1개 생성/업데이트
  /// reportId 예: 2026-02-03_2026-02-09
  Future<String> generateLast7DaysReport({required String uid}) async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 6)); // 오늘 포함 7일

    // finishedAt: Timestamp 기준 쿼리
    final snap = await _sessionsRef(uid)
        .where('finishedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('finishedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    int sessions = snap.docs.length;

    int correct = 0;
    int wrong = 0;
    int total = 0;

    final newNotesSet = <int>{};
    final wrongByMidi = <int, int>{};

    for (final d in snap.docs) {
      final data = d.data();

      correct += (data['correct'] as num?)?.toInt() ?? 0;
      wrong += (data['wrong'] as num?)?.toInt() ?? 0;
      total += (data['total'] as num?)?.toInt() ?? 0;

      final newNotes = (data['newNotes'] as List?) ?? const [];
      for (final n in newNotes) {
        final v = (n as num).toInt();
        newNotesSet.add(v);
      }

      final wb = Map<String, dynamic>.from(data['wrongByMidi'] ?? const {});
      wb.forEach((k, v) {
        final midi = int.tryParse(k);
        if (midi == null) return;
        final add = (v as num).toInt();
        wrongByMidi[midi] = (wrongByMidi[midi] ?? 0) + add;
      });
    }

    final acc = total == 0 ? 0.0 : (correct / total);

    // 오답 상위 8개
    final topWrong = wrongByMidi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWrongMidis = topWrong.take(8).map((e) => e.key).toList();

    final report = WeeklyReport(
      rangeStart: start,
      rangeEnd: end,
      sessions: sessions,
      total: total,
      correct: correct,
      wrong: wrong,
      accuracy: acc,
      newNotesUnique: newNotesSet.toList()..sort(),
      wrongByMidiSum: wrongByMidi,
      topWrongMidis: topWrongMidis,
    );

    final reportId =
        "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}"
        "_"
        "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    await _weeklyDoc(uid, reportId).set({
      ...report.toJson(),
      "generatedAt": FieldValue.serverTimestamp(),
      "schemaVersion": 1,
    }, SetOptions(merge: true));

    return reportId;
  }
}
