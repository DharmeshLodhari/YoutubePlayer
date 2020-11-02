import 'dart:math';

import 'package:Slydo/screens/more_apps/music/models/music_album.dart'
    as musicAlbum;
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'music_player.dart';

// ignore: must_be_immutable
class MusicTile extends StatelessWidget {
  String imageUrl;
  MusicTile({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    height: 86,
                    width: 68,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    height: 86,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thu, Oct 15 • 6:54 AM",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: mateRed,
                          ),
                        ),
                        flexibleSpace(flex: 2),
                        Text(
                          "5th Borough food festival",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(),
                        Text(
                          "Clove lakes park",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(flex: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class MusicTileWithHeart extends StatefulWidget {
  String image;
  MusicTileWithHeart({this.image});

  @override
  _MusicTileWithHeartState createState() => _MusicTileWithHeartState();
}

class _MusicTileWithHeartState extends State<MusicTileWithHeart> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are you happy? ",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Text(
                  "SHY Martin",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: blackFont,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 10,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isChange ? SlydoAppIcon.heart_empty : SlydoAppIcon.heart_1,
                color: isChange ? blackFont : navyBlue,
                size: 20,
              ),
              onPressed: () {
                isChange = !isChange;
                setState(() {});
              },
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class MusicTileGeneral extends StatefulWidget {
  String image;

  MusicTileGeneral({this.image});

  @override
  _MusicTileGeneralState createState() => _MusicTileGeneralState();
}

class _MusicTileGeneralState extends State<MusicTileGeneral> {
  bool isDownloaded = Random().nextBool();

  bool isChange = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Run it down",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              "Run it down",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: blackFont,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                isDownloaded
                    ? SlydoAppIcon.music_play
                    : isChange
                        ? SlydoAppIcon.heart_empty
                        : SlydoAppIcon.heart_1,
                color: isDownloaded
                    ? navyBlue
                    : isChange
                        ? blackFont
                        : navyBlue,
                size: 20,
              ),
              onPressed: () {
                isChange = !isChange;
                setState(() {});
              },
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class AlbumSongTile extends StatefulWidget {
  MusicPlayer musicPlayer;
  musicAlbum.Audio audio;
  int count;
  AlbumSongTile({this.audio, this.count, this.musicPlayer});

  @override
  _AlbumSongTileState createState() => _AlbumSongTileState();
}

class _AlbumSongTileState extends State<AlbumSongTile> {
  bool isDownloaded = Random().nextBool();

  bool isChange = Random().nextBool();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          StreamBuilder<RealtimePlayingInfos>(
              stream: widget.musicPlayer.audioPlayer.realtimePlayingInfos,
              initialData: RealtimePlayingInfos(
                loopMode: null,
                current: null,
                currentPosition: null,
                isBuffering: null,
                playerId: null,
                volume: null,
                isShuffling: null,
                isPlaying: false,
              ),
              builder: (context, snapshot) {
                return snapshot.data.isPlaying
                    ? Row(
                        children: [
                          InkWell(
                            child: CircularPercentIndicator(
                              backgroundColor: dividerColor,
                              radius: 30.0,
                              lineWidth: 3.0,
                              percent: snapshot.data.playingPercent,
                              center: Icon(
                                Icons.stop,
                                color: navyBlue,
                                size: 14,
                              ),
                              progressColor: navyBlue,
                            ),
                            onTap: () {
                              widget.musicPlayer.audioPlayer.stop();
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: widget.count.toString().length == 1
                                    ? 12
                                    : widget.count.toString().length == 2
                                        ? 8
                                        : 4,
                                right: widget.count.toString().length == 1
                                    ? 20
                                    : widget.count.toString().length == 2
                                        ? 16
                                        : 14),
                            child: Text(
                              "${widget.count}",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: blackFont,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      );
              }),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.audio.metas.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: blackFont),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  widget.audio.metas.artist,
                  style: TextStyle(
                      fontSize: 14,
                      color: blackFont,
                      fontWeight: FontWeight.w400),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Text(
            "12:32",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: blackFont,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: navyBlue.withOpacity(0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 8,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            children: <Widget>[
              InkWell(
                child: Icon(
                  isDownloaded
                      ? SlydoAppIcon.music_play
                      : isChange
                          ? SlydoAppIcon.heart_empty
                          : SlydoAppIcon.heart_1,
                  color: isDownloaded
                      ? navyBlue
                      : isChange
                          ? blackFont
                          : navyBlue,
                  size: 20,
                ),
                onTap: () {
                  isChange = !isChange;
                  setState(() {});
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
