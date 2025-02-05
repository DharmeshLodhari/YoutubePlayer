import 'package:Slydo/screens/more_apps/music/models/music_album.dart'
    as MusicAlbum;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';

class MusicPlayer extends ChangeNotifier {
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer.withId(
    "musicPlayer",
  );

  MusicAlbum.MusicAlbum _musicAlbum = MusicAlbum.MusicAlbum(
      audio: [],
      title: "",
      id: null,
      image:
          "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg");

  // ignore: unnecessary_getters_setters
  MusicAlbum.MusicAlbum get musicAlbum => _musicAlbum;

  // ignore: unnecessary_getters_setters
  set musicAlbum(MusicAlbum.MusicAlbum value) {
    _musicAlbum = value;
    notifyListeners();
  }

  AssetsAudioPlayer get audioPlayer => _audioPlayer;

  void toggleShuffle() {
    _audioPlayer.toggleShuffle();
    notifyListeners();
  }
}
