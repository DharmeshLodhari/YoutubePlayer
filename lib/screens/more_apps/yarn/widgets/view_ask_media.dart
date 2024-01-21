import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewAskMedia extends StatefulWidget {
  final arguments;

  ViewAskMedia({this.arguments});

  @override
  _ViewAskMediaState createState() => _ViewAskMediaState();
}

class _ViewAskMediaState extends State<ViewAskMedia> {
  String? type = "";
  String? url = "";
  String? poster;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool isLoading = false;

  @override
  void initState() {
    type = widget.arguments["type"];
    url = widget.arguments["file"];
    poster = widget.arguments["poster"] ?? null;

    if (type == "video") {
      initializeVideoPlayer();
    }

    super.initState();
  }

  void initializeVideoPlayer() async {
    isLoading = true;
    if (mounted) setState(() {});

    _videoController = VideoPlayerController.network(url!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      aspectRatio: _videoController!.value.aspectRatio,
      allowedScreenSleep: false, autoPlay: true,
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
        imageProvider: NetworkImage(url!),
      ));
    }
    if (type == "video") {
      return isLoading
          ? Container(
              child: Center(
                child: CircularLoadingIndicator(),
              ),
            )
          : Chewie(
              controller: _chewieController!,
              posterUrl: poster ?? "",
              titleName: "",
            );
    } else {
      return Container();
    }
  }
}
