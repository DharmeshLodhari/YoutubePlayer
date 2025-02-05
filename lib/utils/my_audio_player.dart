import 'package:assets_audio_player/assets_audio_player.dart';

class MyAudioPlayer {
  AssetsAudioPlayer? audioPlayer;

  Future<void> playAudio(String path) async {
    audioPlayer = AssetsAudioPlayer();
    audioPlayer!.open(
      Audio(path),
      pitch: 1.0,
      volume: 0.9,
      loopMode: LoopMode.single,
    );
  }

  Future<void> stopAudio() async {
    audioPlayer!.stop();
    // audioPlayer!.dispose();
  }
}
