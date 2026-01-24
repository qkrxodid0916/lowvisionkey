import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'screens/menu_screen.dart';
// import 'firebase_options.dart'; // 생성되어 있으면 주석 해제

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Low Vision Piano',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 로그인(구글/익명) 되어있으면 메뉴로
          if (snapshot.hasData) {
            return const MenuScreen(fontSize: 30.0);
          }

          // 아니면 로그인 화면
          return const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 계정 선택 꼬임 방지(선택)
      try {
        await GoogleSignIn().disconnect();
      } catch (_) {}

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: $e")),
        );
      }
    }
  }

  Future<void> _signInAsGuestTrial() async {
    setState(() => _isLoading = true);

    try {
      // 게스트(체험판) = 익명 로그인
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("게스트 시작 실패: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.piano, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "음악 학습 어플",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // ✅ 체험판 안내
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "게스트 모드는 체험판입니다.\n"
                      "기기 변경/앱 삭제 시 데이터가 유지되지 않을 수 있어요.\n"
                      "데이터를 안전하게 보관하려면 구글 로그인을 권장합니다.",
                  style: TextStyle(fontSize: 18, height: 1.35),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),

              if (_isLoading) ...[
                const CircularProgressIndicator(),
              ] else ...[
                // 구글 로그인
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.login, size: 35, color: Colors.blue),
                    label: const Text(
                      "구글로 시작하기",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _signInWithGoogle,
                  ),
                ),
                const SizedBox(height: 20),

                // 게스트(체험판) 시작
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.person_outline, size: 32),
                    label: const Text(
                      "게스트로 체험하기",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _signInAsGuestTrial,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
