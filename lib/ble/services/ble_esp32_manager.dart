import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleEsp32Manager {
  BleEsp32Manager._();

  static final BleEsp32Manager I = BleEsp32Manager._();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  static const String deviceName = 'ESP32-PianoLED';

  static final Uuid serviceUuid =
  Uuid.parse('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');

  static final Uuid writeUuid =
  Uuid.parse('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

  static final Uuid notifyUuid =
  Uuid.parse('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  final StreamController<String> _notifyController =
  StreamController<String>.broadcast();

  Stream<String> get notifyStream => _notifyController.stream;

  String? _deviceId;
  bool _connected = false;

  bool get isConnected => _connected && _deviceId != null;

  QualifiedCharacteristic? get _writeChar {
    final id = _deviceId;
    if (id == null) return null;

    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: serviceUuid,
      characteristicId: writeUuid,
    );
  }

  QualifiedCharacteristic? get _notifyChar {
    final id = _deviceId;
    if (id == null) return null;

    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: serviceUuid,
      characteristicId: notifyUuid,
    );
  }

  Future<void> scanAndConnect({
    Duration scanTimeout = const Duration(seconds: 5),
    Duration connectTimeout = const Duration(seconds: 10),
  }) async {
    await disconnect();

    final completer = Completer<DiscoveredDevice>();

    _scanSub = _ble
        .scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    )
        .listen(
          (device) {
        if (device.name == deviceName) {
          if (!completer.isCompleted) {
            completer.complete(device);
          }
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
    );

    final found = await completer.future.timeout(scanTimeout);

    await _scanSub?.cancel();
    _scanSub = null;

    _deviceId = found.id;

    final connectionCompleter = Completer<void>();

    _connSub = _ble
        .connectToDevice(
      id: found.id,
      connectionTimeout: connectTimeout,
    )
        .listen(
          (update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          _connected = true;
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.complete();
          }
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          _connected = false;
        }
      },
      onError: (Object e) {
        _connected = false;
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.completeError(e);
        }
      },
    );

    await connectionCompleter.future;

    final notifyChar = _notifyChar;
    if (notifyChar != null) {
      _notifySub = _ble.subscribeToCharacteristic(notifyChar).listen(
            (data) {
          final text = utf8.decode(data, allowMalformed: true).trim();
          if (text.isNotEmpty) {
            _notifyController.add(text);
          }
        },
        onError: (Object e) {
          // 필요하면 디버그 로그 추가
        },
      );
    }
  }

  Future<void> disconnect() async {
    await _scanSub?.cancel();
    _scanSub = null;

    await _notifySub?.cancel();
    _notifySub = null;

    await _connSub?.cancel();
    _connSub = null;

    _connected = false;
    _deviceId = null;
  }

  Future<void> sendRaw(String text) async {
    final c = _writeChar;
    if (c == null || !_connected) {
      throw StateError('ESP32가 연결되지 않았어요.');
    }

    await _ble.writeCharacteristicWithResponse(
      c,
      value: utf8.encode(text),
    );
  }

  Future<void> sendTarget(Iterable<int> midiNotes) async {
    final list = midiNotes.toList()..sort();
    if (list.isEmpty) return;

    await sendRaw('T:${list.join(',')}');
  }

  Future<void> sendInput(Iterable<int> midiNotes) async {
    final list = midiNotes.toList()..sort();
    if (list.isEmpty) return;

    await sendRaw('I:${list.join(',')}');
  }

  Future<void> sendReset() async {
    await sendRaw('R');
  }

  Future<void> sendTest() async {
    await sendRaw('X');
  }

  Future<void> dispose() async {
    await disconnect();
    await _notifyController.close();
  }
}