import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleMidiManager {
  BleMidiManager._();
  static final BleMidiManager I = BleMidiManager._();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // ✅ ESP32 현재 코드와 맞춘 UUID
  static final Uuid serviceUuid =
  Uuid.parse('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Uuid writeCharUuid =
  Uuid.parse('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Uuid notifyCharUuid =
  Uuid.parse('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  String? _deviceId;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  final ValueNotifier<DeviceConnectionState> connectionState =
  ValueNotifier(DeviceConnectionState.disconnected);

  String? get deviceId => _deviceId;
  bool get isConnected =>
      connectionState.value == DeviceConnectionState.connected;

  QualifiedCharacteristic? get _writeQc {
    final id = _deviceId;
    if (id == null) return null;
    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: serviceUuid,
      characteristicId: writeCharUuid,
    );
  }

  QualifiedCharacteristic? get _notifyQc {
    final id = _deviceId;
    if (id == null) return null;
    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: serviceUuid,
      characteristicId: notifyCharUuid,
    );
  }

  // ===== notify 문자열 수신 =====
  final StreamController<String> _messageCtrl =
  StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageCtrl.stream;

  Future<void> connect(String deviceId) async {
    if (_deviceId == deviceId &&
        (connectionState.value == DeviceConnectionState.connected ||
            connectionState.value == DeviceConnectionState.connecting)) {
      return;
    }

    await disconnect();

    _deviceId = deviceId;
    connectionState.value = DeviceConnectionState.connecting;

    _connSub = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    )
        .listen(
          (update) {
        connectionState.value = update.connectionState;

        if (update.connectionState == DeviceConnectionState.connected) {
          debugPrint('BLE connected: $deviceId');
        }

        if (update.connectionState == DeviceConnectionState.disconnected) {
          debugPrint('BLE disconnected: $deviceId');
          _deviceId = null;
          stopListening();
        }
      },
      onError: (e) {
        debugPrint('BLE connection error: $e');
        connectionState.value = DeviceConnectionState.disconnected;
        _deviceId = null;
        stopListening();
      },
    );
  }

  Future<void> disconnect() async {
    await stopListening();
    await _connSub?.cancel();
    _connSub = null;
    _deviceId = null;
    connectionState.value = DeviceConnectionState.disconnected;
  }

  // ===== 내부 write =====
  Future<void> _writeText(String text) async {
    final qc = _writeQc;
    if (qc == null || !isConnected) {
      debugPrint('BLE write skipped: not connected');
      return;
    }

    final bytes = Uint8List.fromList(text.codeUnits);

    debugPrint('BLE SEND -> $text');
    debugPrint('BLE SEND BYTES -> ${bytes.toList()}');

    try {
      await _ble.writeCharacteristicWithResponse(
        qc,
        value: bytes,
      );
    } catch (e) {
      debugPrint('BLE write error: $e');
    }
  }

  // ===== ESP32 명령 전송 =====

  /// 예: T:60
  /// 예: T:60,64,67
  Future<void> sendTargetNotes(List<int> midiNotes) async {
    if (midiNotes.isEmpty) return;

    final filtered = <int>[];
    for (final note in midiNotes) {
      if (note < 48 || note > 83) continue;
      if (!filtered.contains(note)) {
        filtered.add(note);
      }
      if (filtered.length >= 6) break;
    }

    if (filtered.isEmpty) {
      debugPrint('sendTargetNotes skipped: no valid notes');
      return;
    }

    final cmd = 'T:${filtered.join(',')}';
    await _writeText(cmd);
  }

  Future<void> sendReset() async {
    await _writeText('R');
  }

  Future<void> sendTest() async {
    await _writeText('X');
  }

  /// 옥타브 가이드
  /// 0 = 끄기
  /// 1 = C3~B3
  /// 2 = C4~B4
  /// 3 = C5~B5
  Future<void> sendOctaveGuide(int octave) async {
    if (octave < 0 || octave > 3) {
      debugPrint('sendOctaveGuide skipped: invalid octave $octave');
      return;
    }

    await _writeText('O:$octave');
  }

  /// 옥타브 가이드 끄기
  Future<void> clearOctaveGuide() async {
    await sendOctaveGuide(0);
  }

  /// 정답 피드백: 초록색
  Future<void> sendCorrectFeedback() async {
    await _writeText('C');
  }

  /// 오답 피드백: 빨간색
  /// ESP32 쪽에서 W 누적 횟수에 따라 3번부터 노란색 가이드
  Future<void> sendWrongFeedback() async {
    await _writeText('W');
  }


  // ===== notify 수신 시작/중지 =====
  Future<void> startListening() async {
    if (!isConnected) return;
    if (_notifySub != null) return;

    final qc = _notifyQc;
    if (qc == null) return;

    _notifySub = _ble.subscribeToCharacteristic(qc).listen(
      _handleNotifyMessage,
      onError: (e) {
        debugPrint('BLE notify error: $e');
      },
    );
  }

  Future<void> stopListening() async {
    await _notifySub?.cancel();
    _notifySub = null;
  }

  void _handleNotifyMessage(List<int> value) {
    if (value.isEmpty) return;

    try {
      final text = String.fromCharCodes(value).trim();
      if (text.isEmpty) return;

      debugPrint('BLE NOTIFY <- $text');
      _messageCtrl.add(text);
    } catch (e) {
      debugPrint('BLE notify parse error: $e');
    }
  }

  void dispose() {
    _notifySub?.cancel();
    _connSub?.cancel();
    _messageCtrl.close();
    connectionState.dispose();
  }
}