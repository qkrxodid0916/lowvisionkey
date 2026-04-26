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
  String? _lastDeviceId;

  bool _autoReconnect = false;
  bool _reconnecting = false;
  bool _manualDisconnecting = false;

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
    if (isConnected) {
      debugPrint('ESP32 already connected');
      return;
    }

    await disconnect(manual: false);

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
    await disconnect(manual: false);

    _deviceId = deviceId;
    _lastDeviceId = deviceId;
    _autoReconnect = true;
    _manualDisconnecting = false;

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
          debugPrint('ESP32 connected: $deviceId');
          _deviceId = deviceId;

          if (!connectionCompleter.isCompleted) {
            connectionCompleter.complete();
          }
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          debugPrint('ESP32 disconnected');

          _deviceId = null;

          if (!_manualDisconnecting && _autoReconnect) {
            // ignore: discarded_futures
            _tryReconnect();
          }
        }
      },
      onError: (Object e) {
        debugPrint('ESP32 connection error: $e');

        connectionState.value = DeviceConnectionState.disconnected;
        _deviceId = null;

        if (!connectionCompleter.isCompleted) {
          connectionCompleter.completeError(e);
        }

        if (!_manualDisconnecting && _autoReconnect) {
          // ignore: discarded_futures
          _tryReconnect();
        }
      },
    );

    await connectionCompleter.future;

    await _notifySub?.cancel();
    _notifySub = null;

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
          debugPrint('ESP32 notify error: $e');
        },
      );
    }
  }

  Future<void> _tryReconnect() async {
    if (_reconnecting) return;

    final id = _lastDeviceId;
    if (id == null) return;

    _reconnecting = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!_autoReconnect || _manualDisconnecting || isConnected) {
        return;
      }

      debugPrint('ESP32 reconnect try: $id');

      await connectToDeviceId(id);

      debugPrint('ESP32 reconnect success');
    } catch (e) {
      debugPrint('ESP32 reconnect failed: $e');

      if (_autoReconnect && !_manualDisconnecting) {
        await Future.delayed(const Duration(seconds: 2));
        _reconnecting = false;

        // ignore: discarded_futures
        _tryReconnect();
        return;
      }
    } finally {
      _reconnecting = false;
    }
  }

  Future<void> disconnect({bool manual = true}) async {
    if (manual) {
      _manualDisconnecting = true;
      _autoReconnect = false;
      _lastDeviceId = null;
    }

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
    debugPrint('BLE SEND TRY -> $text / connected=$isConnected');

    final c = _writeChar;
    if (c == null || !isConnected) {
      debugPrint('BLE SEND SKIP -> not connected');

      if (_autoReconnect && !_reconnecting && _lastDeviceId != null) {
        // ignore: discarded_futures
        _tryReconnect();
      }

      return;
    }

    try {
      await _ble.writeCharacteristicWithResponse(
        c,
        value: utf8.encode(text),
      );
      debugPrint('BLE SEND OK -> $text');
    } catch (e) {
      debugPrint('BLE SEND FAIL -> $text / $e');

      _deviceId = null;
      connectionState.value = DeviceConnectionState.disconnected;

      if (_autoReconnect) {
        // ignore: discarded_futures
        _tryReconnect();
      }
    }
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
    await disconnect(manual: true);
    await _notifyController.close();
    connectionState.dispose();
  }
}