import 'staff_models.dart';

class StaffSettings {
  final bool allowAccidentals; // 나중에 true로 켜면 #/b 반환하도록 확장
  final bool preferSharps;
  const StaffSettings({
    this.allowAccidentals = false,
    this.preferSharps = true,
  });
}

// Clef별 기준(refMidi): 여기만 바꾸면 스태프 전체 위치가 바뀜
int refMidiForClef(StaffClef clef) {
  switch (clef) {
    case StaffClef.treble:
      return 64; // E4 (MVP 기준)
    case StaffClef.bass:
      return 43; // G2 (MVP 기준)
  }
}

// pitch class -> 자연음 PC로 스냅 (반음은 일단 무시)
int _pcToNaturalPc(int pc) {
  const naturals = [0, 2, 4, 5, 7, 9, 11]; // C D E F G A B
  int best = naturals.first;
  int bestDiff = 99;
  for (final n in naturals) {
    final diff = (pc - n).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      best = n;
    }
  }
  return best;
}

int _naturalLetterFromPc(int naturalPc) {
  // C D E F G A B => 0..6
  switch (naturalPc) {
    case 0: return 0;  // C
    case 2: return 1;  // D
    case 4: return 2;  // E
    case 5: return 3;  // F
    case 7: return 4;  // G
    case 9: return 5;  // A
    case 11: return 6; // B
    default: return 0;
  }
}

StaffGlyph midiToStaffGlyph({
  required int midi,
  required StaffClef clef,
  StaffSettings settings = const StaffSettings(),
}) {
  // 지금은 초심자 모드: 반음 표기/출제 없음 -> accidental none
  // 나중에 allowAccidentals=true일 때 여기만 확장하면 됨.

  final pc = midi % 12;
  final naturalPc = _pcToNaturalPc(pc);
  final letter = _naturalLetterFromPc(naturalPc);
  final octave = (midi ~/ 12) - 1;

  final refMidi = refMidiForClef(clef);
  final refPc = refMidi % 12;
  final refNaturalPc = _pcToNaturalPc(refPc);
  final refLetter = _naturalLetterFromPc(refNaturalPc);
  final refOctave = (refMidi ~/ 12) - 1;

  final idx = octave * 7 + letter;
  final refIdx = refOctave * 7 + refLetter;

  return StaffGlyph(diatonicStepFromRef: idx - refIdx, accidental: Accidental.none);
}