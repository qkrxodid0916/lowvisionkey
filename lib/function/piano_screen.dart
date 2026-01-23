import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  final MidiPro _midi = MidiPro();

  int? _sfId; // loaded soundfont id
  bool _loading = true;

  // 88 keys: A0(21) ~ C8(108)
  static const int _minMidi = 21;
  static const int _maxMidi = 108;

  static const Set<int> _blackPitchClasses = {1, 3, 6, 8, 10};
  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  bool _isBlack(int midi) => _blackPitchClasses.contains(midi % 12);

  String _label(int midi) {
    final name = _noteNames[midi % 12];
    final octave = (midi ~/ 12) - 1; // MIDI standard: 60 = C4
    return '$name$octave';
  }

  @override
  void initState() {
    super.initState();
    _initSoundFont();
  }

  Future<void> _initSoundFont() async {
    try {
      // assets 경로를 그대로 넣는 예제가 공식 문서에 있습니다.
      // (본인 sf2 파일명/경로에 맞게 변경)
      final int sfId = await _midi.loadSoundfontAsset(
        assetPath: 'assets/sf2/Piano.sf2',
        bank: 0,
        program: 0,
      );

      // 피아노(보통 bank 0, program 0) 를 channel 0에 명시적으로 선택
      await _midi.selectInstrument(sfId: sfId, channel: 0, bank: 0, program: 0);

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
    if (sfId == null) return;
    _midi.playNote(sfId: sfId, channel: 0, key: midi, velocity: velocity);
  }

  void _stop(int midi) {
    final sfId = _sfId;
    if (sfId == null) return;
    _midi.stopNote(sfId: sfId, channel: 0, key: midi);
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('피아노 연주 (88키)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_sfId == null)
          ? const Center(
        child: Text(
          'SoundFont 로딩 실패\nassets/sf2/TimGM6mb.sf2 경로와 pubspec assets 설정을 확인하세요.',
          textAlign: TextAlign.center,
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          // 화면 크기에 따라 키 크기/글씨가 자동으로 적당히 변하도록 계산
          final double w = (constraints.maxWidth / 7.5)
              .clamp(44.0, isTablet ? 90.0 : 70.0);
          const double gap = 2.0;
          final double whiteStride = w + gap;

          final double h = constraints.maxHeight;
          final double whiteH = h;
          final double blackW = (w * 0.62).clamp(28.0, 60.0);
          final double blackH = (h * 0.62).clamp(140.0, 260.0);

          // white/black key 데이터 구성
          final List<int> whiteMidis = [];
          final List<_BlackKey> blackKeys = [];

          int whiteIndex = 0;
          for (int midi = _minMidi; midi <= _maxMidi; midi++) {
            if (_isBlack(midi)) {
              // 직전 흰 건반 인덱스에 붙여 배치
              blackKeys.add(_BlackKey(midi: midi, leftWhiteIndex: whiteIndex - 1));
            } else {
              whiteMidis.add(midi);
              whiteIndex++;
            }
          }

          final totalWidth = (whiteMidis.length * whiteStride) + gap;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  // 흰 건반
                  Row(
                    children: [
                      const SizedBox(width: gap / 2),
                      for (final midi in whiteMidis)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: gap / 2),
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

                  // 검은 건반 (흰 건반 위에 overlay)
                  for (final bk in blackKeys)
                    Positioned(
                      left: (bk.leftWhiteIndex + 1) * whiteStride - (blackW / 2),
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
    );
  }
}

class _BlackKey {
  final int midi;
  final int leftWhiteIndex;
  _BlackKey({required this.midi, required this.leftWhiteIndex});
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
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
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
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          boxShadow: const [
            BoxShadow(blurRadius: 4, offset: Offset(0, 2)),
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
