import 'package:assets_audio_player/assets_audio_player.dart';

class MyAudioPlayer {
  AssetsAudioPlayer? audioPlayer;

  playAudio(String path) {
    audioPlayer = AssetsAudioPlayer();
    audioPlayer!.open(
      Audio(path),
      pitch: 1.0,
      volume: 0.9,
      loopMode: LoopMode.single,
    );
  }

  stopAudio() async {
    audioPlayer!.stop();
    // audioPlayer!.dispose();
  }
}
