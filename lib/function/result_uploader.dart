import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../lesson/models/lesson_result.dart';
import '../report/repositories/report_repository.dart';

class ResultUploader {
  ResultUploader._();
  static final ResultUploader I = ResultUploader._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) =>
      _db.collection('lesson_results').doc(uid).collection('sessions');

  Future<void> upload(LessonResult result) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('로그인이 필요합니다.');
    }

    // ✅ 학습시간(초) - 리포트에서 바로 사용
    final durationSec = result.finishedAt.difference(result.startedAt).inSeconds;

    final data = result.toJson()
      ..addAll({
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
        "durationSec": durationSec,
      });

    // ✅ 1) 세션 저장
    await _sessionsRef(uid).add(data);

    // ✅ 2) 리포트 생성/갱신
    final repo = ReportRepository();
    await repo.generateDailyAndWeeklyOncePerDay(uid: uid);
  }
}