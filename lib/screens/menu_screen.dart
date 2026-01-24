import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../function/piano_screen.dart';

/// ✅ enum은 반드시 파일 최상단(Top-level)에 선언
enum _ExistingAccountAction { cancel, useExisting, chooseAnother }

class MenuScreen extends StatefulWidget {
  final double fontSize;

  const MenuScreen({super.key, required this.fontSize});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _working = false;

  User? get _user => FirebaseAuth.instance.currentUser;
  bool get _isGuest => _user?.isAnonymous ?? false;

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

  Future<void> _signOut() async {
    if (_working) return;
    setState(() => _working = true);

    try {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      await FirebaseAuth.instance.signOut();
      // ✅ main.dart의 authStateChanges가 LoginScreen으로 자동 전환
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그아웃 실패: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<_ExistingAccountAction> _showAlreadyExistsDialog() async {
    final fs = widget.fontSize;

    final result = await showDialog<_ExistingAccountAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("이미 존재하는 계정", style: TextStyle(fontSize: fs * 0.8)),
        content: Text(
          "선택한 구글 계정은 이미 사용 중입니다.\n\n"
              "• 다른 계정을 선택하거나\n"
              "• 기존 계정으로 로그인할 수 있어요.\n\n"
              "※ 기존 계정으로 로그인하면 현재 게스트(체험판) 데이터는 유지되지 않을 수 있습니다.",
          style: TextStyle(fontSize: fs * 0.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ExistingAccountAction.cancel),
            child: Text("취소", style: TextStyle(fontSize: fs * 0.6)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ExistingAccountAction.chooseAnother),
            child: Text("다른 계정", style: TextStyle(fontSize: fs * 0.6)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _ExistingAccountAction.useExisting),
            child: Text("기존 계정 사용", style: TextStyle(fontSize: fs * 0.6)),
          ),
        ],
      ),
    );

    return result ?? _ExistingAccountAction.cancel;
  }

  /// 게스트(익명) 계정을 구글 계정에 "연결" 시도
  /// - 성공: UID 유지(데이터 보존)
  /// - 실패(credential-already-in-use): 이미 존재하는 계정 -> 다른 계정/기존 계정 사용
  Future<void> _linkGuestToGoogle() async {
    final user = _user;
    if (user == null) return;

    if (!user.isAnonymous) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 로그인된 계정입니다.")),
        );
      }
      return;
    }

    if (_working) return;
    setState(() => _working = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _working = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        await user.linkWithCredential(cred);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("구글 계정 연결 완료! (데이터 보존)")),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          if (!mounted) return;

          final action = await _showAlreadyExistsDialog();

          if (action == _ExistingAccountAction.chooseAnother) {
            try {
              await GoogleSignIn().disconnect();
            } catch (_) {}

            setState(() => _working = false);
            await _linkGuestToGoogle();
            return;
          }

          if (action == _ExistingAccountAction.useExisting) {
            await FirebaseAuth.instance.signInWithCredential(cred);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("기존 계정으로 로그인했습니다.")),
              );
            }
          }
          // cancel: 게스트 유지
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("연결 실패: ${e.code}")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("연결 실패: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showAccountDialog() {
    final user = _user;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final fs = widget.fontSize;

        final isGuest = _isGuest;
        final titleText = isGuest ? "게스트(체험판) 계정" : "로그인 계정";
        final subtitleText = isGuest
            ? "로그인 없이 기능을 체험할 수 있어요."
            : "데이터가 계정에 안전하게 저장됩니다.";
        final accountText = isGuest ? "이메일 정보 없음" : (user?.email ?? "이메일 정보 없음");

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 10),
                    color: Color(0x22000000),
                  )
                ],
                border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.manage_accounts, color: Color(0xFF246BFD)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "계정 설정",
                              style: TextStyle(
                                fontSize: fs * 0.95,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              titleText,
                              style: TextStyle(
                                fontSize: fs * 0.55,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "닫기",
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 상태/설명 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitleText,
                          style: TextStyle(
                            fontSize: fs * 0.55,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "현재 계정",
                          style: TextStyle(fontSize: fs * 0.5, color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          accountText,
                          style: TextStyle(
                            fontSize: fs * 0.62,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 게스트 안내 (게스트일 때만)
                  if (isGuest) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "게스트 모드는 체험판입니다.\n"
                                  "기기 변경/앱 삭제 시 데이터가 유지되지 않을 수 있어요.\n"
                                  "데이터를 보존하려면 구글 계정을 연결하세요.",
                              style: TextStyle(
                                fontSize: fs * 0.52,
                                height: 1.25,
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 버튼들
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.link, color: Colors.white),
                          label: Text(
                            "구글 계정 연결하기",
                            style: TextStyle(
                              fontSize: fs * 0.62,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: _working
                              ? null
                              : () async {
                            Navigator.pop(dialogContext);
                            await _linkGuestToGoogle();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            "로그아웃",
                            style: TextStyle(
                              fontSize: fs * 0.62,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: _working
                              ? null
                              : () async {
                            Navigator.pop(dialogContext);
                            await _signOut();
                          },
                        ),
                      ),
                    ],
                  ),

                  if (_working) ...[
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
              tooltip: '계정 설정',
              onPressed: _showAccountDialog,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("수업 목록 화면으로 이동합니다 (준비중)", style: TextStyle(fontSize: 20)),
                  duration: Duration(seconds: 1),
                ),
              );
            }),

            const SizedBox(height: 20),

            buildMenuButton("🎵 자유 연주", Icons.music_note, Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PianoScreen()),
              );
            }),

            if (_working) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
