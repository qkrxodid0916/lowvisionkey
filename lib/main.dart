import 'package:flutter/services.dart'; // DeviceOrientation, SystemChrome
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'screens/menu_screen.dart';
import 'screens/ble_permission_screen.dart';
import 'utils/ble_permission.dart';

// import 'firebase_options.dart'; // 생성되어 있으면 주석 해제

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// ✅ 태블릿만 전체 가로 고정, 폰은 전체 허용
class RootGate extends StatelessWidget {
  final Widget child;
  const RootGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    // build에서 여러 번 호출될 수 있지만, 값이 같으면 문제 없이 유지됩니다.
    if (isTablet) {
      // 태블릿: 전체 가로 고정
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // 폰: 전체 회전 허용(메인 화면 세로 정상)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Low Vision Piano',
      theme: ThemeData(primarySwatch: Colors.blue),

      // ✅ 앱 시작 시 BLE 권한 게이트 + 태블릿 가로 고정 게이트
      home: const RootGate(
        child: BlePermissionGate(),
      ),
    );
  }
}

/// ✅ BLE 권한 있으면 AuthGate로, 없으면 권한 화면
class BlePermissionGate extends StatefulWidget {
  const BlePermissionGate({super.key});

  @override
  State<BlePermissionGate> createState() => _BlePermissionGateState();
}

class _BlePermissionGateState extends State<BlePermissionGate> {
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    _future = BlePermission.ensureGranted();
  }

  void _retry() {
    setState(() {
      _future = BlePermission.ensureGranted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final granted = snapshot.data == true;
        if (granted) return const AuthGate();

        return BlePermissionScreen(onRetry: _retry);
      },
    );
  }
}

/// ✅ 기존 그대로: 로그인 상태 감시
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
                      icon: const Icon(Icons.login, size: 42, color: Colors.blue),
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
                  SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black54, width: 2),
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
