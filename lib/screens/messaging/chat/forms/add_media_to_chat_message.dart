import 'dart:async';
import 'dart:io';

import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class AddMediaToChatMessage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const AddMediaToChatMessage({super.key, required this.arguments});

  @override
  State<AddMediaToChatMessage> createState() => _AddMediaToChatMessageState();
}

class _AddMediaToChatMessageState extends State<AddMediaToChatMessage> {
  Map<String, dynamic>? data;
  File? mediaFile;
  String? mediaType;

  TextEditingController? messageController;

  bool isLoading = false;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  /// Music Player
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  bool isAudioPlaying = false;

  @override
  void initState() {
    final message = widget.arguments!["message"];
    messageController = TextEditingController(text: message);
    data = widget.arguments!["data"];
    mediaFile = widget.arguments!["media"];
    mediaType = widget.arguments!["mediaType"];

    // debugPrint('MEDIA FILE ::: $mediaFile');

    if (mediaType == "video") {
      setUpVideoPlayer();
    }

    if (mediaType == "image") {
      cropImage();
    }
    if (mediaType == "file") {
      debugPrint('DOC FILE WAS PICKED');
    }

    super.initState();
  }

  void cropImage() async {
    /// for cropping the image
    final String? croppedImage = await ImageCrop().cropImage(mediaFile!.path);
    if (croppedImage != null) {
      mediaFile = File(croppedImage);
      if (mounted) setState(() {});
    }
  }

  void setUpVideoPlayer() async {
    isLoading = true;
    if (mounted) setState(() {});
    // debugPrint("path=> $mediaFile");
    _videoController = VideoPlayerController.file(mediaFile!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      aspectRatio: _videoController!.value.aspectRatio,
      allowedScreenSleep: false,
      autoPlay: false,
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

    _audioPlayer.stop();
    _audioPlayer.dispose();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

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
          floatingActionButton: mediaType == "audio"
              ? FloatingActionButton(
                  backgroundColor: navyBlue,
                  onPressed: sendMessage,
                  mini: false,
                  heroTag: null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        50.0), // Set the border radius to create a circle
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    return Column(
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
                    child: SizedBox(
                      height: 36,
                      width: 36,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: mediaType == "file" ? blackFont : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        if (mediaType != "audio")
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            constraints: const BoxConstraints(
              maxHeight: 100,
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: getMessageTextFormField()),
                InkWell(
                  onTap: sendMessage,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(
                        Icons.send,
                        color: navyBlue,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(),
      ],
    );
  }

  Widget getMessageTextFormField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: chatBackgroundColor,
        child: Theme(
            data: ThemeData(highlightColor: navyBlue.withOpacity(0.3)),
            child: Scrollbar(
              radius: const Radius.circular(12),
              thickness: 2.5,
              child: TextFormField(
                controller: messageController,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.multiline,
                autofocus: Platform.isIOS ? false : true,
                onFieldSubmitted: (value) {
                  sendMessage();
                },
                cursorColor: blackFont,
                cursorWidth: 1,
                cursorHeight: 20,
                maxLines: null,
                cursorRadius: const Radius.circular(16),
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16),
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  void sendMessage() async {
    final Map<String, dynamic> data = {};
    data['text'] = messageController!.text.trim();
    data['check_id'] = const Uuid().v4();
    data['kind'] = mediaType;
    data['read_by_author'] = true;
    data['created_at'] = DateTime.now().toUtc().toString();
    data['type'] = "chatroom_message";
    data.addAll(data);

    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    File? poster;
    if (mediaType == "video") {
      final String? posterPath = await getVideoThumbnail(mediaFile!);
      if (posterPath == null) return;
      poster = File(posterPath);
    }

    await MessageAuth()
        .sendSocketMessage(data, mediaFile!, poster: poster)
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
        imageProvider: FileImage(mediaFile!),
      ));
    } else if (mediaType == "video") {
      // debugPrint("ISLOADING=> $isLoading");
      return isLoading
          ? Center(
              child: CircularLoadingIndicator(),
            )
          : Chewie(
              controller: _chewieController!,
              posterUrl: "",
              titleName: "",
            );
    } else if (mediaType == "audio") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                padding:
                    const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: _audioPlayer.builderRealtimePlayingInfos(
                              builder: (context, info) {
                            if (info.current == null) {
                              return GestureDetector(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: navyBlue,
                                  size: 32,
                                ),
                                onTap: () {
                                  _audioPlayer.open(
                                    Audio.file(mediaFile!.path),
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
                          if (info.current == null) {
                            return Expanded(
                              child: Column(
                                children: [
                                  PositionSeekWidget(
                                    currentPosition: Duration.zero,
                                    duration: Duration.zero,
                                    seekTo: (to) {},
                                  ),
                                  const SizedBox(
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
                                    _audioPlayer.seek(to!);
                                  },
                                ),
                                const SizedBox(
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
    } else if (mediaType == "file") {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                getDocumentFileIcon(
                  getDocumentFileTypeForChat(mediaFile!.path.split('.').last),
                ),
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 12),
              Text(
                mediaFile!.path.split('/').last,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: blackFont,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }
}

getDocumentFileTypeForChat(String extension) {
  switch (extension) {
    case 'pdf':
      return DocumentFileTypeForChat.pdf;
    case 'apk':
      return DocumentFileTypeForChat.apk;
    case 'xls':
      return DocumentFileTypeForChat.xls;
    case 'zip':
      return DocumentFileTypeForChat.zip;
    case 'txt':
      return DocumentFileTypeForChat.txt;
  }
}

String getDocumentFileIcon(DocumentFileTypeForChat docsType) {
  switch (docsType) {
    case DocumentFileTypeForChat.apk:
      return 'assets/images/apk_icon.svg';
    case DocumentFileTypeForChat.pdf:
      return 'assets/images/pdf_icon.svg';
    case DocumentFileTypeForChat.txt:
      return 'assets/images/txt_icon.svg';
    case DocumentFileTypeForChat.xls:
      return 'assets/images/xls_icon.svg';
    case DocumentFileTypeForChat.zip:
      return 'assets/images/zip_icon.svg';
    default:
      return 'assets/images/zip_icon.svg';
  }
}
