import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/customer_view_map.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RiderMapStatus extends StatefulWidget {
  var arguments;
  RiderMapStatus({super.key, this.arguments});

  @override
  State<RiderMapStatus> createState() => _RiderMapStatusState();
}

class _RiderMapStatusState extends State<RiderMapStatus> {
  double _initialSheetChildSize = 0.0;
  // late RiderDeliveryBloc riderDeliveryBloc;
  DeliveryModel? deliveryModel;
  CustomerProfile? customerProfile;
  bool isLoading = false;

  @override
  void initState() {
    _initialSheetChildSize = 0.35;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    fetchJobData();
    // });
    super.initState();
  }

  Future<void> fetchJobData() async {
    isLoading = true;
    if (mounted) setState(() {});

    await RiderDeliveryAuthService()
        .fetchJob(widget.arguments["journey_id"])
        .then((value) async {
      if (value != null) {
        deliveryModel = value;

        if (deliveryModel?.acceptedBy != null) {
          customerProfile =
              await UserAuth().fetchCustomerProfile(deliveryModel?.acceptedBy);
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
    // riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
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
                    child: CustomerViewMap(
                      journeyDetail: deliveryModel,
                    ),
                  ),
                ],
              ),
              _buildArriving(),
            ],
          );
  }

  Widget _buildArriving() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          color: white,
          child: getArrivingDetails(),
        ),
      ),
    );
  }

  Widget getArrivingDetails() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
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
          SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrivingPartner(),
                SizedBox(height: 30),
                _buildPartnerContactIcon(),
              ],
            ),
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
                  arguments: customerProfile?.avatar);
            },
            child: Container(
              color: Colors.white,
              child: CachedNetworkImage(
                height: 70,
                width: 70,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                imageUrl: customerProfile?.avatar ?? "",
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerProfile?.nickName ?? "",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: "Inter",
              ),
            ),
            SizedBox(height: 5),
            Text(
              customerProfile?.userName ?? "",
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

  Widget _buildPartnerContactIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
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
