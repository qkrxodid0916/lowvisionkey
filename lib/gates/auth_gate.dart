import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lowvision_key/app/app_settings.dart';
import 'package:lowvision_key/app/font_prefs.dart';
import 'package:lowvision_key/auth/login_screen.dart';
import 'package:lowvision_key/screens/menu_screen.dart';
import 'package:lowvision_key/settings/screens/font_selection_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final uid = authSnap.data!.uid;

        return FutureBuilder<bool>(
          future: FontPrefs.hasFontScale(uid),
          builder: (context, hasSnap) {
            if (hasSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final hasScale = hasSnap.data ?? false;

            if (!hasScale) {
              // ✅ 계정별 1회 설정
              return const FontSelectionScreen();
            }

            return FutureBuilder<double>(
              // ✅ 이제는 scale이므로 fallback은 1.0
              future: FontPrefs.getFontScale(uid, fallback: 1.0),
              builder: (context, scaleSnap) {
                if (scaleSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                final scale = scaleSnap.data ?? 1.0;

                // ✅ 전역 스케일 주입 (앱 전체 적용)
                AppSettings.fontScale.value = scale;

                // ✅ MenuScreen은 더 이상 fontSize 안 받음
                return const MenuScreen();
              },
            );
          },
        );
      },
    );
  }
}