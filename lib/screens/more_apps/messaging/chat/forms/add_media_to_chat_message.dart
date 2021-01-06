import 'dart:io';

import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// ignore: must_be_immutable
class AddMediaToChatMessage extends StatefulWidget {
  Map<String, dynamic> arguments;

  AddMediaToChatMessage({@required this.arguments});

  @override
  _AddMediaToChatMessageState createState() => _AddMediaToChatMessageState();
}

class _AddMediaToChatMessageState extends State<AddMediaToChatMessage> {
  Map<String, dynamic> data;
  File mediaFile;
  String mediaType;

  TextEditingController messageController;

  bool isLoading = false;

  VideoPlayerController _videoController;
  ChewieController _chewieController;

  /// Music Player
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  bool isAudioPlaying = false;

  @override
  void initState() {
    var message = widget.arguments["message"];
    messageController = TextEditingController(text: message);
    data = widget.arguments["data"];
    mediaFile = widget.arguments["media"];
    mediaType = widget.arguments["mediaType"];

    if (mediaType == "video") {
      setUpVideoPlayer();
    }

    super.initState();
  }

  void setUpVideoPlayer() {
    isLoading = true;
    if (mounted) setState(() {});

    _videoController = VideoPlayerController.file(
      mediaFile,
    );
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false, autoPlay: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      // showControls: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: navyBlue,
        handleColor: Colors.white,
        backgroundColor: dividerColor,
        bufferedColor: Colors.white30,
      ),
      autoInitialize: true,
    );

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();

    _audioPlayer?.stop();
    _audioPlayer?.dispose();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: scaffoldBody(),
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              getMediaRenderer(),
              Positioned(
                top: 4,
                left: 4,
                child: InkWell(
                  child: ClipOval(
                    child: Container(
                      height: 36,
                      width: 36,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          )),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Expanded(child: getMessageTextFormField()),
                InkWell(
                  onTap: sendMessage,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.send,
                        color: navyBlue,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getMessageTextFormField() {
    return TextFormField(
      controller: messageController,
      autofocus: true,
      textInputAction: TextInputAction.send,
      onFieldSubmitted: (value) {
        sendMessage();
      },
      cursorColor: blackFont,
      cursorWidth: 1,
      cursorHeight: 20,
      cursorRadius: Radius.circular(16),
      decoration: InputDecoration(
        hintText: "Type message",
        hintStyle: TextStyle(
          color: darkGrey.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefix: Padding(
          padding: EdgeInsets.only(left: 12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: navyBlue,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Future<String> getVideoThumbnail(File file) async {
    String path = await VideoThumbnail.thumbnailFile(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    debugPrint(" PATH:-  ===> $path");
    return path;
  }

  void sendMessage() async {
    // Navigator.pop(context, Future.error("error"));

    Map<String, dynamic> _data = {};
    _data['text'] = messageController.text.trim();
    _data['check_id'] = Uuid().v4();
    _data['kind'] = mediaType;
    _data['read_by_author'] = true;
    _data['created_at'] = DateTime.now().toUtc().toString();
    _data['type'] = "chatroom_message";
    _data.addAll(data);

    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    File poster;
    if (mediaType == "video") {
      String posterPath = await getVideoThumbnail(mediaFile);
      poster = File(posterPath);
    }

    MessageAuth()
        .sendSocketMessage(_data, mediaFile, poster: poster)
        .then((value) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }).catchError((error) {
      Navigator.pop(context);
      Navigator.pop(context, Future.error(error));
    });
  }

  Widget getMediaRenderer() {
    if (mediaType == "image") {
      return ClipRect(
          child: PhotoView(
        imageProvider: FileImage(mediaFile),
      ));
    } else if (mediaType == "video") {
      return Chewie(
        controller: _chewieController,
        posterUrl: "",
        titleName: "",
      );
    } else if (mediaType == "audio") {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                    minWidth: MediaQuery.of(context).size.width - 32,
                    minHeight: 50),
                decoration: BoxDecoration(
                  color: chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
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
                                onTap: () {
                                  _audioPlayer.open(
                                    Audio.file(mediaFile.path),
                                    autoStart: false,
                                  );
                                  isAudioPlaying = !isAudioPlaying;
                                  setState(() {});
                                },
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
          ),
        ),
      );
    }
  }
}
