import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  String _yyyyMmDd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('일일 리포트')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    final todayId = _yyyyMmDd(DateTime.now());

    final docRef = FirebaseFirestore.instance
        .collection('lesson_reports')
        .doc(uid)
        .collection('daily')
        .doc(todayId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('일일 리포트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // StreamBuilder가 아닌 FutureBuilder라면 setState가 필요하지만,
          // 여기선 StreamBuilder로 바로 새로고침 느낌을 줌(사용자 UX용)
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('불러오기 실패: ${snap.error}', textAlign: TextAlign.center),
                ],
              );
            }

            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final doc = snap.data!;
            if (!doc.exists) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: const [
                  SizedBox(height: 40),
                  Icon(Icons.inbox, size: 56, color: Colors.black38),
                  SizedBox(height: 12),
                  Text(
                    '오늘의 일일 리포트가 아직 없어요.\n수업을 진행하면 자동으로 생성돼요.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final data = doc.data() ?? <String, dynamic>{};

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

            String formatDuration(int sec) {
              if (sec <= 0) return '0분';
              final h = sec ~/ 3600;
              final m = (sec % 3600) ~/ 60;
              if (h <= 0) return '${m}분';
              if (m == 0) return '${h}시간';
              return '${h}시간 ${m}분';
            }

            final total = asInt(data['total']);
            final correct = asInt(data['correct']);
            final wrong = asInt(data['wrong']);
            final accuracy = data.containsKey('accuracy') ? asDouble(data['accuracy']) : (total > 0 ? correct / total : 0.0);
            final learningTimeSec = asInt(data['learningTimeSec']);

            final topWrongMidis = (data['topWrongMidis'] as List?)
                ?.map((e) => e is num ? e.toInt() : int.tryParse(e.toString()) ?? 0)
                .where((e) => e != 0)
                .toList() ??
                const [];

            final coachLine = (data['coachLine'] ?? '코칭이 아직 없어요.').toString();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _HeaderCard(
                  title: '오늘 (${todayId.replaceAll('-', '.')})',
                  subtitle: '학습 요약',
                ),
                const SizedBox(height: 14),

                _StatsCard(
                  accuracyPercent: accuracy * 100.0,
                  total: total,
                  correct: correct,
                  wrong: wrong,
                  learningTime: formatDuration(learningTimeSec),
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  title: '오답 TOP3',
                  child: topWrongMidis.isEmpty
                      ? Text('오답 데이터가 없어요.', style: TextStyle(color: Colors.black.withOpacity(0.6)))
                      : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topWrongMidis
                        .take(3)
                        .map((m) => _Chip(text: 'MIDI $m'))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  title: '코칭',
                  child: Text(
                    coachLine,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),

                const SizedBox(height: 18),
                Center(
                  child: Text(
                    '아래로 당겨서 새로고침',
                    style: TextStyle(color: Colors.black.withOpacity(0.45)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.withOpacity(0.12),
            ),
            child: const Icon(Icons.today, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.55), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.accuracyPercent,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.learningTime,
  });

  final double accuracyPercent;
  final int total;
  final int correct;
  final int wrong;
  final String learningTime;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('핵심 지표', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatChip(label: '정확도', value: '${accuracyPercent.toStringAsFixed(1)}%', icon: Icons.insights)),
              const SizedBox(width: 10),
              Expanded(child: _StatChip(label: '학습 시간', value: learningTime, icon: Icons.timer)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatChip(label: '총 문제', value: '$total', icon: Icons.list_alt)),
              const SizedBox(width: 10),
              Expanded(child: _StatChip(label: '정답/오답', value: '$correct / $wrong', icon: Icons.check_circle)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.05),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.55))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: child,
    );
  }
}