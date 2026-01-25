import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleMidiManager {
  BleMidiManager._();
  static final BleMidiManager I = BleMidiManager._();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // BLE-MIDI 표준 UUID
  static final Uuid midiService =
  Uuid.parse('03B80E5A-EDE8-4B33-A751-6CE34EC4C700');
  static final Uuid midiChar =
  Uuid.parse('7772E5DB-3868-4112-A1A9-F2669D106BF3');

  String? _deviceId;
  StreamSubscription<ConnectionStateUpdate>? _connSub;

  final ValueNotifier<DeviceConnectionState> connectionState =
  ValueNotifier(DeviceConnectionState.disconnected);

  String? get deviceId => _deviceId;
  bool get isConnected => connectionState.value == DeviceConnectionState.connected;

  QualifiedCharacteristic? get _qc {
    final id = _deviceId;
    if (id == null) return null;
    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: midiService,
      characteristicId: midiChar,
    );
  }

  Future<void> connect(String deviceId) async {
    // 이미 같은 기기 연결 중/연결됨이면 무시
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
          (u) {
        connectionState.value = u.connectionState;
        if (u.connectionState == DeviceConnectionState.disconnected) {
          // 끊기면 deviceId는 유지해도 되지만, 여기선 깔끔하게 비움
          _deviceId = null;
        }
      },
      onError: (_) {
        connectionState.value = DeviceConnectionState.disconnected;
        _deviceId = null;
      },
    );
  }

  Future<void> disconnect() async {
    await _connSub?.cancel();
    _connSub = null;
    _deviceId = null;
    connectionState.value = DeviceConnectionState.disconnected;
  }

  /// BLE-MIDI 패킷: timestamp header(2바이트) + MIDI message bytes
  List<int> _wrapBleMidi(List<int> midiBytes) {
    final ts = DateTime.now().millisecondsSinceEpoch % 8192; // 13-bit timestamp
    final header1 = 0x80 | ((ts >> 7) & 0x3F); // 0b10xxxxxx
    final header2 = 0x80 | (ts & 0x7F);        // 0b1xxxxxxx
    return <int>[header1, header2, ...midiBytes];
  }

  Future<void> _write(List<int> bleMidiPacket) async {
    final qc = _qc;
    if (qc == null || !isConnected) return;

    // Write Without Response
    await _ble.writeCharacteristicWithoutResponse(
      qc,
      value: bleMidiPacket,
    );
  }

  Future<void> sendNoteOn(int midiNote, {int velocity = 110, int channel = 0}) async {
    if (midiNote < 0 || midiNote > 127) return;
    velocity = velocity.clamp(0, 127);
    channel = channel.clamp(0, 15);

    final status = 0x90 | channel;
    final msg = <int>[status, midiNote, velocity];
    await _write(_wrapBleMidi(msg));
  }

  Future<void> sendNoteOff(int midiNote, {int channel = 0}) async {
    if (midiNote < 0 || midiNote > 127) return;
    channel = channel.clamp(0, 15);

    // NOTE OFF는 0x80도 가능하지만, 0x90 velocity 0도 널리 사용
    final status = 0x90 | channel;
    final msg = <int>[status, midiNote, 0];
    await _write(_wrapBleMidi(msg));
  }
}
