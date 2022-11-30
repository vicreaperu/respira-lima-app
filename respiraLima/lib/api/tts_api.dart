
import 'package:app4/helpers/helpers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

enum TtsState { playing, stopped, paused, continued }
class TtsApi {
  static final _flutterTts = FlutterTts();
  static String? language;
  static String? engine;
  static double volume = 1;
  static double pitch = 1.0;
  static double rate = 0.5;
  static bool isCurrentLanguageInstalled = false;
  static int? _inputLength;

  TtsState ttsState = TtsState.stopped;
initTts() {

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    _flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      
        print("Complete");
        ttsState = TtsState.stopped;
      
    });

    _flutterTts.setCancelHandler(() {

        print("Cancel");
        ttsState = TtsState.stopped;
     
    });

    if (isIOS) {
      _flutterTts.setPauseHandler(() {

          print("Paused");
          ttsState = TtsState.paused;
       
      });

      _flutterTts.setContinueHandler(() {
    
          print("Continued");
          ttsState = TtsState.continued;
 
      });
    }

    _flutterTts.setErrorHandler((msg) {

        print("error: $msg");
        ttsState = TtsState.stopped;

    });
  }

  Future<dynamic> _getLanguages() => _flutterTts.getLanguages;

  Future<dynamic> _getEngines() => _flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await _flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await _flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future speakTts(String newVoiceText) async {
    await _flutterTts.setVolume(volume);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.getLanguages.then((value) => print('Languages are: $value'));

      if (newVoiceText.isNotEmpty) {
        await _flutterTts.speak(newVoiceText);
      }
    
  }

 Future _setAwaitOptions() async {
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future stopTts() async {
    var result = await _flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  Future pauseTts() async {
    var result = await _flutterTts.pause();
    if (result == 1)  ttsState = TtsState.paused;
  }
  


  // Future initialize() async{
  //   if(isIOS){ 
  //     await _flutterTts.setSharedInstance(true);
  //     await _flutterTts.setIosAudioCategory(
  //       IosTextToSpeechAudioCategory.ambient,
  //       [
  //         IosTextToSpeechAudioCategoryOptions.allowBluetooth,
  //         IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
  //         IosTextToSpeechAudioCategoryOptions.mixWithOthers
  //       ],
  //       IosTextToSpeechAudioMode.voicePrompt
  //     );
  //      }
  //   await _flutterTts.awaitSpeakCompletion(true);
  //   await _flutterTts.awaitSynthCompletion(true);
  // }
  // Future _speak() async{
  //   var result = await _flutterTts.speak("Hello World");
  //   if (result == 1) setState(() => ttsState = TtsState.playing);
  // }

  // Future _stop() async{
  //     var result = await _flutterTts.stop();
  //     if (result == 1) setState(() => ttsState = TtsState.stopped);
  // }
}