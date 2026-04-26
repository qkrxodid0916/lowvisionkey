import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../services/ble_esp32_manager.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  final Map<String, DiscoveredDevice> _devices = {};

  bool _scanning = false;
  String _status = 'IDLE';

  @override
  void initState() {
    super.initState();
    BleEsp32Manager.I.connectionState.addListener(_onConnStateChanged);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    BleEsp32Manager.I.connectionState.removeListener(_onConnStateChanged);
    super.dispose();
  }

  void _onConnStateChanged() {
    final st = BleEsp32Manager.I.connectionState.value;
    if (!mounted) return;

    setState(() {
      switch (st) {
        case DeviceConnectionState.connecting:
          _status = 'CONNECTING';
          break;
        case DeviceConnectionState.connected:
          _status = 'CONNECTED';
          break;
        case DeviceConnectionState.disconnected:
          _status = 'DISCONNECTED';
          break;
        case DeviceConnectionState.disconnecting:
          _status = 'DISCONNECTING';
          break;
      }
    });
  }

  void _startScan() {
    _devices.clear();
    _scanSub?.cancel();

    setState(() {
      _status = 'SCANNING';
      _scanning = true;
    });

    _scanSub = _ble
        .scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    )
        .listen(
          (d) {
        if (!mounted) return;
        setState(() {
          _devices[d.id] = d;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _status = 'SCAN ERROR';
          _scanning = false;
        });
      },
    );
  }

  void _stopScan() {
    _scanSub?.cancel();
    setState(() {
      _scanning = false;
      _status = 'IDLE';
    });
  }

  Future<void> _connect(DiscoveredDevice d) async {
    _stopScan();
    setState(() => _status = 'CONNECTING');

    try {
      await BleEsp32Manager.I.connectToDeviceId(d.id);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('연결 완료'),
          content: Text('${d.name.isEmpty ? "기기" : d.name}에 연결되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _status = 'CONNECT FAILED');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('연결 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _devices.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE 기기 선택'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            _status,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final d = list[i];
                final name = d.name.isEmpty ? '(unknown)' : d.name;

                return ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text('RSSI: ${d.rssi}'),
                  onTap: () => _connect(d),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _scanning ? null : _startScan,
                      child: const Text(
                        'SCAN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      onPressed: _scanning ? _stopScan : null,
                      child: const Text(
                        'STOP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}