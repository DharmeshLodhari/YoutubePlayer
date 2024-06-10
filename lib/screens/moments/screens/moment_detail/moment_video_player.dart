import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/utils/cached_video_player/cached_video_player.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MomentVideoPlayer extends StatefulWidget {
  final MomentsModel momentsModel;
  final List<CachedVideoPlayerController> videoPlayerControllers;
  final AnimationController controller;
  final double? value;

  MomentVideoPlayer(
      {Key? key,
      required this.momentsModel,
      required this.videoPlayerControllers,
      required this.value,
      required this.controller})
      : super(key: key);

  @override
  MomentVideoPlayerState createState() => MomentVideoPlayerState(key: key);
}

class MomentVideoPlayerState extends State<MomentVideoPlayer> {
  bool initialized = false;
  bool showMediaIcon = false;

  // late VideoPlayerManager videoPlayerManager;

  late CachedVideoPlayerController _controller;

  Key? key;

  MomentVideoPlayerState({this.key});

  @override
  void initState() {
    debugPrint('VIDEO MEDIA --> ${widget.momentsModel.media!.length}');
    // videoPlayerManager = VideoPlayerManager();
    // videoPlayerManager.init(widget.momentsModel.media!);
    // widget.controller.stop();

    _controller = CachedVideoPlayerController.network(
      widget.momentsModel.media!,
    )..initialize().then((value) async {
        await _controller.play();
        widget.controller.forward();
        initialized = true;
        setState(() {});
      }).catchError((e) {
        Navigator.pop(context);
        showToast(message: 'Unable to display moment');
      });

    _controller.addListener(() {
      if (_controller.value.isBuffering) {
        if (widget.controller.isAnimating) {
          debugPrint("BUFFERING !! STOPPING ANIMATION CONTROLLER");
          widget.controller.stop();
        }
      } else {
        debugPrint("NOT BUFFERING !!");
        if (widget.controller.isAnimating == false) {
          debugPrint("NOT BUFFERING !! STARTIING ANIMATION CONTROLLER");
          widget.controller.forward();
        }
      }
    });

    widget.videoPlayerControllers.add(_controller);
    super.initState();
  }

  void toggleVideoPlayer() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      widget.controller.stop();
    } else {
      _controller.play();
      widget.controller.forward();
    }
  }

  @override
  void dispose() async {
    //await videoPlayerManager.dispose();
    // for (var controller in widget.videoPlayerControllers) {
    //   controller.dispose();
    // }
    try {
      _controller.dispose();
    } catch (error) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return FittedBox(
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: InkWell(
              onTap: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  widget.controller.stop();
                  showMediaIconFor2Seconds();
                } else {
                  _controller.play();
                  widget.controller.forward();
                  showMediaIconFor2Seconds();
                }
              },
              child: Stack(
                children: [
                  CachedVideoPlayer(_controller),
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: showMediaIcon,
                      child: RoundedBackgroundIcon(
                        width: 60,
                        height: 80,
                        borderRadius: 50,
                        icon: Icon(
                          !_controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          Center(child: CircularLoadingIndicator()),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    debugPrint("poster ${widget.momentsModel.mediaPoster}");
    if (widget.momentsModel.mediaPoster != null) {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.mediaPoster!,
        fit: BoxFit.fitWidth,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        placeholder: (context, _) {
          return Container(color: black);
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }
  }

  showMediaIconFor2Seconds() {
    setState(() => showMediaIcon = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showMediaIcon = false;
        });
      }
    });
  }
}
