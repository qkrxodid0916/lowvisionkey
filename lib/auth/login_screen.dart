import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  /// ✅ Google 로그인
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 계정 선택 꼬임 방지 (선택)
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
      // 성공하면 AuthGate가 자동으로 MenuScreen으로 이동
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: $e")),
        );
      }
    }
  }

  /// ✅ 게스트(익명 로그인)
  Future<void> _signInAsGuestTrial() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInAnonymously();
      // 성공하면 AuthGate가 자동으로 MenuScreen으로 이동
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.piano, size: 120, color: Colors.blue),
                const SizedBox(height: 24),

                const Text(
                  "음악 학습 어플",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 80),

                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                ] else ...[
                  /// 🔵 Google 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 6,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.login,
                        size: 42,
                        color: Colors.blue,
                      ),
                      label: const Text(
                        "구글로 시작하기",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _signInWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🟢 게스트 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.black54,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.person_outline, size: 40),
                      label: const Text(
                        "게스트로 체험하기",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _signInAsGuestTrial,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}