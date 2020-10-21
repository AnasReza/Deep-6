import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class ClickPlayer {
  AudioCache audioCache = new AudioCache();
  AudioPlayer audioPlayer = new AudioPlayer();

  playClick() {
    audioCache.disableLog();
    audioCache.play('sounds/click.mp3');
  }

  stopClick(){
    audioCache.disableLog();
    audioCache.clearCache();
  }

}
