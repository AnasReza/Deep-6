import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Player {
  final AudioCache audioCache = new AudioCache();
  static AudioPlayer audioPlayer;

  playAudio() async {
    audioCache.disableLog();
    audioPlayer = await audioCache.loop('sounds/background.mp3');
  }

  stopAudio() {
    audioPlayer.stop();
    audioCache.clearCache();
  }

  pauseAudio(){
    audioPlayer.pause();
  }

  resumeAudio(){
    audioPlayer.resume();
  }

}
