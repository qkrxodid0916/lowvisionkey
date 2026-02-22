import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'daily_report_screen.dart';
import 'infographic_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>?>? _future;

  @override
  void initState() {
    super.initState();
    _kickoff();
  }

  void _kickoff() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _future = null;
      return;
    }
    _future = _fetchLatestWeekly(uid);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchLatestWeekly(String uid) async {
    // 1) createdAt 기반 최신 1개 시도
    try {
      final q = await FirebaseFirestore.instance
          .collection('lesson_reports')
          .doc(uid)
          .collection('weekly')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (q.docs.isEmpty) return null;
      return q.docs.first;
    } catch (_) {
      // createdAt 인덱스/필드 없으면 여기로 떨어질 수 있음
    }

    // 2) 문서 ID 기반 최신 1개 (예: 2026-02-03_2026-02-09)
    final q2 = await FirebaseFirestore.instance
        .collection('lesson_reports')
        .doc(uid)
        .collection('weekly')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .get();

    if (q2.docs.isEmpty) return null;
    return q2.docs.first;
  }

  // ✅ 주차 목록 (최근 N개)
  Query<Map<String, dynamic>> _weeklyListQueryByCreatedAt(String uid) {
    return FirebaseFirestore.instance
        .collection('lesson_reports')
        .doc(uid)
        .collection('weekly')
        .orderBy('createdAt', descending: true)
        .limit(30);
  }

  Query<Map<String, dynamic>> _weeklyListFallbackByDocId(String uid) {
    return FirebaseFirestore.instance
        .collection('lesson_reports')
        .doc(uid)
        .collection('weekly')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(30);
  }

  Future<void> _refresh() async {
    setState(() {
      _kickoff(); // ✅ future 자체를 교체해서 FutureBuilder가 확실히 다시 돎
    });
  }

  String _asString(dynamic v, {String fallback = '-'}) {
    if (v == null) return fallback;
    final s = v.toString();
    if (s.trim().isEmpty) return fallback;
    return s;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _formatPeriod(Map<String, dynamic> data, String docId) {
    final title = data['title'];
    if (title != null && title.toString().trim().isNotEmpty) return title.toString();

    if (docId.contains('_')) {
      final parts = docId.split('_');
      if (parts.length == 2) return '${parts[0]} ~ ${parts[1]}';
    }
    return docId;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('리포트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }

            if (snap.hasError) {
              return _ErrorView(
                message: '리포트를 불러오지 못했습니다.\n${snap.error}',
                onRetry: _refresh,
              );
            }

            final doc = snap.data;

            // ✅ 주간 리포트가 아예 없을 때도 "주차 선택"은 볼 수 있게
            // (다만 docs가 비어있으면 목록도 비어있음)
            if (doc == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const _EmptyView(),
                  const SizedBox(height: 18),
                  const _SectionTitle('주차 선택'),
                  const SizedBox(height: 10),
                  _WeeklyListSection(
                    uid: uid,
                    weeklyListQueryByCreatedAt: _weeklyListQueryByCreatedAt,
                    weeklyListFallbackByDocId: _weeklyListFallbackByDocId,
                    formatPeriod: _formatPeriod,
                  ),
                ],
              );
            }

            final data = doc.data() ?? <String, dynamic>{};
            final period = _formatPeriod(data, doc.id);

            final total = _asInt(data['total'] ?? data['totalNotes']);
            final correct = _asInt(data['correct'] ?? data['success']);
            final wrong = _asInt(data['wrong'] ?? data['fail']);
            final accuracy = data.containsKey('accuracy')
                ? _asDouble(data['accuracy'])
                : (total > 0 ? correct / total : 0.0);

            final summary = _asString(
              data['summary'] ?? data['text'] ?? data['aiSummary'],
              fallback: '요약이 아직 없어요.',
            );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _HeaderCard(
                  title: '최신 주간 리포트',
                  subtitle: period,
                ),
                const SizedBox(height: 14),

                _StatsCard(
                  total: total,
                  correct: correct,
                  wrong: wrong,
                  accuracy: accuracy,
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  title: '요약',
                  child: _ExpandableText(
                    text: summary,
                    maxLines: 6,
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ 버튼 연결 (인포그래픽은 최신 doc.id를 앵커로 넘김)
                _ActionsRow(
                  onDaily: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DailyReportScreen()),
                    );
                  },
                  onInfographic: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InfographicScreen(anchorDocId: doc.id),
                      ),
                    );
                  },
                  onWeeklyDetail: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('주간 상세 화면은 아직 없어요. (추가 예정)')),
                    );
                  },
                ),

                const SizedBox(height: 18),
                const _SectionTitle('주차 선택'),
                const SizedBox(height: 10),

                _WeeklyListSection(
                  uid: uid,
                  weeklyListQueryByCreatedAt: _weeklyListQueryByCreatedAt,
                  weeklyListFallbackByDocId: _weeklyListFallbackByDocId,
                  formatPeriod: _formatPeriod,
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '아래로 당겨서 새로고침',
                    style: TextStyle(color: Colors.black.withOpacity(0.45)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ✅ 주차 리스트 섹션(쿼리 + fallback 포함)
class _WeeklyListSection extends StatelessWidget {
  const _WeeklyListSection({
    required this.uid,
    required this.weeklyListQueryByCreatedAt,
    required this.weeklyListFallbackByDocId,
    required this.formatPeriod,
  });

  final String uid;
  final Query<Map<String, dynamic>> Function(String uid) weeklyListQueryByCreatedAt;
  final Query<Map<String, dynamic>> Function(String uid) weeklyListFallbackByDocId;
  final String Function(Map<String, dynamic> data, String docId) formatPeriod;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: weeklyListQueryByCreatedAt(uid).snapshots(),
      builder: (context, s1) {
        if (s1.hasError) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: weeklyListFallbackByDocId(uid).snapshots(),
            builder: (context, s2) => _WeeklyList(
              snap: s2,
              formatPeriod: formatPeriod,
              onTapDocId: (docId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InfographicScreen(anchorDocId: docId),
                  ),
                );
              },
            ),
          );
        }

        return _WeeklyList(
          snap: s1,
          formatPeriod: formatPeriod,
          onTapDocId: (docId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfographicScreen(anchorDocId: docId),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _WeeklyList extends StatelessWidget {
  const _WeeklyList({
    required this.snap,
    required this.formatPeriod,
    required this.onTapDocId,
  });

  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap;
  final String Function(Map<String, dynamic> data, String docId) formatPeriod;
  final void Function(String docId) onTapDocId;

  @override
  Widget build(BuildContext context) {
    if (!snap.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final docs = snap.data!.docs;
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('주간 리포트가 없습니다.'),
      );
    }

    // ✅ ListView 안에 ListView이므로 shrinkWrap + NeverScrollable 필수
    return ListView.builder(
      itemCount: docs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final d = docs[i];
        final title = formatPeriod(d.data(), d.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onTapDocId(d.id),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.onDaily,
    required this.onInfographic,
    required this.onWeeklyDetail,
  });

  final VoidCallback onDaily;
  final VoidCallback onInfographic;
  final VoidCallback onWeeklyDetail;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('바로가기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDaily,
                  icon: const Icon(Icons.today),
                  label: const Text('일일'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onInfographic,
                  icon: const Icon(Icons.auto_graph),
                  label: const Text('인포그래픽'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onWeeklyDetail,
            icon: const Icon(Icons.article_outlined),
            label: const Text('주간 상세'),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text, this.maxLines = 6});
  final String text;
  final int maxLines;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(fontSize: 15, height: 1.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: style,
          maxLines: expanded ? null : widget.maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? '접기' : '더보기',
            style: TextStyle(
              color: Colors.purple.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
              color: Colors.purple.withOpacity(0.10),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55)),
                ),
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
    required this.total,
    required this.correct,
    required this.wrong,
    required this.accuracy,
  });

  final int total;
  final int correct;
  final int wrong;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 주 성과', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatChip(label: '총 시도', value: '$total', icon: Icons.list_alt)),
              const SizedBox(width: 10),
              Expanded(child: _StatChip(label: '성공', value: '$correct', icon: Icons.check_circle)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatChip(label: '실패', value: '$wrong', icon: Icons.cancel)),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  label: '정확도',
                  value: '${(accuracy * 100).toStringAsFixed(1)}%',
                  icon: Icons.insights,
                ),
              ),
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
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: const [
        SizedBox(height: 60),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 12),
        Center(child: Text('리포트를 불러오는 중...')),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.inbox, size: 56, color: Colors.black.withOpacity(0.35)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            '아직 주간 리포트가 없어요.\n수업을 진행하면 자동으로 생성돼요.',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Icon(Icons.error_outline, size: 56, color: Colors.red.withOpacity(0.7)),
        const SizedBox(height: 12),
        Center(child: Text(message, textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ),
      ],
    );
  }
}