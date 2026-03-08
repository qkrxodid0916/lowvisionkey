import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lowvision_key/data/lesson_results_repository.dart';
import 'package:lowvision_key/utils/header_message.dart';
import 'package:lowvision_key/lesson/screens/course_levels_screen.dart';
import 'package:lowvision_key/function/piano_screen.dart';
import 'package:lowvision_key/settings/screens/settings_screen.dart';
import 'package:lowvision_key/report/screens/report_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _repo = LessonResultsRepository();

  Future<String> _loadHeaderText() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final name = user?.displayName;

    if (uid == null) {
      return HeaderMessageBuilder.build(name: name, streak: 0);
    }

    final recent = await _repo.fetchRecentResults(uid: uid, limit: 60);
    final streak = HeaderMessageBuilder.computeStreakKst(recent);

    return HeaderMessageBuilder.build(name: name, streak: streak);
  }

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ base 크기만 유지 (전역 textScaler가 알아서 확대/축소)
    const fs = 30.0;

    // 기존 “44/28/34 느낌” 비율 유지
    final headerBig = fs * 1.47;
    final headerSmall = fs * 0.93;
    final cardTitle = fs * 1.13;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _loadHeaderText(),
                      builder: (context, snap) {
                        final text = snap.data ?? "불러오는 중…";
                        final lines = text.split("\n");
                        final line1 = lines.isNotEmpty ? lines[0] : text;
                        final line2 = lines.length >= 2 ? lines[1] : "";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line1,
                              style: TextStyle(
                                fontSize: headerBig,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              line2,
                              style: TextStyle(
                                fontSize: headerSmall,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, size: fs * 1.2),
                    onPressed: () => _go(const SettingsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.25,
                  children: [
                    _menuCard(
                      "수업 시작하기",
                      Icons.school,
                      Colors.blue,
                      cardTitle,
                          () => _go(const CourseLevelsScreen()),
                    ),
                    _menuCard(
                      "자유 연주",
                      Icons.music_note,
                      Colors.green,
                      cardTitle,
                          () => _go(const PianoScreen()),
                    ),
                    _menuCard(
                      "리포트 보기",
                      Icons.bar_chart,
                      Colors.purple,
                      cardTitle,
                          () => _go(const ReportScreen()),
                    ),
                    _menuCard(
                      "설정",
                      Icons.settings,
                      Colors.orange,
                      cardTitle,
                          () => _go(const SettingsScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
      String title,
      IconData icon,
      Color color,
      double titleSize,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 4),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                offset: Offset(0, 6),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: titleSize * 1.8, color: color),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}