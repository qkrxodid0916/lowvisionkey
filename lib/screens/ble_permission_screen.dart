import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePermissionScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const BlePermissionScreen({super.key, required this.onRetry});

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
                const Icon(Icons.bluetooth, size: 120, color: Colors.blue),
                const SizedBox(height: 30),
                const Text(
                  "블루투스 권한이 필요합니다",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                const Text(
                  "디지털 피아노(ESP32)와 연결하려면\n"
                      "블루투스 권한을 허용해주세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, height: 1.35),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onRetry,
                    child: const Text(
                      "다시 시도",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black54, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      await openAppSettings();
                    },
                    child: const Text(
                      "설정으로 이동",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
