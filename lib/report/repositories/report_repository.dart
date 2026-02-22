import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_report.dart';
import '../models/weekly_report.dart';

class ReportRepository {
  ReportRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) =>
      _db.collection('lesson_results').doc(uid).collection('sessions');

  DocumentReference<Map<String, dynamic>> _weeklyDoc(String uid, String reportId) =>
      _db.collection('lesson_reports').doc(uid).collection('weekly').doc(reportId);

  DocumentReference<Map<String, dynamic>> _dailyDoc(String uid, String dateId) =>
      _db.collection('lesson_reports').doc(uid).collection('daily').doc(dateId);

  // ✅ 자동 생성 상태(하루 1회 실행 기록)
  DocumentReference<Map<String, dynamic>> _autoGenStateDoc(String uid) =>
      _db.collection('lesson_reports').doc(uid).collection('meta').doc('autoGen');

  String _yyyyMmDd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  int _readDurationSec(Map<String, dynamic> data) {
    final v = data['durationSec'];
    if (v is num) return v.toInt();

    final ms = data['durationMs'];
    if (ms is num) return (ms / 1000).round();

    return 0;
  }

  /// ✅ 하루 1번만 일일+주간 리포트 생성/갱신
  /// - ResultUploader에서 매 세션 업로드 후 호출해도, 실제 집계는 하루 1회만 수행됨
  /// - 트랜잭션으로 동시 호출 중복 실행 방지
  Future<void> generateDailyAndWeeklyOncePerDay({required String uid}) async {
    final todayId = _yyyyMmDd(DateTime.now());

    final shouldRun = await _db.runTransaction<bool>((tx) async {
      final ref = _autoGenStateDoc(uid);
      final snap = await tx.get(ref);

      final last = snap.data()?['lastGeneratedDateId'] as String?;
      if (last == todayId) return false;

      tx.set(ref, {
        'lastGeneratedDateId': todayId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });

    if (!shouldRun) return;

    await generateDailyLessonReport(uid: uid);
    await generateLast7DaysLessonWeeklyReport(uid: uid);
  }

  /// ✅ 일일 리포트(간결)
  /// - 정확도(핵심)
  /// - 학습 시간(한 줄)
  /// - 오답 TOP3
  /// - 코칭 1줄
  Future<String> generateDailyLessonReport({
    required String uid,
    DateTime? day,
  }) async {
    final now = day ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snap = await _sessionsRef(uid)
        .where('finishedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('finishedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    int correct = 0, wrong = 0, total = 0;
    int learningTimeSec = 0;

    final wrongByMidi = <int, int>{};

    for (final d in snap.docs) {
      final data = d.data();

      correct += (data['correct'] as num?)?.toInt() ?? 0;
      wrong += (data['wrong'] as num?)?.toInt() ?? 0;
      total += (data['total'] as num?)?.toInt() ?? 0;

      learningTimeSec += _readDurationSec(data);

      final wb = Map<String, dynamic>.from(data['wrongByMidi'] ?? const {});
      wb.forEach((k, v) {
        final midi = int.tryParse(k);
        if (midi == null) return;
        final add = (v as num).toInt();
        wrongByMidi[midi] = (wrongByMidi[midi] ?? 0) + add;
      });
    }

    final acc = total == 0 ? 0.0 : (correct / total);

    final topWrong = wrongByMidi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topWrong.take(3).map((e) => e.key).toList();

    final dateId = _yyyyMmDd(now);

    final report = DailyReport(
      dateId: dateId,
      total: total,
      correct: correct,
      wrong: wrong,
      accuracy: acc,
      learningTimeSec: learningTimeSec,
      topWrongMidis: top3,
      coachLine: _makeDailyCoachLine(
        accuracy: acc,
        learningTimeSec: learningTimeSec,
        topWrongMidis: top3,
      ),
    );

    await _dailyDoc(uid, dateId).set({
      ...report.toJson(),
      "generatedAt": FieldValue.serverTimestamp(),
      "schemaVersion": 1,
    }, SetOptions(merge: true));

    return dateId;
  }

  /// ✅ (변경) 이번 주(월~일 고정) 주간 리포트 생성/갱신
  /// - 기존: 최근 7일(슬라이딩)
  /// - 변경: 월~일(고정 주차)
  ///
  /// docId 예: 2026-02-10_2026-02-16
  Future<String> generateLast7DaysLessonWeeklyReport({required String uid}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ✅ 이번 주 월요일 00:00:00
    final start = today.subtract(Duration(days: today.weekday - DateTime.monday));

    // ✅ 이번 주 일요일 23:59:59
    final end = DateTime(start.year, start.month, start.day, 23, 59, 59)
        .add(const Duration(days: 6));

    final snap = await _sessionsRef(uid)
        .where('finishedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('finishedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final sessions = snap.docs.length;

    int correct = 0, wrong = 0, total = 0;
    int learningTimeSec = 0;

    final newNotesSet = <int>{};
    final wrongByMidi = <int, int>{};

    // ✅ 그래프용(월~일 7칸)
    final dayTotal = List<int>.filled(7, 0);
    final dayCorrect = List<int>.filled(7, 0);
    final startDay = DateTime(start.year, start.month, start.day);

    for (final doc in snap.docs) {
      final data = doc.data();

      final c = (data['correct'] as num?)?.toInt() ?? 0;
      final w = (data['wrong'] as num?)?.toInt() ?? 0;
      final t = (data['total'] as num?)?.toInt() ?? 0;

      correct += c;
      wrong += w;
      total += t;

      // ✅ 학습 시간(초): durationSec/durationMs 없으면 0
      learningTimeSec += _readDurationSec(data);

      // ✅ 일별 버킷: finishedAt 기준 (월=0 ... 일=6)
      final finishedAt = (data['finishedAt'] as Timestamp?)?.toDate();
      if (finishedAt != null) {
        final fDay = DateTime(finishedAt.year, finishedAt.month, finishedAt.day);
        final idx = fDay.difference(startDay).inDays;
        if (idx >= 0 && idx < 7) {
          dayTotal[idx] += t;
          dayCorrect[idx] += c;
        }
      }

      // newNotes 합치기
      final newNotes = (data['newNotes'] as List?) ?? const [];
      for (final n in newNotes) {
        newNotesSet.add((n as num).toInt());
      }

      // wrongByMidi 합치기
      final wb = Map<String, dynamic>.from(data['wrongByMidi'] ?? const {});
      wb.forEach((k, v) {
        final midi = int.tryParse(k);
        if (midi == null) return;
        final add = (v as num).toInt();
        wrongByMidi[midi] = (wrongByMidi[midi] ?? 0) + add;
      });
    }

    final acc = total == 0 ? 0.0 : (correct / total);

    // ✅ 일별 정확도 7개 (0~1) : 월~일 순서
    final dailyAccuracy = List<double>.generate(7, (i) {
      final dt = dayTotal[i];
      if (dt == 0) return 0.0;
      return dayCorrect[i] / dt;
    });

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
      learningTimeSec: learningTimeSec,
      dailyAccuracy: dailyAccuracy,
    );

    final reportId = "${_yyyyMmDd(start)}_${_yyyyMmDd(end)}";

    await _weeklyDoc(uid, reportId).set({
      ...report.toJson(),

      // ✅ 목록/정렬용 (ReportScreen이 createdAt 정렬을 씀)
      "createdAt": FieldValue.serverTimestamp(),

      // ✅ 생성 시각
      "generatedAt": FieldValue.serverTimestamp(),

      // ✅ ReportScreen에서 title 있으면 그걸 먼저 보여줌
      "title": "${_yyyyMmDd(start)} ~ ${_yyyyMmDd(end)}",

      "schemaVersion": 4,
    }, SetOptions(merge: true));

    return reportId;
  }

  String _makeDailyCoachLine({
    required double accuracy,
    required int learningTimeSec,
    required List<int> topWrongMidis,
  }) {
    // “정말 한 줄” 유지
    if (learningTimeSec > 0 && learningTimeSec < 180) {
      return "오늘은 워밍업 정도였어요. 3분만 더 해볼까요?";
    }

    final top = topWrongMidis.isNotEmpty ? topWrongMidis.first : null;

    if (accuracy >= 0.85) return "페이스 좋아요. 내일은 난이도를 살짝 올려도 돼요.";
    if (accuracy >= 0.70) {
      return top != null ? "다음엔 $top 음을 짧게 복습해봐요." : "다음엔 어려운 음을 짧게 복습해봐요.";
    }
    return top != null ? "오늘은 $top 음이 어려웠어요. 2분만 집중 복습!" : "오늘은 기본기를 다졌어요. 내일 5분만 더!";
  }
}