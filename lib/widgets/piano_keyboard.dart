import 'package:flutter/material.dart';

/// Reusable 88-key piano keyboard UI.
/// - Pure UI: emits note on/off callbacks
/// - Supports highlight/pressed states for learning & external MIDI input
/// - ✅ highlightBlinkOn: highlighted key가 색으로 깜빡이도록 지원
class PianoKeyboard extends StatelessWidget {
  final int minMidi;
  final int maxMidi;

  /// Notes to visually emphasize (e.g., "next target note(s)").
  final Set<int> highlightedNotes;

  /// Notes currently pressed (e.g., touch or external MIDI input).
  final Set<int> pressedNotes;

  /// ✅ highlighted key가 깜빡일 때 ON/OFF 상태(외부 애니메이션에서 주기적으로 바꿔줌)
  /// - true: 강한 하이라이트
  /// - false: 약한 하이라이트
  final bool highlightBlinkOn;

  /// Label builder for each MIDI note (e.g., "C4").
  /// If null, labels are hidden.
  final String Function(int midi)? labelBuilder;

  /// Called when a key is pressed.
  final void Function(int midi, int velocity)? onNoteOn;

  /// Called when a key is released.
  final void Function(int midi)? onNoteOff;

  /// Velocity used for touch input when [onNoteOn] is called.
  final int touchVelocity;

  const PianoKeyboard({
    super.key,
    this.minMidi = 21,
    this.maxMidi = 108,
    this.highlightedNotes = const <int>{},
    this.pressedNotes = const <int>{},
    this.highlightBlinkOn = true, // ✅ 기본값: ON(기존 사용처 영향 없음)
    this.labelBuilder,
    this.onNoteOn,
    this.onNoteOff,
    this.touchVelocity = 110,
  });

  static const Set<int> _blackPitchClasses = {1, 3, 6, 8, 10};

  bool _isBlack(int midi) => _blackPitchClasses.contains(midi % 12);

  List<int> _whiteKeys() {
    final whites = <int>[];
    for (int midi = minMidi; midi <= maxMidi; midi++) {
      if (!_isBlack(midi)) whites.add(midi);
    }
    return whites;
  }

  /// Builds black key list with positioning relative to white-key index.
  List<_BlackKey> _blackKeys(List<int> whites) {
    // Map midi -> white index
    final whiteIndexByMidi = <int, int>{};
    for (int i = 0; i < whites.length; i++) {
      whiteIndexByMidi[whites[i]] = i;
    }

    final blacks = <_BlackKey>[];
    for (int midi = minMidi; midi <= maxMidi; midi++) {
      if (_isBlack(midi)) {
        // A black key sits between two white keys: (midi-1) and (midi+1) are white.
        // Use the left white key index for placement.
        final leftWhiteMidi = midi - 1;
        final leftIdx = whiteIndexByMidi[leftWhiteMidi];
        if (leftIdx != null) {
          blacks.add(_BlackKey(midi: midi, leftWhiteIndex: leftIdx));
        }
      }
    }
    return blacks;
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    final whites = _whiteKeys();
    final blacks = _blackKeys(whites);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final totalH = constraints.maxHeight;

        final whiteCount = whites.length;
        final whiteW = totalW / whiteCount;
        final whiteH = totalH;

        final blackW = whiteW * 0.62;
        final blackH = totalH * 0.62;

        // Distance from one white key start to the next (same as whiteW)
        final whiteStride = whiteW;

        return Stack(
          children: [
            // White keys row
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final midi in whites)
                  _WhiteKey(
                    width: whiteW,
                    height: whiteH,
                    label: labelBuilder?.call(midi) ?? '',
                    showLabel: labelBuilder != null,
                    isHighlighted: highlightedNotes.contains(midi),
                    isPressed: pressedNotes.contains(midi),
                    highlightBlinkOn: highlightBlinkOn,
                    onDown: () => onNoteOn?.call(midi, touchVelocity),
                    onUp: () => onNoteOff?.call(midi),
                    bigText: isTablet,
                  ),
              ],
            ),

