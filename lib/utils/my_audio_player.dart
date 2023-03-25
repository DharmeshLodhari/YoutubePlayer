import 'package:assets_audio_player/assets_audio_player.dart';

class MyAudioPlayer {
  AssetsAudioPlayer? audioPlayer;

  playAudio(String path) {
    audioPlayer = AssetsAudioPlayer();
    audioPlayer!.open(Audio(path), pitch: 1.0, volume: 0.2);
  }

  stopAudio() async {
    audioPlayer!.stop();
  }
}

// class MyAudioPlayer {
//   AudioPlayer? audioPlayer;
//
//   Future<void> playAudio(String audioPath) async {
//     audioPlayer = AudioPlayer();
//     await audioPlayer!.play(audioPath, isLocal: true);
//   }
//
//   Future<void> stopAudio() async {
//     await audioPlayer!.stop();
//   }
// }
