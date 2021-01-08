import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewChatMedia extends StatefulWidget {
  final arguments;

  ViewChatMedia({this.arguments});

  @override
  _ViewChatMediaState createState() => _ViewChatMediaState();
}

class _ViewChatMediaState extends State<ViewChatMedia> {
  String type = "";
  String url = "";
  String message = "";
  String poster;

  VideoPlayerController _videoController;
  ChewieController _chewieController;

  bool isLoading = false;

  @override
  void initState() {
    type = widget.arguments["type"];
    url = widget.arguments["file"];
    message = widget.arguments["message"];
    poster = widget.arguments["poster"] ?? null;

    if (type == "video") {
      isLoading = true;
      if (mounted) setState(() {});

      _videoController = VideoPlayerController.network(
        url,
      );
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
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

    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();

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
              getMediaItem(),
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
              ),
              (message != "")
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black38,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                                child: Center(
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.justify,
                              ),
                            )),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          )),
        ],
      ),
    );
  }

  Widget getMediaItem() {
    if (type == "image") {
      return ClipRect(
          child: PhotoView(
        imageProvider: NetworkImage(url),
      ));
    }
    if (type == "video") {
      return Chewie(
        controller: _chewieController,
        posterUrl: poster ?? "",
        titleName: "",
      );
    } else {
      return Container();
    }
  }
}
