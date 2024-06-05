import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/overlay_yarn_photo.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:video_player/video_player.dart';

class ViewCompletedDelivery extends StatefulWidget {
  var arguments;

  ViewCompletedDelivery({Key? key, this.arguments}) : super(key: key);

  @override
  State<ViewCompletedDelivery> createState() => _ViewCompletedDeliveryState();
}

class _ViewCompletedDeliveryState extends State<ViewCompletedDelivery> {
  late RiderDeliveryBloc riderDeliveryBloc;
  late UserBloc userBloc;
  String? journeyId;
  bool isLoading = false;
  String? fileType;
  String? generatedVideoThumbnail;
  bool isVideoLoading = false;
  bool isTapped = false;
  VideoPlayerController? videoPlayerController;
  StreamController<Widget> overlayController =
      StreamController<Widget>.broadcast();

  @override
  void initState() {
    if (widget.arguments['isCallAPI'] == true) {
      journeyId = widget.arguments['journeyId'];

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await fetchJobData();
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  fetchJobData() async {
    isLoading = true;
    if (mounted) setState(() {});
    await RiderDeliveryAuthService().fetchJob(journeyId).then((value) {
      if (value != null) {
        riderDeliveryBloc.updateDeliveryModel(value);

        final String? fType = getFileTypeByPath(
            path: riderDeliveryBloc.deliveryDetails?.deliveryEvidence ?? "");
        if (fType == null) return;
        fileType = fType;
        /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
        if (fileType == "video") {
          setUpVideoPlayer();
          generateThumbNailFromVideo(
                  videoPath:
                      riderDeliveryBloc.deliveryDetails?.deliveryEvidence ?? "")
              .then((thumbnail) {
            if (thumbnail != null) {
              generatedVideoThumbnail = thumbnail;
              debugPrint('file path gen -> $generatedVideoThumbnail');
            }
          });
        }
        isLoading = false;
        if (mounted) setState(() {});
      }
    }).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: lightGrey,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      title: Text(
        'Delivery History',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
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
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody() {
    return isLoading
        ? const YarnShimmer()
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDeliveryData(),
                  const SizedBox(height: 20),
                  _buildDeliveredTo(),
                  const SizedBox(height: 10),
                  _buildDistance(),
                  const SizedBox(height: 15),
                  _buildDuration(),
                  const SizedBox(height: 15),
                  _buildItems(),
                  _buildDivider(),
                  _buildDeliveryProof(),
                ],
              ),
            ),
          );
  }

