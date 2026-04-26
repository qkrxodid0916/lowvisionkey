import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  final ValueNotifier<DeviceConnectionState> connectionState =
  ValueNotifier(DeviceConnectionState.disconnected);

  String? _deviceId;

  bool get isConnected =>
      connectionState.value == DeviceConnectionState.connected &&
          _deviceId != null;

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

    await connectToDeviceId(found.id);
  }

  Future<void> connectToDeviceId(String deviceId) async {
    await disconnect();

    _deviceId = deviceId;
    connectionState.value = DeviceConnectionState.connecting;

    final connectionCompleter = Completer<void>();

    _connSub = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    )
        .listen(
          (update) {
        connectionState.value = update.connectionState;

        if (update.connectionState == DeviceConnectionState.connected) {
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.complete();
          }
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          _deviceId = null;
        }
      },
      onError: (Object e) {
        connectionState.value = DeviceConnectionState.disconnected;
        _deviceId = null;
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

    _deviceId = null;
    connectionState.value = DeviceConnectionState.disconnected;
  }

  Future<void> sendRaw(String text) async {
    final c = _writeChar;
    if (c == null || !isConnected) {
      throw StateError('ESP32가 연결되지 않았어요.');
    }

    await _ble.writeCharacteristicWithResponse(
      c,
      value: utf8.encode(text),
    );
  }

  Future<void> sendTarget(Iterable<int> midiNotes) async {
    final unique = <int>[];
    for (final n in midiNotes) {
      if (n < 48 || n > 83) continue;
      if (!unique.contains(n)) unique.add(n);
      if (unique.length >= 6) break;
    }

    unique.sort();
    if (unique.isEmpty) return;

    await sendRaw('T:${unique.join(',')}');
  }

  Future<void> sendWrong() async {
    await sendRaw('W');
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
    connectionState.dispose();
  }
}