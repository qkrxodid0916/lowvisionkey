import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../app/dev_settings.dart';
import 'package:lowvision_key/settings/screens/font_selection_screen.dart';
import '../../report/repositories/report_repository.dart';
import '../../ble/screens/ble_scan_screen.dart';

enum _ExistingAccountAction { cancel, useExisting, chooseAnother }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _working = false;

  User? get _user => FirebaseAuth.instance.currentUser;
  bool get _isGuest => _user?.isAnonymous ?? false;

  final ReportRepository _reportRepo = ReportRepository();

  Future<void> _generateWeeklyReport() async {
    if (_working) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요해요.")),
      );
      return;
    }

    setState(() => _working = true);
    try {
      final reportId = await _reportRepo.generateLast7DaysLessonWeeklyReport(uid: uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주간 리포트 생성 완료: $reportId")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주간 리포트 생성 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _signOut() async {
    if (_working) return;
    setState(() => _working = true);

    try {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pop();
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
    const fs = 30.0;

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
        if (mounted) setState(() => _working = false);
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

            if (mounted) setState(() => _working = false);
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

  void _openFontScaleSetting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FontSelectionScreen(fromSettings: true),
      ),
    );
  }
  void _openBleScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BleScanScreen(),
      ),
    );
  }
  Widget _buildDevSettingsCard(double fs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "개발자 모드",
            style: TextStyle(
              fontSize: fs * 0.85,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "개발 중 테스트를 빠르게 하기 위한 옵션이에요.",
            style: TextStyle(
              fontSize: fs * 0.52,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "레슨 전체 해제",
              style: TextStyle(
                fontSize: fs * 0.58,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              "모든 주차와 Day를 바로 열어 테스트해요.",
              style: TextStyle(
                fontSize: fs * 0.48,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            value: DevSettings.unlockAllLessons,
            onChanged: (v) {
              setState(() {
                DevSettings.unlockAllLessons = v;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "결과 저장 끄기",
              style: TextStyle(
                fontSize: fs * 0.58,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              "테스트 중 결과를 저장하지 않아요.",
              style: TextStyle(
                fontSize: fs * 0.48,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            value: DevSettings.disableResultSaving,
            onChanged: (v) {
              setState(() {
                DevSettings.disableResultSaving = v;
              });
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.bluetooth, color: Colors.white),
              label: Text(
                "ESP32 LED 기기 연결",
                style: TextStyle(
                  fontSize: fs * 0.58,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: _working ? null : _openBleScanScreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const fs = 30.0;

    final user = _user;
    final isGuest = _isGuest;

    final titleText = isGuest ? "게스트(체험판) 계정" : "로그인 계정";
    final subtitleText =
    isGuest ? "로그인 없이 기능을 체험할 수 있어요." : "데이터가 계정에 안전하게 저장됩니다.";
    final accountText =
    isGuest ? "이메일 정보 없음" : (user?.email ?? "이메일 정보 없음");

    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("설정")),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: (_working || uid == null) ? null : _generateWeeklyReport,
            icon: const Icon(Icons.summarize),
            label: const Text("이번 주 리포트 생성(최근 7일)"),
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text("로그인이 필요해요"))
          : Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x14000000),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.text_fields),
                  title: Text(
                    "글씨 크기 조절",
                    style: TextStyle(
                      fontSize: fs * 0.70,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    "화면 글씨 크기를 다시 설정합니다.",
                    style: TextStyle(
                      fontSize: fs * 0.52,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: _working ? null : _openFontScaleSetting,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x14000000),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "계정",
                      style: TextStyle(
                        fontSize: fs * 0.85,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      titleText,
                      style: TextStyle(
                        fontSize: fs * 0.55,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: fs * 0.55,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "현재 계정",
                      style: TextStyle(
                        fontSize: fs * 0.5,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      accountText,
                      style: TextStyle(
                        fontSize: fs * 0.62,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isGuest) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
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
                    Column(
                      children: [
                        if (isGuest) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.link, color: Colors.white),
                              label: Text(
                                "구글 계정 연결하기",
                                style: TextStyle(
                                  fontSize: fs * 0.58,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: _working ? null : _linkGuestToGoogle,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text(
                              "로그아웃",
                              style: TextStyle(
                                fontSize: fs * 0.58,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: _working ? null : _signOut,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildDevSettingsCard(fs),
            ],
          ),

          if (_working)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}