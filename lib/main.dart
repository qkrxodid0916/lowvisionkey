import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/menu_screen.dart';
// import 'firebase_options.dart'; // firebase_options 파일이 생성되었다면 주석 해제 후 사용

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 초기화
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // firebase_options를 사용 중이라면 주석 해제
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 로그인 상태를 실시간 감시해서 화면 자동 전환
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. 로그인 성공 상태면 -> 메뉴 화면으로
          if (snapshot.hasData) {
            return const MenuScreen(fontSize: 30.0);
          }
          // 2. 아니면 -> 로그인 화면 표시
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

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // (재로그인 시 에러 방지)
      try {
        await GoogleSignIn().disconnect();
      } catch (e) {
        // 연결된 게 없으면 에러가 나는데 정상이므로 무시
      }

      // 구글 계정 선택창 띄우기
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // 사용자가 창을 닫거나 취소함
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 인증 토큰 받아오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // [수정 완료] 파이어베이스용 자격 증명 만들기
      // accessToken을 null로 설정하여 최신 라이브러리 충돌 해결
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // 파이어베이스 로그인 실행
      await FirebaseAuth.instance.signInWithCredential(credential);

      // (로그인이 성공하면 StreamBuilder가 알아서 화면을 메뉴로 바꿉니다)

    } catch (e) {
      if (FirebaseAuth.instance.currentUser != null) {
        print("로그인 성공했으나 타이밍 에러 발생(무시함): $e");
        return;
      }

      // 치명적 에러일시 아래 내용 실행
      print("로그인 에러 발생: $e");
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: $e")),
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
              // 로고 아이콘
              const Icon(Icons.piano, size: 100, color: Colors.blue),
              const SizedBox(height: 20),

              // 앱 제목
              const Text(
                "피아노 배우기",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 100),

              // 로그인 버튼
              _isLoading
                  ? const CircularProgressIndicator() // 로딩 중이면 뺑뺑이
                  : SizedBox(
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
                  onPressed: signInWithGoogle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}