import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final ChatConversation chatConversation;

  AudioTileForChat({this.message, this.chatConversation});

  @override
  _AudioTileForChatState createState() => _AudioTileForChatState();
}

class _AudioTileForChatState extends State<AudioTileForChat> {
  /// Music Player
  AssetsAudioPlayer _audioPlayer;

  UserBloc userBloc;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bool isSend = widget.message["author"] == userBloc.user.userName;

    if (_audioPlayer == null || _audioPlayer?.id != widget.message["id"]) {
      _audioPlayer = AssetsAudioPlayer.withId(widget.message["id"]);

      debugPrint("==> ${widget.message["media"]}");

      _audioPlayer
          .open(
              Audio.network(
                widget.message["media"],
              ),
              autoStart: false,
              showNotification: false)
          .catchError((error) {
        debugPrint("ERROR while playing:- $error");
      });
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend ? Container() : Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: widget.chatConversation.isGroupConversation
                      ? widget.message['author'] != userBloc.user.userName
                          ? 65
                          : 50
                      : 50),
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
                  widget.chatConversation.isGroupConversation
                      ? widget.message['author'] != userBloc.user.userName
                          ? Container(
                              padding: EdgeInsets.only(left: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message['author_full_name'] ??
                                        widget.message['author'],
                                    style: TextStyle(
                                        color: isSend ? Colors.white : navyBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              width: 0,
                            )
                      : Container(
                          width: 0,
                        ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 6, left: 4),
                        child: _audioPlayer.builderRealtimePlayingInfos(
                            builder: (context, info) {
                          if (info == null) {
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
                              // ignore: null_aware_in_condition
                              _audioPlayer?.isPlaying?.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: navyBlue,
                              size: 32,
                            ),
                            onTap: () {
                              // ignore: null_aware_in_condition
                              if (_audioPlayer?.isPlaying?.value) {
                                _audioPlayer?.pause();
                              } else {
                                _audioPlayer?.play();
                              }
                              setState(() {});
                            },
                          );
                        }),
                      ),
                      _audioPlayer?.builderRealtimePlayingInfos(
                          builder: (context, info) {
                        if (info == null) {
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
                                currentPosition: info?.currentPosition,
                                duration: info?.duration,
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
                  ),
                ],
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: widget.message),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSend
                ? Container()
                : SizedBox(
                    width: 20,
                  ),
            Text(
              formatTime(widget.message['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        )
      ],
    );
  }
}
