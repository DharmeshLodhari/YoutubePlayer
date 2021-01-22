import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
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
    ///{id: 0d1fb784-db82-481a-9fd8-b775bba2a18e, check_id: 17769da5-1a06-457d-ae11-47c8475e62fc,
    /// conversation: d60887a8-1dce-4e2d-8c54-432c3365abd3, author: black,
    /// text: , read_by_author: true, read_by_recipient: false, was_edited: false,
    /// media: https://slydo-assets.s3.amazonaws.com/media/1b434eab-edf3-450f-a9cc-b796a92edf5c.mp3,
    /// poster: null, updated_at: 2021-01-20T13:38:59.276192+01:00, created_at: 2021-01-20T13:38:59.276228+01:00,
    /// kind: audio, deleted_for_recipient: false, deleted_for_author: false, delivered: true, meta_data: {}}

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
    String messageText = widget.message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    if (_audioPlayer == null || _audioPlayer?.id != widget.message["id"]) {
      _audioPlayer = AssetsAudioPlayer.withId(widget.message["id"]);

      _audioPlayer.open(
        Audio.network(widget.message["media"]),
        autoStart: false,
      );
    }

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
              SizedBox(
                height: isMessageEmpty ? 2 : 2,
              ),
              Stack(
                overflow: Overflow.visible,
                children: [
                  Column(
                    children: [
                      isMessageEmpty
                          ? Container()
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    messageText,
                                    style: TextStyle(
                                        color:
                                            isSend ? Colors.white : blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: isMessageEmpty ? 8 : 2,
                        width: 45,
                      )
                    ],
                  ),
                  Positioned(
                    right: !isSend ? 0 : -2,
                    bottom: isMessageEmpty ? -2 : -6,
                    child: Row(
                      children: [
                        Text(
                          formatTime(widget.message['created_at']),
                          style: TextStyle(
                              color: navyBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        isSend
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 10,
                                    color: getMessageTickColor(
                                        message: widget.message),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isMessageEmpty ? 2 : 6,
              )
            ],
          ),
        )
      ],
    );
  }
}
