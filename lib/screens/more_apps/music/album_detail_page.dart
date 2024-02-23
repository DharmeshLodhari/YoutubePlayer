import 'package:Slydo/screens/more_apps/music/models/music_album.dart'
    as MusicAlbum;
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../messaging/chat/utils.dart';
import 'music_auth.dart';
import 'music_dashboard_bloc.dart';
import 'music_player.dart';
import 'music_tile.dart';

// ignore: must_be_immutable
class AlbumDetailPage extends StatefulWidget {
  var arguments;

  AlbumDetailPage({this.arguments});

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late MusicDashboardBloc _musicDashboardBloc;

  MusicPlayer? musicPlayer;
  bool isLoading = false;
  late MusicAlbum.MusicAlbum musicAlbum;

  @override
  void initState() {
    musicPlayer = widget.arguments["musicPlayer"];
    musicAlbum = musicPlayer!.musicAlbum;
    if (musicAlbum.id == null) {
      getMusicAlbum();
    }

    super.initState();
  }

  void getMusicAlbum() {
    isLoading = true;
    setState(() {});
    MusicAuthService().getMusicAlbum().then((album) async {
      musicAlbum = album;
      musicPlayer!.musicAlbum = album;
      isLoading = false;
      await musicPlayer!.audioPlayer.open(
        Playlist(
          audios: musicAlbum.audio!
              .map((audio) => Audio.network(
                    audio.src!,
                    cached: true,
                    metas: Metas(
                      id: audio.metas!.id,
                      title: audio.metas!.title,
                      artist: audio.metas!.artist,
                      album: audio.metas!.title,
                      image: MetasImage.network(
                          audio.metas!.image!), //can be MetasImage.network
                    ),
                  ))
              .toList(),
        ),
        autoStart: false,
        showNotification: true,
        loopMode: LoopMode.playlist,
        playInBackground: PlayInBackground.enabled,
      );
      setState(() {});
    });
  }

  bool isWishList = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _musicDashboardBloc = Provider.of<MusicDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        _musicDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Text(
        musicAlbum.title!,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
      ),
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
      actions: <Widget>[
        shareBtn(),
        SizedBox(
          width: 8,
        ),
        addToCartBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget shareBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget addToCartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.cart,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    int count = 1;
    return isLoading
        ? Center(child: CircularLoadingIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                albumPoster(),
                Column(
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: albumDetail(),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                      color: dividerColor,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 58,
                        ),
                        Expanded(
                          child: Text(
                            'Name',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: blackFont),
                          ),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          'Duration',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: blackFont),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          'Price',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: blackFont),
                        ),
                        SizedBox(
                          width: 75,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                      color: dividerColor,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20, left: 10),
                      child: Column(
                        children: musicAlbum.audio!
                            .asMap()
                            .map(
                              (i, audio) => MapEntry(
                                i,
                                InkWell(
                                  child: AlbumSongTile(
                                    audio: audio,
                                    count: count++,
                                    index: i,
                                    musicPlayer: musicPlayer,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, "/music-detail",
                                        arguments: {
                                          "musicPlayer": musicPlayer,
                                          "index": i,
                                        });
                                  },
                                ),
                              ),
                            )
                            .values
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget albumPoster() {
    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          CachedNetworkImage(
            width: double.infinity,
            height: double.infinity,
            imageUrl: musicAlbum.image!,
            fit: BoxFit.fill,
            errorWidget: imageErrorWidget,
          ),
          Positioned(
            right: 12,
            top: 12,
            child: InkWell(
              child: Icon(
                isWishList ? SlydoAppIcon.heart_1 : SlydoAppIcon.heart_empty,
                color: Colors.white,
                size: 22,
              ),
              onTap: () {
                isWishList = !isWishList;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget albumDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              musicAlbum.title!,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                getUserCurrencySymbol(context, fontSize: 18),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: navyBlue,
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'ERIGGA',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: blackFont),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 11,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8",
                      style: TextStyle(fontSize: 14, color: blackFont),
                    )
                  ],
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: buyAlbumButton(),
            )
          ],
        ),
      ],
    );
  }

  Widget buyAlbumButton() {
    return CurvedButton(
      height: 30,
      backgroundColor: navyBlue,
      onPressed: () {
        Navigator.of(context).pushNamed("/mix-cart-item");
      },
      text: "Buy",
      textColor: Colors.white,
    );
  }
}
