import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson/models/lesson_result.dart';

class LessonResultsRepository {
  LessonResultsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) =>
      _db.collection('lesson_results').doc(uid).collection('sessions');

  Future<String> saveLessonResult({
    required String uid,
    required LessonResult result,
  }) async {
    final doc = _sessionsRef(uid).doc();

    await doc.set({
      ...result.toJson(),
      "createdAt": FieldValue.serverTimestamp(),
      "schemaVersion": 1,
    });

    return doc.id;
  }

  /// ✅ 최근 세션 N개 가져오기 (streak 계산용)
  Future<List<LessonResult>> fetchRecentResults({
    required String uid,
    int limit = 60,
  }) async {
    final snap = await _sessionsRef(uid)
        .orderBy("finishedAt", descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => LessonResult.fromJson(d.data()))
        .toList();
  }
}