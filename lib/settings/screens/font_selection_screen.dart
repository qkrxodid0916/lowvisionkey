import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lowvision_key/app/app_settings.dart';
import 'package:lowvision_key/app/font_prefs.dart';
import 'package:lowvision_key/screens/menu_screen.dart';

class FontSelectionScreen extends StatefulWidget {
  const FontSelectionScreen({super.key, this.fromSettings = false});
  final bool fromSettings;

  @override
  State<FontSelectionScreen> createState() => _FontSelectionScreenState();
}

class _FontSelectionScreenState extends State<FontSelectionScreen> {
  double _initialScale = 1.0;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 순간 값 저장(임시)
    _initialScale = AppSettings.fontScale.value;
    _loadSavedScaleIfAny();
  }

  Future<void> _loadSavedScaleIfAny() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // 비로그인/게스트 흐름 등: 현재값이 기준
      _initialScale = AppSettings.fontScale.value;
      return;
    }

    final saved = await FontPrefs.getFontScale(
      uid,
      fallback: AppSettings.fontScale.value,
    );

    AppSettings.fontScale.value = saved;
    // ✅ “이 화면에 들어왔을 때 기준값”을 저장된 값으로 갱신
    _initialScale = saved;
  }

  void _rollbackIfNeeded() {
    if (_applied) return;
    AppSettings.fontScale.value = _initialScale;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                  "확인해주세요",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 30),

                // 전역 스케일이 적용되므로 base 텍스트만 둬도 같이 커짐(미리보기)
                const Text(
                  "지금 설정하신 크기로\n적용할까요?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    // ✅ 이전(롤백)
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue, width: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            _rollbackIfNeeded();
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            "이전",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // ✅ 적용(저장 + 분기)
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            _applied = true; // ✅ 이제부터 롤백 금지
                            Navigator.pop(dialogContext);

                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              await FontPrefs.setFontScale(
                                uid,
                                AppSettings.fontScale.value,
                              );
                            }

                            if (!mounted) return;

                            if (widget.fromSettings) {
                              // 설정에서 들어온 경우: 설정으로 복귀
                              Navigator.pop(context);
                            } else {
                              // 최초 설정 흐름: 메뉴로
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MenuScreen()),
                              );
                            }
                          },
                          child: const Text(
                            "적용",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ✅ 뒤로가기도 “적용” 안 했으면 롤백
        _rollbackIfNeeded();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "글씨가 잘 보이시나요?",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const SingleChildScrollView(
                      child: Text(
                        "설정한 글씨 크기가\n적용된 화면입니다.\n잘 보이시나요?",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Text(
                      "가",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<double>(
                        valueListenable: AppSettings.fontScale,
                        builder: (_, scale, __) {
                          return Slider(
                            value: scale,
                            min: 0.8,
                            max: 1.6,
                            divisions: 8,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.blueAccent,
                            thumbColor: Colors.blue,
                            label: "${scale.toStringAsFixed(1)}x",
                            onChanged: (value) {
                              AppSettings.fontScale.value = value;
                            },
                          );
                        },
                      ),
                    ),
                    const Text(
                      "가",
                      style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _showConfirmationDialog,
                    child: const Text(
                      "확 인",
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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