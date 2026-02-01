const List<String> solfege = [
  '도', '도#', '레', '레#', '미', '파',
  '파#', '솔', '솔#', '라', '라#', '시'
];

String midiToSolfege(int midi) {
  return solfege[midi % 12];
}