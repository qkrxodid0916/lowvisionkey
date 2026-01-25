import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BlePermission {
  /// 권한이 필요하면 요청하고, 결과를 bool로 반환
  static Future<bool> ensureGranted() async {
    if (Platform.isIOS) {
      // iOS는 BLE 사용 시점에 시스템이 권한 팝업을 띄움 (Info.plist 필수)
      return true;
    }

    // Android 12+
    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();

    return scan.isGranted && connect.isGranted;
  }

  /// 현재 권한 상태만 확인(요청 없이)
  static Future<bool> isGranted() async {
    if (Platform.isIOS) return true;

    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    return scan.isGranted && connect.isGranted;
  }
}
