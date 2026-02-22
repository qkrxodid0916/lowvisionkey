import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfographicScreen extends StatelessWidget {
  const InfographicScreen({super.key, this.anchorDocId});
  final String? anchorDocId;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('주간 인포그래픽'),
      ),
      body: uid == null
          ? const Center(
        child: Text('로그인이 필요합니다.',
            style: TextStyle(color: Colors.white70)),
      )
          : _InfographicBody(
        uid: uid,
        anchorDocId: anchorDocId,
      ),
    );
  }
}

class _InfographicBody extends StatelessWidget {
  const _InfographicBody({
    required this.uid,
    this.anchorDocId,
  });

  final String uid;
  final String? anchorDocId;

  CollectionReference<Map<String, dynamic>> get _weeklyRef =>
      FirebaseFirestore.instance
          .collection('lesson_reports')
          .doc(uid)
          .collection('weekly');

  /// ✅ docId 기반으로만 가져오기 (createdAt 의존 제거)
  /// - anchorDocId 있으면: 선택한 주 + 전주(2개)
  /// - 없으면: 최신 2개
  Query<Map<String, dynamic>> _query() {
    final base = _weeklyRef.orderBy(FieldPath.documentId, descending: true);

    if (anchorDocId != null && anchorDocId!.trim().isNotEmpty) {
      return base.startAt([anchorDocId]).limit(2);
    }

    return base.limit(2);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query().snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(
              '에러: ${snap.error}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD54A)),
          );
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text('주간 리포트가 아직 없습니다.',
                style: TextStyle(color: Colors.white70)),
          );
        }

        final currentDoc = docs[0]; // ✅ 선택한 주(또는 최신)
        final current = currentDoc.data();
        final prev = (docs.length >= 2) ? docs[1].data() : null; // ✅ 전 주

        int asInt(dynamic v) {
          if (v == null) return 0;
          if (v is int) return v;
          if (v is double) return v.toInt();
          return int.tryParse(v.toString()) ?? 0;
        }

        double asDouble(dynamic v) {
          if (v == null) return 0;
          if (v is double) return v;
          if (v is int) return v.toDouble();
          return double.tryParse(v.toString()) ?? 0;
        }

        final total = asInt(current['total']);
        final correct = asInt(current['correct']);
        final wrong = asInt(current['wrong']);
        final sessions = asInt(current['sessions']);
        final learningTimeSec = asInt(current['learningTimeSec']);

        // ✅ 정확도: 문서에 accuracy가 있으면 그걸 우선 사용 (없으면 correct/total)
        final accuracy = current.containsKey('accuracy')
            ? asDouble(current['accuracy'])
            : (total > 0 ? correct / total : 0.0);

        final prevAcc = prev == null ? null : asDouble(prev['accuracy']);
        final prevTime = prev == null ? null : asInt(prev['learningTimeSec']);

        final accPercent = accuracy * 100.0;
        final accDelta = (prevAcc == null) ? null : ((accuracy - prevAcc) * 100.0);
        final timeDelta = (prevTime == null) ? null : (learningTimeSec - prevTime);

        String deltaText(double? v) {
          if (v == null) return '지난 주 데이터 없음';
          if (v.abs() < 0.05) return '변화 없음';
          final sign = v > 0 ? '+' : '';
          return '$sign${v.toStringAsFixed(1)}%p';
        }

        String deltaMinText(int? sec) {
          if (sec == null) return '지난 주 데이터 없음';
          final min = (sec / 60).round();
          if (min == 0) return '변화 없음';
          final sign = min > 0 ? '+' : '';
          return '$sign$min분';
        }

        // ✅ 타이틀(기간) 표시: title > docId
        final title = (current['title'] as String?)?.trim();
        final headerText = (title != null && title.isNotEmpty) ? title : currentDoc.id;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주간 비교',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headerText,
                    style: TextStyle(color: Colors.white.withOpacity(0.65)),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    '정확도 ${accPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFFFFD54A),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    deltaText(accDelta),
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    '학습 시간 ${(learningTimeSec / 60).round()}분',
                    style: const TextStyle(
                      color: Color(0xFFFFD54A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    deltaMinText(timeDelta),
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    '총 세션 $sessions',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '정답 $correct / 오답 $wrong / 총 $total',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}