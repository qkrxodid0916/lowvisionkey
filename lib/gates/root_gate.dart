import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ✅ 태블릿만 전체 가로 고정, 폰은 전체 허용
class RootGate extends StatelessWidget {
  final Widget child;
  const RootGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    if (isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
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