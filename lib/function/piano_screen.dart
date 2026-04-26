import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../ble/services/ble_esp32_manager.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  final MidiPro _midi = MidiPro();

  int? _sfId;
  bool _loading = true;

  static const int _minMidi = 21;
  static const int _maxMidi = 108;

  static const Set<int> _blackPitchClasses = {1, 3, 6, 8, 10};
  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  bool _isBlack(int midi) => _blackPitchClasses.contains(midi % 12);

  String _label(int midi) {
    final name = _noteNames[midi % 12];
    final octave = (midi ~/ 12) - 1;
    return '$name$octave';
  }

  @override
  void initState() {
    super.initState();
    _initSoundFont();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initSoundFont() async {
    try {
      final int sfId = await _midi.loadSoundfontAsset(
        assetPath: 'assets/sf2/Piano.sf2',
        bank: 0,
        program: 0,
      );

      await _midi.selectInstrument(
        sfId: sfId,
        channel: 0,
        bank: 0,
        program: 0,
      );

      if (!mounted) return;
      setState(() {
        _sfId = sfId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sfId = null;
        _loading = false;
      });
      debugPrint('SoundFont load failed: $e');
    }
  }

  void _play(int midi, {int velocity = 110}) {
    final sfId = _sfId;
    if (sfId != null) {
      _midi.playNote(
        sfId: sfId,
        channel: 0,
        key: midi,
        velocity: velocity,
      );
    }
  }

  void _stop(int midi) {
    final sfId = _sfId;
    if (sfId != null) {
      _midi.stopNote(
        sfId: sfId,
        channel: 0,
        key: midi,
      );
    }
  }

  Future<void> _sendTarget60() async {
    try {
      await BleEsp32Manager.I.sendTarget([60]);
      _showMsg('T:60 전송');
    } catch (e) {
      _showMsg('전송 실패: $e');
    }
  }

  Future<void> _sendChord() async {
    try {
      await BleEsp32Manager.I.sendTarget([60, 64, 67]);
      _showMsg('T:60,64,67 전송');
    } catch (e) {
      _showMsg('전송 실패: $e');
    }
  }

  Future<void> _sendReset() async {
    try {
      await BleEsp32Manager.I.sendReset();
      _showMsg('R 전송');
    } catch (e) {
      _showMsg('전송 실패: $e');
    }
  }

  Future<void> _sendTest() async {
    try {
      await BleEsp32Manager.I.sendTest();
      _showMsg('X 전송');
    } catch (e) {
      _showMsg('전송 실패: $e');
    }
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('피아노 연주 (88키)'),
        actions: [
          ValueListenableBuilder<DeviceConnectionState>(
            valueListenable: BleEsp32Manager.I.connectionState,
            builder: (context, st, _) {
              final connected = st == DeviceConnectionState.connected;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    connected ? 'BLE:ON' : 'BLE:OFF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: connected ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_sfId == null)
          ? const Center(
        child: Text(
          'SoundFont 로딩 실패\nassets/sf2/Piano.sf2 경로와 pubspec assets 설정을 확인하세요.',
          textAlign: TextAlign.center,
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _sendTarget60,
                  child: const Text('T:60'),
                ),
                ElevatedButton(
                  onPressed: _sendChord,
                  child: const Text('T:60,64,67'),
                ),
                ElevatedButton(
                  onPressed: _sendReset,
                  child: const Text('R'),
                ),
                ElevatedButton(
                  onPressed: _sendTest,
                  child: const Text('X'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double w = (constraints.maxWidth / 7.5)
                    .clamp(44.0, isTablet ? 90.0 : 70.0);
                const double gap = 2.0;
                final double whiteStride = w + gap;

                final double h = constraints.maxHeight;
                final double whiteH = h;
                final double blackW = (w * 0.62).clamp(28.0, 60.0);
                final double blackH = (h * 0.62).clamp(140.0, 260.0);

                final List<int> whiteMidis = [];
                final List<_BlackKey> blackKeys = [];

                int whiteIndex = 0;
                for (int midi = _minMidi; midi <= _maxMidi; midi++) {
                  if (_isBlack(midi)) {
                    final leftWhiteIndex =
                    (whiteIndex - 1).clamp(0, 1000000);
                    blackKeys.add(
                      _BlackKey(
                        midi: midi,
                        leftWhiteIndex: leftWhiteIndex,
                      ),
                    );
                  } else {
                    whiteMidis.add(midi);
                    whiteIndex++;
                  }
                }

                final totalWidth =
                    (whiteMidis.length * whiteStride) + gap;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: gap / 2),
                            for (final midi in whiteMidis)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: gap / 2,
                                ),
                                child: _WhiteKey(
                                  width: w,
                                  height: whiteH,
                                  label: _label(midi),
                                  onDown: () => _play(midi),
                                  onUp: () => _stop(midi),
                                  bigText: isTablet,
                                ),
                              ),
                          ],
                        ),
                        for (final bk in blackKeys)
                          Positioned(
                            left: (bk.leftWhiteIndex + 1) *
                                whiteStride -
                                (blackW / 2),
                            top: 0,
                            child: _BlackKeyWidget(
                              width: blackW,
                              height: blackH,
                              label: _label(bk.midi),
                              onDown: () => _play(bk.midi),
                              onUp: () => _stop(bk.midi),
                              bigText: isTablet,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlackKey {
  final int midi;
  final int leftWhiteIndex;

  _BlackKey({
    required this.midi,
    required this.leftWhiteIndex,
  });
}

class _WhiteKey extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool bigText;

  const _WhiteKey({
    required this.width,
    required this.height,
    required this.label,
    required this.onDown,
    required this.onUp,
    required this.bigText,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.2),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: bigText ? 26 : 18),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: bigText ? 18 : 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _BlackKeyWidget extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool bigText;

  const _BlackKeyWidget({
    required this.width,
    required this.height,
    required this.label,
    required this.onDown,
    required this.onUp,
    required this.bigText,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: bigText ? 20 : 14),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: bigText ? 12 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}