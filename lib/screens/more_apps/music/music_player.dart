import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';

class MusicPlayer extends ChangeNotifier {
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer.withId(
    "musicPlayer",
  );

  AssetsAudioPlayer get audioPlayer => _audioPlayer;

  void toggleShuffle() {
    _audioPlayer.toggleShuffle();
    notifyListeners();
  }
}
