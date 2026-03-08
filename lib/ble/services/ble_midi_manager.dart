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

  /// ✅ 채널 규칙(0-based)
  /// - 입력(키보드 → ESP32 → 앱): channel 0
  /// - 가이드(앱 → ESP32): channel 1
  static const int inputChannel = 0;
  static const int guideChannel = 1;

  /// ✅ 수신에서 “판정용으로 받을 채널”(기본: inputChannel)
  int listenChannel = inputChannel;

  String? _deviceId;
  StreamSubscription<ConnectionStateUpdate>? _connSub;

  final ValueNotifier<DeviceConnectionState> connectionState =
  ValueNotifier(DeviceConnectionState.disconnected);

  String? get deviceId => _deviceId;
  bool get isConnected =>
      connectionState.value == DeviceConnectionState.connected;

  QualifiedCharacteristic? get _qc {
    final id = _deviceId;
    if (id == null) return null;
    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: midiService,
      characteristicId: midiChar,
    );
  }

  // ===== 수신 스트림 =====
  final StreamController<int> _noteOnCtrl = StreamController<int>.broadcast();
  final StreamController<int> _noteOffCtrl = StreamController<int>.broadcast();

  Stream<int> get noteOnStream => _noteOnCtrl.stream;
  Stream<int> get noteOffStream => _noteOffCtrl.stream;

  StreamSubscription<List<int>>? _notifySub;

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
          _deviceId = null;
          stopListening();
        }
      },
      onError: (_) {
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

  /// BLE-MIDI 패킷: timestamp header(2바이트) + MIDI message bytes
  List<int> _wrapBleMidi(List<int> midiBytes) {
    final ts = DateTime.now().millisecondsSinceEpoch % 8192; // 13-bit timestamp
    final header1 = 0x80 | ((ts >> 7) & 0x3F); // 0b10xxxxxx
    final header2 = 0x80 | (ts & 0x7F); // 0b1xxxxxxx
    return <int>[header1, header2, ...midiBytes];
  }

  Future<void> _write(List<int> bleMidiPacket) async {
    final qc = _qc;
    if (qc == null || !isConnected) return;

    await _ble.writeCharacteristicWithoutResponse(
      qc,
      value: bleMidiPacket,
    );
  }

  Future<void> sendNoteOn(
      int midiNote, {
        int velocity = 110,
        int channel = 0,
      }) async {
    if (midiNote < 0 || midiNote > 127) return;
    velocity = velocity.clamp(0, 127);
    channel = channel.clamp(0, 15);

    final status = 0x90 | channel;
    final msg = <int>[status, midiNote, velocity];
    await _write(_wrapBleMidi(msg));
  }

  Future<void> sendNoteOff(
      int midiNote, {
        int channel = 0,
      }) async {
    if (midiNote < 0 || midiNote > 127) return;
    channel = channel.clamp(0, 15);

    // NOTE OFF는 0x80도 가능하지만, 0x90 velocity 0도 널리 사용
    final status = 0x90 | channel;
    final msg = <int>[status, midiNote, 0];
    await _write(_wrapBleMidi(msg));
  }

  /// ✅ Control Change 전송 (MIDI CC)
  Future<void> sendControlChange(
      int controller,
      int value, {
        int channel = 0,
      }) async {
    controller = controller.clamp(0, 127);
    value = value.clamp(0, 127);
    channel = channel.clamp(0, 15);

    final status = 0xB0 | channel;
    final msg = <int>[status, controller, value];
    await _write(_wrapBleMidi(msg));
  }

  /// ✅ 유지보수형 All Notes Off
  /// - 표준 CC(123/120) 우선
  /// - ESP32가 CC를 무시하는 경우 fallbackSweep=true로 note-off sweep 추가
  Future<void> sendAllNotesOff({
    int channel = 0,
    bool fallbackSweep = false,
  }) async {
    channel = channel.clamp(0, 15);

    // 표준 MIDI CC
    await sendControlChange(123, 0, channel: channel); // All Notes Off
    await sendControlChange(120, 0, channel: channel); // All Sound Off

    if (!fallbackSweep) return;

    for (int m = 0; m < 128; m++) {
      unawaited(sendNoteOff(m, channel: channel));
    }
  }

  // ===== 수신 시작/중지 =====

  Future<void> startListening() async {
    if (!isConnected) return;
    final qc = _qc;
    if (qc == null) return;

    // 이미 구독 중이면 무시
    if (_notifySub != null) return;

    _notifySub = _ble.subscribeToCharacteristic(qc).listen(
      _handleBleMidiPacket,
      onError: (e) {
        debugPrint('BLE MIDI subscribe error: $e');
      },
    );
  }

  Future<void> stopListening() async {
    await _notifySub?.cancel();
    _notifySub = null;
  }

  // ===== BLE-MIDI 파싱 (NoteOn/NoteOff만) =====

  void _handleBleMidiPacket(List<int> value) {
    if (value.isEmpty) return;

    // 일반적으로 앞 2바이트는 timestamp header
    int i = 0;
    if (value.length >= 2 &&
        (value[0] & 0x80) != 0 &&
        (value[1] & 0x80) != 0) {
      i = 2;
    }

    int? runningStatus;

    while (i < value.length) {
      final b = value[i];

      // 후보 status (MSB=1)
      if ((b & 0x80) != 0) {
        final status = b;
        final dataLen = _dataLenForStatus(status);

        // 유효한 status인지 검증: 뒤 data bytes가 <0x80 이어야 함
        if (dataLen != null &&
            i + dataLen < value.length &&
            _allDataBytes(value, i + 1, dataLen)) {
          runningStatus = status;
          _emitIfNoteMessage(status, value.sublist(i + 1, i + 1 + dataLen));
          i += 1 + dataLen;
          continue;
        }

        // 위 조건을 못 맞추면 이 바이트는 timestamp일 가능성이 큼 → skip
        i += 1;
        continue;
      }

      // data byte(러닝 스테이터스)
      if (runningStatus == null) {
        i += 1;
        continue;
      }

      final dataLen = _dataLenForStatus(runningStatus);
      if (dataLen == null) {
        i += 1;
        continue;
      }

      if (dataLen == 1) {
        if (b < 0x80) {
          _emitIfNoteMessage(runningStatus, [b]);
        }
        i += 1;
        continue;
      }

      // dataLen == 2
      if (i + 1 < value.length &&
          value[i] < 0x80 &&
          value[i + 1] < 0x80) {
        _emitIfNoteMessage(runningStatus, [value[i], value[i + 1]]);
        i += 2;
        continue;
      }

      i += 1;
    }
  }

  int? _dataLenForStatus(int status) {
    final type = status & 0xF0;
    if (type >= 0x80 && type <= 0xE0) {
      if (type == 0xC0 || type == 0xD0) return 1; // Program/Channel pressure
      return 2; // Note/CC/Pitch 등
    }
    return null; // SysEx 등은 여기선 무시
  }

  bool _allDataBytes(List<int> v, int start, int len) {
    for (int k = 0; k < len; k++) {
      if (v[start + k] >= 0x80) return false;
    }
    return true;
  }

  void _emitIfNoteMessage(int status, List<int> data) {
    final type = status & 0xF0;
    final ch = status & 0x0F;

    // ✅ “입력 채널”만 noteOn/off 스트림으로 내보냄
    if (ch != listenChannel) return;

    if (type == 0x90 && data.length >= 2) {
      final note = data[0];
      final vel = data[1];
      if (vel == 0) {
        _noteOffCtrl.add(note);
      } else {
        _noteOnCtrl.add(note);
      }
      return;
    }

    if (type == 0x80 && data.length >= 2) {
      final note = data[0];
      _noteOffCtrl.add(note);
      return;
    }
  }
}