import 'package:flutter/material.dart';
import 'staff_models.dart';
import 'staff_mapper.dart';

class StaffWidget extends StatelessWidget {
  final int midi;
  final StaffClef clef;
  final StaffStyle style;
  final StaffSettings settings;

  const StaffWidget({
    super.key,
    required this.midi,
    required this.clef,
    required this.style,
    this.settings = const StaffSettings(),
  });

  @override
  Widget build(BuildContext context) {
    final glyph = midiToStaffGlyph(midi: midi, clef: clef, settings: settings);
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _StaffPainter(glyph: glyph, clef: clef, style: style),
      ),
    );
  }
}

class _StaffPainter extends CustomPainter {
  final StaffGlyph glyph;
  final StaffClef clef;
  final StaffStyle style;

  _StaffPainter({
    required this.glyph,
    required this.clef,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = style.horizontalPadding;
    final right = size.width - style.horizontalPadding;
    final centerY = size.height / 2;

    final linePaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke;

    // 오선 5줄
    for (int i = -2; i <= 2; i++) {
      final y = centerY + i * style.staffGap;
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    // 노트 위치: diatonicStep 1칸 이동 = staffGap/2
    final stepHeight = style.staffGap / 2;
    final noteY = centerY - glyph.diatonicStepFromRef * stepHeight;

    final noteX = size.width * style.noteXFactor;

    // 보조선(ledger line) 간단 처리
    final topLineY = centerY - 2 * style.staffGap;
    final bottomLineY = centerY + 2 * style.staffGap;

    final ledgerPaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth;

    if (noteY < topLineY - style.staffGap) {
      for (double y = topLineY - style.staffGap; y >= noteY; y -= style.staffGap) {
        canvas.drawLine(Offset(noteX - 18, y), Offset(noteX + 18, y), ledgerPaint);
      }
    } else if (noteY > bottomLineY + style.staffGap) {
      for (double y = bottomLineY + style.staffGap; y <= noteY; y += style.staffGap) {
        canvas.drawLine(Offset(noteX - 18, y), Offset(noteX + 18, y), ledgerPaint);
      }
    }

    // 임시표(#/b/♮) — 지금은 none이라 안 보이지만, 구조만 준비
    final acc = accidentalText(glyph.accidental);
    if (acc.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: acc,
          style: TextStyle(
            color: style.accidentalColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(noteX - 28, noteY - tp.height / 2));
    }

    // 노트헤드
    final notePaint = Paint()
      ..color = style.noteColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(noteX, noteY),
        width: style.noteWidth,
        height: style.noteHeight,
      ),
      notePaint,
    );

    // (선택) 음자리표 표시: 나중에 예쁜 아이콘으로 바꿀 수 있게 여기만 수정
    final clefText = (clef == StaffClef.treble) ? '𝄞' : '𝄢';
    final clefPainter = TextPainter(
      text: TextSpan(
        text: clefText,
        style: TextStyle(color: style.lineColor, fontSize: 28),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    clefPainter.paint(canvas, Offset(left - 4, topLineY - 18));
  }

  @override
  bool shouldRepaint(covariant _StaffPainter oldDelegate) {
    return oldDelegate.glyph.diatonicStepFromRef != glyph.diatonicStepFromRef ||
        oldDelegate.glyph.accidental != glyph.accidental ||
        oldDelegate.clef != clef ||
        oldDelegate.style != style;
  }
}