import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  FlutterTts flutterTts = FlutterTts();
  speak(String _text, String _language) async {
    await flutterTts.setSharedInstance(true);
    await flutterTts.setLanguage(_language);
    await flutterTts.setSpeechRate(0.54);
    await flutterTts.setPitch(1);
    await flutterTts.speak(_text);
  }
}
