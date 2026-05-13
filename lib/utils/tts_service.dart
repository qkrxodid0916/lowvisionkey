import 'dart:io';
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

    // ✅ iOS에서 MIDI 사운드와 TTS가 동시에 재생되도록 설정
    if (Platform.isIOS) {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }

    _inited = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
