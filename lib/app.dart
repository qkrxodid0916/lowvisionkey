import 'package:flutter/material.dart';
import 'gates/root_gate.dart';
import 'gates/ble_permission_gate.dart';
import 'app/app_settings.dart'; //

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppSettings.fontScale,
      builder: (_, scale, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Low Vision Piano',
          theme: ThemeData(primarySwatch: Colors.blue),

          // 전역 텍스트 비율 적용
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(scale)),
              child: child ?? const SizedBox.shrink(),
            );

            // 만약 textScaler 때문에 에러 나면(구버전 Flutter):
            // return MediaQuery(
            //   data: mq.copyWith(textScaleFactor: scale),
            //   child: child ?? const SizedBox.shrink(),
            // );
          },

          home: const RootGate(
            child: BlePermissionGate(),
          ),
        );
      },
    );
  }
}