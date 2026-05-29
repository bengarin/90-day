import 'package:flutter_tts/flutter_tts.dart';

/// Tiny TTS wrapper. Uses the Android on-device TTS engine — it is offline
/// on most modern Android devices. If TTS isn't available, calls just no-op.
class Tts {
  static final Tts instance = Tts._();
  Tts._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensure() async {
    if (_ready) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {
      // fail silently — we degrade gracefully if no TTS engine.
    }
    _ready = true;
  }

  Future<void> speakEn(String text) async {
    await _ensure();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {/* ignore */}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {/* ignore */}
  }
}
