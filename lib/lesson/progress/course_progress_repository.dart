import 'package:cloud_firestore/cloud_firestore.dart';

class CourseProgress {
  final int unlockedIndex;
  final Map<String, double> bestByKey;
  final Map<String, Timestamp> completedAtByKey;

  const CourseProgress({
    required this.unlockedIndex,
    required this.bestByKey,
    required this.completedAtByKey,
  });

  bool isUnlocked(int index) => index <= unlockedIndex;
  bool isCompleted(String key) => completedAtByKey.containsKey(key);
  double bestAccuracy(String key) => bestByKey[key] ?? 0.0;

  static CourseProgress empty() =>
      const CourseProgress(
        unlockedIndex: 0,
        bestByKey: {},
        completedAtByKey: {},
      );
}

class CourseProgressRepository {
  CourseProgressRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String courseId) =>
      _db.collection('lesson_progress').doc(uid).collection('courses').doc(courseId);

  Future<CourseProgress> getOrCreate(String uid, String courseId) async {
    final ref = _doc(uid, courseId);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'courseId': courseId,
        'unlockedIndex': 0,
        'bestByKey': <String, dynamic>{},
        'completedAtByKey': <String, dynamic>{},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return CourseProgress.empty();
    }

    final data = snap.data() ?? {};
    final unlocked = (data['unlockedIndex'] ?? 0) as int;

    final bestRaw = Map<String, dynamic>.from(data['bestByKey'] ?? {});
    final completedRaw = Map<String, dynamic>.from(data['completedAtByKey'] ?? {});

    final best = <String, double>{};
    for (final e in bestRaw.entries) {
      final v = e.value;
      if (v is num) best[e.key] = v.toDouble();
    }

    final completedAt = <String, Timestamp>{};
    for (final e in completedRaw.entries) {
      final v = e.value;
      if (v is Timestamp) completedAt[e.key] = v;
    }

    return CourseProgress(
      unlockedIndex: unlocked,
      bestByKey: best,
      completedAtByKey: completedAt,
    );
  }

  Future<CourseProgress> applyResult({
    required String uid,
    required String courseId,

    /// lesson 카드 인덱스
    required int lessonIndex,

    /// step 고유 키
    required String stepKey,

    required double accuracy,
    required bool passed,

    /// 마지막 step 통과 시에만 true
    bool advanceUnlock = false,
  }) async {
    final ref = _doc(uid, courseId);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};

      final unlocked = (data['unlockedIndex'] ?? 0) as int;

      final bestRaw = Map<String, dynamic>.from(data['bestByKey'] ?? {});
      final completedRaw = Map<String, dynamic>.from(data['completedAtByKey'] ?? {});

      final prevBest =
      (bestRaw[stepKey] is num) ? (bestRaw[stepKey] as num).toDouble() : 0.0;

      if (accuracy > prevBest) {
        bestRaw[stepKey] = accuracy;
      }

      if (passed) {
        completedRaw[stepKey] = FieldValue.serverTimestamp();
      }

      var newUnlocked = unlocked;
      if (passed && advanceUnlock && unlocked == lessonIndex) {
        newUnlocked = unlocked + 1;
      }

      tx.set(
        ref,
        {
          'courseId': courseId,
          'unlockedIndex': newUnlocked,
          'bestByKey': bestRaw,
          'completedAtByKey': completedRaw,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final best = <String, double>{};
      for (final e in bestRaw.entries) {
        if (e.value is num) best[e.key] = (e.value as num).toDouble();
      }

      final completedAt = <String, Timestamp>{};
      for (final e in completedRaw.entries) {
        if (e.value is Timestamp) completedAt[e.key] = e.value as Timestamp;
      }

      return CourseProgress(
        unlockedIndex: newUnlocked,
        bestByKey: best,
        completedAtByKey: completedAt,
      );
    });
  }
}