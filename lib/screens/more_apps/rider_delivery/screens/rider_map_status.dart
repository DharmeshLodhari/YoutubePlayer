import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/customer_view_map.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderMapStatus extends StatefulWidget {
  final dynamic arguments;
  const RiderMapStatus({super.key, this.arguments});

  @override
  State<RiderMapStatus> createState() => _RiderMapStatusState();
}

class _RiderMapStatusState extends State<RiderMapStatus> {
  DeliveryModel? deliveryModel;
  bool isLoading = false;

  @override
  void initState() {
    deliveryModel = widget.arguments["journey_details"];
    super.initState();
  }

  // Future<void> fetchJobData() async {
  //   isLoading = true;
  //   if (mounted) setState(() {});
  //
  //   await RiderDeliveryAuthService()
  //       .fetchJob(widget.arguments["journey_id"])
  //       .then((value) async {
  //     if (value != null) {
  //       deliveryModel = value;
  //
  //       isLoading = false;
  //       if (mounted) setState(() {});
  //     }
  //   }).catchError((error) {
  //     isLoading = false;
  //     if (mounted) setState(() {});
  //     debugPrint(error.toString());
  //     showToast(message: error.toString());
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
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
      surfaceTintColor: Colors.transparent,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Driving',
        style: TextStyle(
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
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
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: CustomerViewMap(
                      journeyDetail: deliveryModel,
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
              _buildArriving(),
            ],
          );
  }

  Widget _buildArriving() {
    // return DraggableScrollableSheet(
    //   initialChildSize: 0.35,
    //   maxChildSize: 0.35,
    //   minChildSize: 0.15,
    //   builder: (context, scrollController) {
    //     return Container(
    //       clipBehavior: Clip.hardEdge,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).canvasColor,
    //         borderRadius: const BorderRadius.only(
    //           topLeft: Radius.circular(25),
    //           topRight: Radius.circular(25),
    //         ),
    //       ),
    //       child: SingleChildScrollView(
    //         controller: scrollController,
    //         child: getArrivingDetails(),
    //       ),
    //     );
    //   },
    // );
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.3,
      minChildSize: 0.15,
      builder: (context, scrollController) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: getArrivingDetails(),
        ),
      ),
    );
  }

  Widget getArrivingDetails() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: [
          Container(
            height: 2,
            width: 12.0.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: greyBorderColor,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrivingPartner(),
              const SizedBox(height: 30),
              _buildPartnerContactIcon(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrivingPartner() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("/photo-viewer",
                  arguments: deliveryModel?.dispatcherAvatar);
            },
            child: Container(
              color: Colors.white,
              child: CachedNetworkImage(
                height: 70,
                width: 70,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                imageUrl: deliveryModel?.dispatcherAvatar ?? "",
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deliveryModel?.dispatcherFullName ?? "",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 5),
            Text(
              deliveryModel?.dispatcher ?? "",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: deliveryModel?.dispatcherNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildPartnerContactIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            _makePhoneCall();
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 60,
                height: 60,
                color: white,
                child: Image.asset(
                  "assets/images/phone_call_icon.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ),
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 0, end: 0),
          badgeStyle: badges.BadgeStyle(
            badgeColor: navyBlue,
          ),
          badgeContent: Text(
            "2",
            style: TextStyle(
              color: white,
              fontSize: 13,
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/chat-screen',
                  arguments: {"recipientUserName": deliveryModel?.dispatcher});
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 60,
                  height: 60,
                  color: white,
                  child: Image.asset(
                    "assets/images/message_icon.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.CANCELLATION);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 60,
                height: 60,
                color: white,
                child: Image.asset(
                  "assets/images/close_icon.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
