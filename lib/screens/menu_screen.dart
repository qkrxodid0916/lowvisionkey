import 'package:flutter/material.dart';
import 'ble_scan_screen.dart';
import '../function/piano_screen.dart';
import 'lesson_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  final double fontSize;

  const MenuScreen({super.key, required this.fontSize});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // 버튼 만드는 함수
  Widget buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 90,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: color, width: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
          icon: Icon(icon, size: widget.fontSize + 10, color: color),
          label: Text(
            title,
            style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.bold),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10),
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.black, size: widget.fontSize + 10),
              tooltip: '설정',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(fontSize: widget.fontSize),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              "안녕하세요!\n무엇을 하시겠습니까?",
              style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            buildMenuButton("🎹 수업 시작하기", Icons.school, Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LessonScreen()),
              );
            }),

            const SizedBox(height: 20),

            buildMenuButton("🎵 자유 연주", Icons.music_note, Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PianoScreen()),
              );
            }),

            SizedBox(
              width: double.infinity,
              height: 90,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BleScanScreen()),
                  );
                },
                child: Text(
                  "BLE 연결",
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
