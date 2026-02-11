import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService I = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setSharedInstance(true);
    _inited = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
