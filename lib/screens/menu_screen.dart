import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart'; // 로그인 화면(MyApp)으로 돌아가기 위함
import '../function/piano_screen.dart';

class MenuScreen extends StatelessWidget {
  final double fontSize;

  const MenuScreen({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자 정보 가져오기

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
            icon: Icon(icon, size: fontSize + 10, color: color),
            label: Text(title, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
            onPressed: onTap,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
        // 우측 상단 '계정 설정' 톱니바퀴
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10),
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.black, size: fontSize + 10),
              tooltip: '계정 설정',
              onPressed: () {
                _showAccountDialog(context, user);
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
            // 인사말
            Text(
              "안녕하세요!\n무엇을 하시겠습니까?",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // 1. 수업 시작하기 버튼
            buildMenuButton("🎹 수업 시작하기", Icons.school, Colors.blue, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("수업 목록 화면으로 이동합니다 (준비중)", style: TextStyle(fontSize: 20)),
                  duration: Duration(seconds: 1),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 2. 자유 연주 버튼
            buildMenuButton("🎵 자유 연주", Icons.music_note, Colors.green, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PianoScreen())
              );
            }),
          ],
        ),
      ),
    );
  }

  // ★ 계정 설정 팝업창 (로그아웃 로직 수정됨)
  void _showAccountDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue, width: 5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "계정 설정",
                  style: TextStyle(fontSize: fontSize + 5, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
                const SizedBox(height: 30),

                // 이메일 정보 표시
                Text(
                  "현재 로그인된 계정:",
                  style: TextStyle(fontSize: fontSize * 0.7, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? "이메일 정보 없음",
                  style: TextStyle(fontSize: fontSize * 0.8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 로그아웃 버튼 (수정됨: disconnect 적용)
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: Icon(Icons.logout, color: Colors.white, size: fontSize),
                    label: Text("로그아웃", style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(context); // 팝업 닫기

                      try {
                        // 1. 파이어베이스 로그아웃
                        await FirebaseAuth.instance.signOut();

                        // 2. 구글 계정 연결 끊기
                        await GoogleSignIn().disconnect();
                      } catch (e) {
                        // disconnect 실패 시 일반 로그아웃 시도
                        print("구글 연결 해제 실패(무시 가능): $e");
                        try {
                          await GoogleSignIn().signOut();
                        } catch (e2) {
                          // 무시
                        }
                      }

                      // 3. 로그인 화면으로 완전히 이동
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyApp()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 닫기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("닫기", style: TextStyle(fontSize: fontSize * 0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}