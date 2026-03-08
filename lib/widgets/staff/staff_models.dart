import 'package:flutter/material.dart';

enum StaffClef { treble, bass }
enum Accidental { none, sharp, flat, natural }

class StaffGlyph {
  final int diatonicStepFromRef; // 0 기준에서 선/칸 이동 (1 = 한 칸/선 이동)
  final Accidental accidental;
  const StaffGlyph({
    required this.diatonicStepFromRef,
    this.accidental = Accidental.none,
  });
}

class StaffStyle {
  final Color lineColor;
  final Color noteColor;
  final Color accidentalColor;

  final double lineWidth;
  final double staffGap;      // 오선지 줄 간격
  final double noteWidth;
  final double noteHeight;

  final double horizontalPadding;
  final double noteXFactor;   // 0~1 (가로 위치 비율)

  const StaffStyle({
    required this.lineColor,
    required this.noteColor,
    required this.accidentalColor,
    this.lineWidth = 2,
    this.staffGap = 10,
    this.noteWidth = 16,
    this.noteHeight = 12,
    this.horizontalPadding = 16,
    this.noteXFactor = 0.5,
  });
}

String accidentalText(Accidental a) {
  switch (a) {
    case Accidental.sharp:
      return '#';
    case Accidental.flat:
      return 'b';
    case Accidental.natural:
      return '♮';
    case Accidental.none:
      return '';
  }
}