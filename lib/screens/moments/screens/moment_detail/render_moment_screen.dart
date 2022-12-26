import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_video_player.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/utils/cached_video_player/cached_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class RenderMoment extends StatefulWidget {
  final MomentsModel momentsModel;
  final List<CachedVideoPlayerController> videoPlayerControllers;
  final List<PhotoViewController> photoViewController;

  const RenderMoment(
      {Key? key,
      required this.momentsModel,
      required this.videoPlayerControllers,
      required this.photoViewController})
      : super(key: key);

  @override
  RenderMomentState createState() => RenderMomentState(key: key);
}

class RenderMomentState extends State<RenderMoment> {
  Key? key;
  RenderMomentState({this.key});

  GlobalKey<MomentVideoPlayerState> _momentVideoPlayerKey =
      GlobalKey<MomentVideoPlayerState>();
  PhotoViewController photoViewController = PhotoViewController();

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
      return PhotoView(
        //To be able to zoom the image.
        imageProvider: NetworkImage(widget.momentsModel.media!),
        controller: photoViewController,
      );

      return CachedNetworkImage(
        imageUrl: widget.momentsModel.media!,
        fit: BoxFit.fitWidth,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        placeholder: (context, _) {
          return Container(color: Colors.grey);
        },
      );
    } else if (widget.momentsModel.mediaType == "video") {
      return MomentVideoPlayer(
          key: _momentVideoPlayerKey,
          momentsModel: widget.momentsModel,
          videoPlayerControllers: widget.videoPlayerControllers);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Color(0XFFdcdcdc).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }
  }
}
