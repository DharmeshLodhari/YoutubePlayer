import 'dart:io';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/moments/widgets/corner_radius_image.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreviewDeliveryProofScreen extends StatefulWidget {
  var arguments;

  PreviewDeliveryProofScreen({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<PreviewDeliveryProofScreen> createState() =>
      _PreviewDeliveryProofScreenState();
}

class _PreviewDeliveryProofScreenState
    extends State<PreviewDeliveryProofScreen> {
  late RiderDeliveryBloc riderDeliveryBloc;
  String? fileType;
  bool isVideoLoading = false;
  bool isTapped = false;
  VideoPlayerController? videoPlayerController;
  String? generatedVideoThumbnail;
  bool isLoading = false;

  @override
  void initState() {
    String? fType = getFileTypeByPath(path: widget.arguments["filePath"]);
    if (fType == null) return;
    fileType = fType;
    /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
    if (fileType == "video") {
      setUpVideoPlayer();
      generateThumbNailFromVideo(videoPath: widget.arguments["filePath"]);
    }

    super.initState();
  }

  @override
  void dispose() {
    // _chewieController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      // shadowColor: greySecondaryYarn,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: mediaRenderer(),
            ),
            SizedBox(height: 20.0),
            _buildButton()
          ],
        ),
      ),
    );
  }

  Widget mediaRenderer() {
    // if (fileType == "image") {
    //   return ClipRRect(
    //     borderRadius: BorderRadius.circular(0),
    //     child: Image(
    //       image: FileImage(
    //         File(riderRegistrationBloc.tempPicture?.path ?? ""),
    //       ),
    //     ),
    //   );
    // }
    if (fileType == "video") {
      if (isVideoLoading) {
        return Center(child: CircularLoadingIndicator());
      }
      return Container(
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            setState(() {
              isTapped = !isTapped;
              if (isTapped == true) {
                videoPlayerController?.play();
              } else {
                videoPlayerController?.pause();
              }
            });
          },
          child: CornerRadiusVideo(
            widget: Stack(
              children: [
                VideoPlayer(videoPlayerController!),
                isTapped == false
                    ? Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          "yarn/cam_vec".toSVG(),
                          height: 50,
                          width: 50,
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Image(
          image: FileImage(
            File(widget.arguments["filePath"]),
          ),
        ),
      );
    }
  }

  Widget _buildButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OutlineCurvedButton(
            text: "Retake",
            textColor: navyBlue,
            onPressed: () {
              Navigator.of(context).popAndPushNamed(Routes.TAKE_DELIVERY_PROOF);
            },
            backgroundColor: white,
          ),
        ),
        SizedBox(width: 15.0),
        Expanded(
          child: CurvedButton(
            onPressed: () {
              isLoading = true;
              if (mounted) setState(() {});
              sendDeliveryEvidence();
              isLoading = false;
              if (mounted) setState(() {});
            },
            backgroundColor: navyBlue,
            textColor: white,
            text: 'Use Photo',
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> sendDeliveryEvidence() async {
    await RiderDeliveryAuthService()
        .sendDeliveryEvidence(riderDeliveryBloc.deliveryDetails?.id,
            widget.arguments["filePath"], context)
        .then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.fileUploadedSuccessfully);
        Navigator.popAndPushNamed(context, Routes.DELIVERY_COMPLETED);
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  void setUpVideoPlayer() async {
    isVideoLoading = true;
    if (mounted) setState(() {});
    videoPlayerController = VideoPlayerController.file(
      File(widget.arguments["filePath"]),
    );
    await videoPlayerController?.initialize();
    await videoPlayerController?.setLooping(false);
    await videoPlayerController?.pause();
    isVideoLoading = false;
    if (mounted) setState(() {});
  }
}