  Widget _buildDeliveryData() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: greyBorderColor,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 12.0),
            child: _buildDateAndWaitingButton(),
          ),
          DeliveryOrderTile(
            jobListing: riderDeliveryBloc.deliveryDetails,
            showRightArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndWaitingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildDate()),
        _buildWaitingButton(),
      ],
    );
  }

  Widget _buildDate() {
    final String date = DateFormat("dd MMMM,yyyy")
        .format(riderDeliveryBloc.deliveryDetails?.createdAt as DateTime);
    return Text(
      date,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: darkGrey,
        fontSize: 12,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildWaitingButton() {
    final Color color = getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        riderDeliveryBloc.deliveryDetails?.status ?? "",
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Color getStatusColor() {
    switch (riderDeliveryBloc.deliveryDetails?.status) {
      case 'Awaiting Pickup':
        return starYellow;
      case 'Pending':
        return darkGrey;
      case 'Ongoing':
        return navyBlue;
      case 'Completed':
        return naturalGreen;
      case 'Delivered':
        return naturalGreen;
      case 'Canceled':
        return mateRed;
      default:
        return navyBlue;
    }
  }

  Widget _buildDeliveredTo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Delivered to :",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        _buildCircleImageAndName(),
      ],
    );
  }

  Widget _buildCircleImageAndName() {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(color: white, width: 2)),
          child: GestureDetector(
            onTap: () {
              // Navigator.of(context)
              //     .pushNamed("/photo-viewer", arguments: _payee!.avatar);
            },
            child: ClipOval(
              child: defaultImage != null
                  ? CachedNetworkImage(
                      imageUrl: userBloc.user.avatar == ""
                          ? defaultImage
                          : userBloc.user.avatar!,
                      colorBlendMode: BlendMode.darken,
                      fit: BoxFit.cover,
                      errorWidget: imageErrorWidget,
                      height: double.infinity,
                      filterQuality: FilterQuality.high,
                      placeholder: (context, _) => CachedNetworkImage(
                        imageUrl: defaultImage,
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          userBloc.user.nickName ?? "",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
            color: blackFont,
          ),
        ),
      ],
    );
  }

  Widget _buildDistance() {
    // var _distanceInMeters = Geolocator.distanceBetween(
    //   riderDeliveryBloc.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
    //   riderDeliveryBloc.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
    //   riderDeliveryBloc.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
    //   riderDeliveryBloc.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
    // );
    // double distanceInKiloMeters = _distanceInMeters / 1000;
    // double roundDistanceInKM =
    //     double.parse((distanceInKiloMeters).toStringAsFixed(2));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Distance Covered",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "${riderDeliveryBloc.deliveryDetails?.totalDistance ?? 10} km",
          style: TextStyle(
            color: navyBlue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        )
      ],
    );
  }

  Widget _buildDuration() {
    DateTime? pickupTime =
        riderDeliveryBloc.deliveryDetails?.actualDeliveryTime;
    DateTime? deliveryTime =
        riderDeliveryBloc.deliveryDetails?.actualPickupTime;
    Duration? duration = pickupTime?.difference(deliveryTime!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Duration",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "${duration?.inHours}hr ${(duration?.inMinutes ?? 0) % 60}mins",
          style: TextStyle(
            color: black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        )
      ],
    );
  }

  Widget _buildItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Items (${riderDeliveryBloc.deliveryDetails?.totalNoOfItems})",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "${riderDeliveryBloc.deliveryDetails?.totalWeight} kg",
          style: TextStyle(
            color: black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryProof() {
    if (fileType == "image") {
      return GestureDetector(
        onTap: () async {
          return await showSliderGallery(
              [riderDeliveryBloc.deliveryDetails?.deliveryEvidence ?? ""]);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            imageUrl: riderDeliveryBloc.deliveryDetails?.deliveryEvidence ?? "",
            fit: BoxFit.fill,
            width: double.infinity,
            height: 270,
            errorWidget: imageErrorWidget,
          ),
        ),
      );
    } else if (fileType == "video") {
      return isVideoLoading
          ? Center(child: CircularLoadingIndicator())
          : Container(
              width: double.infinity,
              height: 270,
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(children: [
                              VideoPlayer(videoPlayerController!),
                              if (generatedVideoThumbnail != null &&
                                  isTapped == false)
                                Center(
                                  child: Image(
                                    width: double.infinity,
                                    height: 270,
                                    image: FileImage(
                                      File(generatedVideoThumbnail ?? ""),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (isTapped == false)
                                Align(
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    "yarn/cam_vec".toSVG(),
                                    height: 50,
                                    width: 50,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
    } else {
      return const SizedBox();
    }
  }

  Future<void> showSliderGallery(List<String?>? displayProductImages) {
    final List<Widget> imageList = [];

    for (var item in displayProductImages ?? []) {
      imageList.add(Image.network(item));
    }
    return SwipeImageGallery(
      context: context,
      children: imageList,
      onSwipe: (index) {
        overlayController.add(OverlayYarnPhoto(
          title: '${index + 1}/${imageList.length}',
        ));
      },
      overlayController: overlayController,
      initialOverlay: OverlayYarnPhoto(
        title: '1/${imageList.length}',
      ),
    ).show();
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
      child: Divider(
        color: greyBorderColor,
        thickness: 0.8,
      ),
    );
  }

  void setUpVideoPlayer() async {
    isVideoLoading = true;
    if (mounted) setState(() {});

    videoPlayerController = VideoPlayerController.network(
        riderDeliveryBloc.deliveryDetails?.deliveryEvidence ?? "");

    await videoPlayerController?.initialize();
    await videoPlayerController?.setLooping(false);

    await videoPlayerController?.pause();

    isVideoLoading = false;
    if (mounted) setState(() {});
  }
}
