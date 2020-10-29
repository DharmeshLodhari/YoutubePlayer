import 'dart:async';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'music_dashboard_bloc.dart';

class MusicDetailPage extends StatefulWidget {
  @override
  _MusicDetailPageState createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  MusicDashboardBloc _musicDashboardBloc;

  final assetsAudioPlayer = AssetsAudioPlayer();

  bool isPlaying = false;
  bool isLoading = true;

  @override
  void initState() {
    loadMusic();
    super.initState();
  }

  void loadMusic() async {
    try {
      await assetsAudioPlayer.open(
          Audio.network(
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/673e733fe5e055fb5d3d1e35500e0f4991d4faad/Martin Garrix - Animals (Original Mix).mp3"),
          autoStart: true,
          showNotification: true,
          playInBackground: PlayInBackground.enabled);
      isLoading = false;
      setState(() {});
    } catch (t) {
      debugPrint("t" + t.toString());
      //mp3 unreachable
    }
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  var isWishList = false;

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
        'THE ERIGMA II',
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

  Widget scaffoldBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
          ),
          musicPoster(),
          Flexible(
            flex: 2,
            child: SizedBox(
              height: 40,
            ),
          ),
          Text(
            "Up all night",
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, color: blackFont),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "ERIGGA",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              height: 40,
            ),
          ),
          progressIndicator(),
          Flexible(
            flex: 1,
            child: SizedBox(
              height: 40,
            ),
          ),
          playerController(),
          Flexible(
            flex: 2,
            child: SizedBox(
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressIndicator() {
    return Column(
      children: [
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width - 40,
          lineHeight: 2.0,
          percent: 1,
          animation: true,
          restartAnimation: true,
          animationDuration: 300000,
          widgetIndicator: Container(
            height: 10,
            width: 10,
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Positioned(
                  top: -3,
                  child: ClipOval(
                    child: Container(
                      color: navyBlue,
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          linearStrokeCap: LinearStrokeCap.roundAll,
          backgroundColor: dividerColor,
          progressColor: navyBlue,
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<Duration>(
                stream: assetsAudioPlayer.currentPosition,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: darkGrey),
                  );
                }),
            Text(
              "3:00",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w400, color: darkGrey),
            ),
          ],
        )
      ],
    );
  }

  Widget playerController() {
    return Row(
      children: [
        Icon(
          SlydoAppIcon.music_suffle,
          size: 16,
          color: blackFont,
        ),
        flexibleSpace(),
        Icon(
          SlydoAppIcon.music_back,
          size: 16,
          color: blackFont,
        ),
        flexibleSpace(),
        StreamBuilder<bool>(
            stream: assetsAudioPlayer.isPlaying,
            builder: (context, snapshot) {
              return InkWell(
                onTap: snapshot.data
                    ? () {
                        assetsAudioPlayer.pause();
                      }
                    : () {
                        assetsAudioPlayer.play();
                      },
                child: Container(
                  decoration: decorateBox(
                      borderColor: Colors.white,
                      borderRadius: 50,
                      shadowColor: Colors.black12.withOpacity(0.08)),
                  child: ClipOval(
                    child: Container(
                      height: 70,
                      width: 70,
                      child: StreamBuilder<bool>(
                          stream: assetsAudioPlayer.isPlaying,
                          builder: (context, snapshot) {
                            return Icon(
                              snapshot.data
                                  ? Icons.pause
                                  : SlydoAppIcon.music_play_1,
                              size: snapshot.data ? 28 : 20,
                              color: blackFont,
                            );
                          }),
                    ),
                  ),
                ),
              );
            }),
        flexibleSpace(),
        Icon(
          SlydoAppIcon.music_next,
          size: 16,
          color: blackFont,
        ),
        flexibleSpace(),
        Icon(
          SlydoAppIcon.music_repeat,
          size: 16,
          color: blackFont,
        ),
      ],
    );
  }

  Widget musicPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: Container(
        child: AspectRatio(
          aspectRatio: 1,
          child: CachedNetworkImage(
            imageUrl:
                "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
