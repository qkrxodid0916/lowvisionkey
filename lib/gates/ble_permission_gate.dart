import 'package:flutter/material.dart';
import '../ble/services/ble_permission.dart';
import '../ble/screens/ble_permission_screen.dart';
import 'auth_gate.dart';

class BlePermissionGate extends StatefulWidget {
  const BlePermissionGate({super.key});

  @override
  State<BlePermissionGate> createState() => _BlePermissionGateState();
}

class _BlePermissionGateState extends State<BlePermissionGate> {
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    _future = BlePermission.ensureGranted();
  }

  void _retry() {
    setState(() {
      _future = BlePermission.ensureGranted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final granted = snapshot.data == true;
        if (granted) return const AuthGate();

        return BlePermissionScreen(onRetry: _retry);
      },
    );
  }
}