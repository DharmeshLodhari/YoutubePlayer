import 'package:Slydo/screens/more_apps/music/models/partial_music_item.dart';
import 'package:Slydo/services/auth.dart';

import 'models/music_album.dart';
import 'models/partial_celebrity_item.dart';
import 'models/partial_music_album.dart';

class MusicAuthService extends AuthService {
  Future<List<String>> getLocation() async {
    final List<String> list = [
      "Lagos",
      "Kano",
      "Ibadan",
      "Benin City",
      "Abuja"
    ];
    return list;
  }

  Future<List<PartialMusicItem>> getMusicItemList() async {
    final List<String> imgList = [
      "https://storage.googleapis.com/assets-pam-blog/2018/12/Dj-Neptune-Greatness.jpg",
      "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
      "https://i.ytimg.com/vi/MuXtUDQ8Sug/maxresdefault.jpg",
      "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g"
    ];

    final partialMusicItem = imgList
        .map(
          (image) => PartialMusicItem.fromJson({
            "id": 1,
            "name": "Run it down",
            "currency": "NGN",
            "price": "34.00",
            "poster": image,
          }),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return partialMusicItem;
  }

  Future<List<PartialCelebrityItem>> getCelebrity() async {
    final List<Map<String, String>> singerList = [
      {
        "name": "Wizkid",
        "image":
            "https://www.gstatic.com/tv/thumb/persons/1045961/1045961_v9_ba.jpg"
      },
      {
        "name": "Davido",
        "image":
            "https://www.grammy.com/sites/com/files/styles/news_detail_header/public/frankfieber_20181022_8-sm-scaled.jpg?itok=OdyzBPFd"
      },
      {
        "name": "Tiwa Savage",
        "image":
            "https://upload.wikimedia.org/wikipedia/commons/f/fa/Tiwa_Savage%27s_studio_portrait.jpg"
      },
      {
        "name": "Sinach",
        "image":
            "https://kgo.googleusercontent.com/profile_vrt_raw_bytes_1587515408_10954.jpg"
      },
    ];

    final partialCelebrityItem = singerList
        .map(
          (element) => PartialCelebrityItem.fromJson(
              {"name": element["name"], "image": element["image"]}),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return partialCelebrityItem;
  }

  Future<List<PartialMusicAlbum>> getPartialMusicAlbumList() async {
    final partialMusicAlbum = List.generate(
      10,
      (index) => PartialMusicAlbum.fromJson({
        "id": 1,
        "name": "THE ERIGMA II",
        "poster":
            "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
      }),
    ).toList();
    await Future.delayed(const Duration(seconds: 1));
    return partialMusicAlbum;
  }

  Future<MusicAlbum> getMusicAlbum() async {
    final map = {
      "id": 1,
      "title": "Twice As Tall Album",
      "image":
          "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg",
      "audio": [
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f133a23f344e2e96b275800d505011f54a4dc20f/Burna-Boy-Monsters-You-Made-ft-Chris-Martin.mp3",
          "metas": {
            "id": "1",
            "title": "Monsters You Made",
            "artist": "Burna Boy",
            "album": "Twice As Tall Album",
            "image":
                "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/673e733fe5e055fb5d3d1e35500e0f4991d4faad/Martin Garrix - Animals (Original Mix).mp3",
          "metas": {
            "id": "2",
            "title": "Animals (Original Mix)",
            "artist": "Martin Garrix",
            "album": "Animals",
            "image":
                "https://i.pinimg.com/originals/ce/de/a5/cedea5f757301128e39ebf13a36d3596.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/ab04b116c1c257db491490aa8159fff960edeb55/Olamide-Wizkid-Kana.mp3",
          "metas": {
            "id": "3",
            "title": "Kana",
            "artist": "Olamide & Wizkid",
            "album": "Olamide & Wizkid",
            "image":
                "https://www.naijavibes.com/wp-content/uploads/2018/05/Olamide-Kana-Artwork.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Tekno-Sudden.mp3",
          "metas": {
            "id": "4",
            "title": "Sudden",
            "artist": "Tekno",
            "album": "Singles",
            "image": "https://trendybeatz.com/images/tekno-sudden-artwork.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Davido_ChrisBrown.mp3",
          "metas": {
            "id": "5",
            "title": "Blow My Mind",
            "artist": "Davido",
            "album": "Blow My Mind ft Chris Brown",
            "image": "https://trendybeatz.com/images/Davido_ChrisBrown.jpg"
          }
        }
      ]
    };

    final MusicAlbum album = MusicAlbum.fromJson(map);

    await Future.delayed(const Duration(seconds: 2));
    return album;
  }

  Future<void> addToWishList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
