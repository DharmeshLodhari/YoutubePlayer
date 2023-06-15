import 'dart:async';

import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_video_player.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/utils/cached_video_player/cached_video_player.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';

import 'moment_dash_view.dart';

class RenderMoment extends StatefulWidget {
  final MomentsModel momentsModel;
  final List<CachedVideoPlayerController> videoPlayerControllers;
  final List<PhotoViewController> photoViewController;
  final List<MomentsModel> momentsModelList;

  final void Function() onRightSwipe;
  final int index;
  final PageController pageCtrl;
  final AnimationController controller;

  const RenderMoment(
      {Key? key,
      required this.momentsModel,
      required this.videoPlayerControllers,
      required this.onRightSwipe,
      required this.photoViewController,
      required this.index,
      required this.pageCtrl,
      required this.controller,
      required this.momentsModelList})
      : super(key: key);

  @override
  RenderMomentState createState() => RenderMomentState(key: key);
}

class RenderMomentState extends State<RenderMoment>
    with TickerProviderStateMixin {
  Key? key;
  RenderMomentState({this.key});

  GlobalKey<MomentVideoPlayerState> _momentVideoPlayerKey =
      GlobalKey<MomentVideoPlayerState>();
  PhotoViewController photoViewController = PhotoViewController();
  double? value;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      MomentsService().updateMomentView(widget.momentsModel.id!);
    });
    widget.photoViewController.add(photoViewController);
  }

  void toggleMediaPlayingState() {
    _momentVideoPlayerKey.currentState?.toggleVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('GLAD IMAGE MEDIATYPE -> ${widget.momentsModel.id}');
    debugPrint('GLAD IMAGE -> ${widget.momentsModel.media!}');
    if (widget.momentsModel.gif != null) {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.gif!,
        fit: BoxFit.fitWidth,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
      );
    }

    if (widget.momentsModel.mediaType == "image") {
      return Stack(
        children: [
          GestureDetector(
            onLongPress: () {
              widget.controller.stop();
            },
            onLongPressCancel: () {
              widget.controller.animateBack(value!);
            },
            child: PhotoView(
              //To be able to zoom the image.
              imageProvider: NetworkImage(widget.momentsModel.media!),
              controller: photoViewController,
              loadingBuilder: (context, event) {
                if (event?.cumulativeBytesLoaded == null ||
                    event?.expectedTotalBytes == null) {
                  value = 0.0;
                } else {
                  value =
                      event!.cumulativeBytesLoaded / event.expectedTotalBytes!;
                }
                return Center(
                  child: SpinKitRing(
                    lineWidth: 3.5,
                    color: navyBlue,
                    size: 45,
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: MomentDashView(
                currentPageViewIndex: widget.index,
                lengthOfMoment: widget.momentsModelList.length,
                controller: widget.controller,
                pageController: widget.pageCtrl,
                value: value ?? 0,
              ),
            ),
          )
        ],
      );
    } else if (widget.momentsModel.mediaType == "video") {
      if (widget.videoPlayerControllers.isNotEmpty &&
          widget
                  .videoPlayerControllers[
                      widget.videoPlayerControllers.length - 1]
                  .value
                  .isPlaying ==
              true) {
        value = 1.0;
      } else {
        value = 0.0;
      }
      return Stack(
        children: [
          MomentVideoPlayer(
            key: _momentVideoPlayerKey,
            momentsModel: widget.momentsModel,
            videoPlayerControllers: widget.videoPlayerControllers,
            controller: widget.controller,
            value:value,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: MomentDashView(
                currentPageViewIndex: widget.index,
                lengthOfMoment: widget.momentsModelList.length,
                controller: widget.controller,
                pageController: widget.pageCtrl,
                value: value ?? 0,
              ),
            ),
          )
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: blackFont.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }
  }
}
