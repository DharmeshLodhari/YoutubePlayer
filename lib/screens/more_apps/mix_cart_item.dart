import 'package:Slydo/screens/more_apps/movies/models/MovieItem.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

import 'cart_tiles.dart';
import 'music/models/music_album.dart';

class MixCartItem extends StatefulWidget {
  @override
  _MixCartItemState createState() => _MixCartItemState();
}

class _MixCartItemState extends State<MixCartItem> {
  Widget audioTile = Container();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              getAlbumTile(),
              SizedBox(
                height: 8,
              ),
              audioTile,
              SizedBox(
                height: 8,
              ),
              getMovieTile(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget getAlbumTile() {
    MusicAlbum album = MusicAlbum.fromJson({
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
    });

    Audio audio = album.audio[1];
    audioTile = CartMusicTile(audio: audio);

    return CartAlbumTile(
      album: album,
    );
  }

  Widget getMovieTile() {
    MovieItem movie = MovieItem.fromJson({
      "id": 1,
      "name": "The Cloud Of Northland",
      "poster": "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
      "genre": "Action",
      "year": "2020",
      "price": "34.00",
      "currency": "NGN",
      "rating": "7.8"
    });
    return CartMovieTile(
      movie: movie,
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Shopping cart",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