            // Black keys overlay
            for (final bk in blacks)
              Positioned(
                left: (bk.leftWhiteIndex + 1) * whiteStride - (blackW / 2),
                top: 0,
                child: _BlackKeyWidget(
                  width: blackW,
                  height: blackH,
                  label: labelBuilder?.call(bk.midi) ?? '',
                  showLabel: labelBuilder != null,
                  isHighlighted: highlightedNotes.contains(bk.midi),
                  isPressed: pressedNotes.contains(bk.midi),
                  highlightBlinkOn: highlightBlinkOn,
                  onDown: () => onNoteOn?.call(bk.midi, touchVelocity),
                  onUp: () => onNoteOff?.call(bk.midi),
                  bigText: isTablet,
                ),
              ),
          ],
        );
      },
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
  final bool showLabel;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool bigText;

  final bool isHighlighted;
  final bool isPressed;

  /// ✅ 깜빡임 상태(하이라이트 강/약 전환)
  final bool highlightBlinkOn;

  const _WhiteKey({
    required this.width,
    required this.height,
    required this.label,
    required this.showLabel,
    required this.onDown,
    required this.onUp,
    required this.bigText,
    required this.isHighlighted,
    required this.isPressed,
    required this.highlightBlinkOn,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ “색이 깜빡임”의 핵심: fill 색을 강/약으로 번갈아 주기
    // - pressed가 최우선
    // - highlighted는 그 다음
    final Color normalFill = Colors.white;
    final Color pressedFill = Colors.grey.shade200;

    // 하이라이트: 강/약 2단
    final Color highlightStrongFill = Colors.amber.shade200; // 강
    final Color highlightWeakFill = Colors.amber.shade100;   // 약

    Color fill = normalFill;
    if (isPressed) {
      fill = pressedFill;
    } else if (isHighlighted) {
      fill = highlightBlinkOn ? highlightStrongFill : highlightWeakFill;
    }

    // 테두리도 살짝 리듬감 있게(선택): 강할 때 두껍게
    final double borderWidth = isHighlighted
        ? (highlightBlinkOn ? 3.2 : 2.0)
        : 1.2;

    final Color borderColor = Colors.black;

    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: bigText ? 26 : 18),
        child: showLabel
            ? Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: bigText ? 18 : 14,
            color: Colors.black,
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _BlackKeyWidget extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final bool showLabel;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool bigText;

  final bool isHighlighted;
  final bool isPressed;

  /// ✅ 깜빡임 상태(하이라이트 강/약 전환)
  final bool highlightBlinkOn;

  const _BlackKeyWidget({
    required this.width,
    required this.height,
    required this.label,
    required this.showLabel,
    required this.onDown,
    required this.onUp,
    required this.bigText,
    required this.isHighlighted,
    required this.isPressed,
    required this.highlightBlinkOn,
  });

  @override
  Widget build(BuildContext context) {
    // 검은 건반도 “색이 깜빡임”이 느껴지게:
    // - pressed 최우선
    // - highlighted면 검정 → 진한 회색(강) / 조금 더 연한 회색(약)
    final Color normalFill = Colors.black;
    final Color pressedFill = Colors.grey.shade800;

    final Color highlightStrongFill = Colors.grey.shade700; // 강
    final Color highlightWeakFill = Colors.grey.shade900;   // 약(거의 검정)

    Color fill = normalFill;
    if (isPressed) {
      fill = pressedFill;
    } else if (isHighlighted) {
      fill = highlightBlinkOn ? highlightStrongFill : highlightWeakFill;
    }

    // 하이라이트일 때 테두리 강조(강/약)
    final Border? border = isHighlighted
        ? Border.all(
      color: Colors.white,
      width: highlightBlinkOn ? 2.8 : 1.6,
    )
        : null;

    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          border: border,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          boxShadow: const [
            BoxShadow(blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: bigText ? 20 : 14),
        child: showLabel
            ? Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: bigText ? 12 : 10,
            fontWeight: FontWeight.w700,
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}