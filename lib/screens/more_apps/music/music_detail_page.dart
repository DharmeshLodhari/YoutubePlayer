import 'dart:async';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'music_dashboard_bloc.dart';
import 'music_player.dart';

// ignore: must_be_immutable
class MusicDetailPage extends StatefulWidget {
  var arguments;

  MusicDetailPage({this.arguments});

  @override
  _MusicDetailPageState createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  MusicDashboardBloc _musicDashboardBloc;

  // musicPlayer.audioPlayer musicPlayer.audioPlayer;
  MusicPlayer musicPlayer;
  int trackIndex;

  bool isPlaying = false;
  bool isLoading = true;

  LoopMode musicLoopMode = LoopMode.playlist;

  @override
  void initState() {
    musicPlayer = widget.arguments["musicPlayer"];
    trackIndex = widget.arguments["index"];
    loadMusic();
    super.initState();
  }

  void loadMusic() async {
    try {
      if (musicPlayer.audioPlayer.isPlaying.value == true ||
          musicPlayer.audioPlayer.playerState.value == PlayerState.pause) {
        if (musicPlayer.audioPlayer.current.value.index != trackIndex) {
          musicPlayer.audioPlayer.playlistPlayAtIndex(trackIndex);
        }
      } else {
        musicPlayer.audioPlayer.playlistPlayAtIndex(trackIndex);
      }

      isLoading = false;
      setState(() {});
    } catch (t) {
      debugPrint("t" + t.toString());
      //mp3 unreachable
    }
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
      title: musicPlayer.audioPlayer.builderRealtimePlayingInfos(
          builder: (context, info) {
        return Text(
          info == null || info.current == null
              ? "ERIGMA II"
              : info.current.audio.audio.metas.title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
        );
      }),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: musicPoster(),
        ),
        Flexible(
          flex: 3,
          child: SizedBox(
            height: 40,
          ),
        ),
        musicPlayer.audioPlayer.builderRealtimePlayingInfos(
            builder: (context, info) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info == null || info.current == null
                      ? "ERIGMA II"
                      : info.current.audio.audio.metas.title,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: blackFont),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  info == null || info.current == null
                      ? "ERIGGA"
                      : info.current.audio.audio.metas.artist,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: blackFont),
                ),
              ],
            ),
          );
        }),
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 40,
          ),
        ),
        progressIndicator(),
        Flexible(
          flex: 2,
          child: SizedBox(
            height: 40,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: playerController(),
        ),
        Flexible(
          flex: 4,
          child: SizedBox(
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return Column(
      children: [
        musicPlayer.audioPlayer.builderRealtimePlayingInfos(
            builder: (context, info) {
          if (info == null || info.current == null) {
            return SizedBox(
              height: 50,
            );
          }
          return PositionSeekWidget(
            currentPosition: info.currentPosition,
            duration: info.duration,
            seekTo: (to) {
              musicPlayer.audioPlayer.seek(to);
            },
          );
        }),
      ],
    );
  }

  Widget playerController() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            musicPlayer.toggleShuffle();
            debugPrint("suffle:- ${musicPlayer.audioPlayer.shuffle}");
            setState(() {});
          },
          child: Icon(
            SlydoAppIcon.music_suffle,
            size: 16,
            color: musicPlayer.audioPlayer.shuffle ? navyBlue : blackFont,
          ),
        ),
        flexibleSpace(),
        InkWell(
          onTap: () {
            musicPlayer.audioPlayer.previous();
            setState(() {});
          },
          child: Icon(
            SlydoAppIcon.music_back,
            size: 16,
            color: blackFont,
          ),
        ),
        flexibleSpace(),
        InkWell(
          onTap: () {
            if (musicPlayer.audioPlayer.isPlaying.value) {
              musicPlayer.audioPlayer.pause();
              setState(() {});
            } else {
              musicPlayer.audioPlayer.play();
              setState(() {});
            }
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
                    initialData: false,
                    stream: musicPlayer.audioPlayer.isPlaying,
                    builder: (context, snapshot) {
                      return Icon(
                        snapshot.data ? Icons.pause : SlydoAppIcon.music_play_1,
                        size: snapshot.data ? 28 : 20,
                        color: blackFont,
                      );
                    }),
              ),
            ),
          ),
        ),
        flexibleSpace(),
        InkWell(
          onTap: () {
            musicPlayer.audioPlayer.next();
          },
          child: Icon(
            SlydoAppIcon.music_next,
            size: 16,
            color: blackFont,
          ),
        ),
        flexibleSpace(),
        InkWell(
          onTap: () {
            if (musicLoopMode == LoopMode.playlist) {
              musicPlayer.audioPlayer.setLoopMode(LoopMode.single);
              musicLoopMode = LoopMode.single;
            } else if (musicLoopMode == LoopMode.single) {
              musicPlayer.audioPlayer.setLoopMode(LoopMode.playlist);
              musicLoopMode = LoopMode.playlist;
            }
            setState(() {});
          },
          child: Icon(
            SlydoAppIcon.music_repeat,
            size: 16,
            color: musicLoopMode == LoopMode.single ? navyBlue : blackFont,
          ),
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
          child: musicPlayer.audioPlayer.builderRealtimePlayingInfos(
              builder: (context, info) {
            return CachedNetworkImage(
              imageUrl: info == null || info.current == null
                  ? "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg"
                  : info.current.audio.audio.metas.image.path,
              fit: BoxFit.fill,
            );
          }),
        ),
      ),
    );
  }
}

class PositionSeekWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  const PositionSeekWidget({
    @required this.currentPosition,
    @required this.duration,
    @required this.seekTo,
  });

  @override
  _PositionSeekWidgetState createState() => _PositionSeekWidgetState();
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  Duration _visibleValue;
  bool listenOnlyUserInterraction = false;
  double get percent => widget.duration.inMilliseconds == 0
      ? 0
      : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                trackHeight: 1,
                thumbColor: navyBlue,
                inactiveTrackColor: dividerColor,
                trackShape: RoundedRectSliderTrackShape(),
                activeTrackColor: navyBlue,
                disabledThumbColor: Colors.white,
                thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                    elevation: 1,
                    pressedElevation: 4)),
            child: Slider(
              min: 0,
              max: widget.duration.inMilliseconds.toDouble(),
              inactiveColor: dividerColor,
              activeColor: navyBlue,
              value: percent * widget.duration.inMilliseconds.toDouble(),
              onChangeEnd: (newValue) {
                setState(() {
                  listenOnlyUserInterraction = false;
                  widget.seekTo(_visibleValue);
                });
              },
              onChangeStart: (_) {
                setState(() {
                  listenOnlyUserInterraction = true;
                });
              },
              onChanged: (newValue) {
                setState(() {
                  final to = Duration(milliseconds: newValue.floor());
                  _visibleValue = to;
                });
              },
            ),
          ),
          Positioned(
            bottom: -16,
            left: 20,
            right: 20,
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    durationToString(widget.currentPosition),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: darkGrey),
                  ),
                  Expanded(
                      child: SizedBox(
                    width: 8,
                  )),
                  Text(
                    durationToString(widget.duration),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: darkGrey),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
