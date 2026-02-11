import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../lesson/lesson_result.dart';


class ResultUploader {
  ResultUploader._();
  static final ResultUploader I = ResultUploader._();

  final _db = FirebaseFirestore.instance;

  Future<void> upload(LessonResult result) async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // 로그인 없으면 null

    final data = result.toJson()
      ..addAll({
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
  }
}
