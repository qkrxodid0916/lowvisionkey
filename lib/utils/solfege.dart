const List<String> noteLetters = [
  'C', 'C#', 'D', 'D#', 'E', 'F',
  'F#', 'G', 'G#', 'A', 'A#', 'B'
];

String midiToLetter(int midi) {
  return noteLetters[midi % 12];
}

String midiToDisplayName(int midi) {
  final letter = midiToLetter(midi);

  if (midi >= 72 && midi <= 83) {
    return 'hi $letter';
  }

  if (midi >= 48 && midi <= 59) {
    return 'low $letter';
  }

  return letter;
}

String midiToOctaveName(int midi) {
  final letter = midiToLetter(midi);
  final octave = (midi ~/ 12) - 1;
  return '$letter$octave';
}