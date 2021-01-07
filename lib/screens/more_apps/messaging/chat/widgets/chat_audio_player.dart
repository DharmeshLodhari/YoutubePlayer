import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatAudioPlayer extends StatefulWidget {
  final Map<String, dynamic> message;

  ChatAudioPlayer({this.message});

  @override
  _ChatAudioPlayerState createState() => _ChatAudioPlayerState();
}

class _ChatAudioPlayerState extends State<ChatAudioPlayer> {
  /// Music Player
  AssetsAudioPlayer _audioPlayer;

  UserBloc userBloc;
  @override
  void initState() {
    debugPrint("${widget.message}");
    _audioPlayer = AssetsAudioPlayer.withId(widget.message["id"]);
    _audioPlayer.open(Audio.network(widget.message["media"]), autoStart: false);
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bool isSend = widget.message["author"] == userBloc.user.userName;

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
              minHeight: 50),
          decoration: BoxDecoration(
            color: chatBackgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(!isSend ? 0 : 6),
              bottomRight: Radius.circular(isSend ? 0 : 6),
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: _audioPlayer.builderRealtimePlayingInfos(
                        builder: (context, info) {
                      if (info == null || info.current == null) {
                        return GestureDetector(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: navyBlue,
                            size: 32,
                          ),
                          onTap: () {},
                        );
                      }
                      return GestureDetector(
                        child: Icon(
                          _audioPlayer.isPlaying.value
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: navyBlue,
                          size: 32,
                        ),
                        onTap: () {
                          if (_audioPlayer.isPlaying.value) {
                            _audioPlayer.pause();
                          } else {
                            _audioPlayer.play();
                          }
                          setState(() {});
                        },
                      );
                    }),
                  ),
                  _audioPlayer.builderRealtimePlayingInfos(
                      builder: (context, info) {
                    if (info == null || info.current == null) {
                      return Expanded(
                        child: Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: Duration.zero,
                              duration: Duration.zero,
                              seekTo: (to) {},
                            ),
                            SizedBox(
                              height: 6,
                            )
                          ],
                        ),
                      );
                    }
                    return Expanded(
                      child: Column(
                        children: [
                          PositionSeekWidget(
                            currentPosition: info.currentPosition,
                            duration: info.duration,
                            seekTo: (to) {
                              _audioPlayer.seek(to);
                            },
                          ),
                          SizedBox(
                            height: 6,
                          )
                        ],
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
