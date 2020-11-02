import 'package:Slydo/screens/more_apps/music/models/music_album.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  MusicDashboardBloc _musicDashboardBloc;

  MusicPlayer musicPlayer;
  bool isLoading = false;
  MusicAlbum musicAlbum = MusicAlbum(
      audio: [],
      title: "",
      id: 0,
      image:
          "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg");

  @override
  void initState() {
    musicPlayer = widget.arguments["musicPlayer"];
    getMusicAlbum();
    super.initState();
  }

  void getMusicAlbum() {
    isLoading = true;
    setState(() {});
    AuthService().getMusicAlbum().then((album) {
      musicAlbum = album;
      isLoading = false;
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
        appBar: appBar(),
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
        musicAlbum.title,
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
                        children: musicAlbum.audio
                            .map(
                              (audio) => InkWell(
                                child: AlbumSongTile(
                                  audio: audio,
                                  count: count++,
                                  musicPlayer: musicPlayer,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, "/music-detail",
                                      arguments: {"musicPlayer": musicPlayer});
                                },
                              ),
                            )
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
            imageUrl: musicAlbum.image,
            fit: BoxFit.fill,
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
              musicAlbum.title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 12,
                ),
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
        Text(
          'ERIGGA',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
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
    );
  }
}
