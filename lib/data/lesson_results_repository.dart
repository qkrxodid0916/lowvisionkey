import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson/lesson_result.dart';

class LessonResultsRepository {
  LessonResultsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) =>
      _db.collection('lesson_results').doc(uid).collection('sessions');

  /// lesson_results/{uid}/sessions/{autoId}
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
}
