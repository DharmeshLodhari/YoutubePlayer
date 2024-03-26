import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class DeliveryCompleted extends StatefulWidget {
  @override
  State<DeliveryCompleted> createState() => _DeliveryCompletedState();
}

class _DeliveryCompletedState extends State<DeliveryCompleted> {
  @override
  Widget build(BuildContext context) {
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
            // appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDeliveryText(),
            _buildImageOrderComplete(),
            _buildRideNumber(),
            SizedBox(height: 15),
            _buildEarningText(),
            SizedBox(height: 7),
            _buildEarningAmount(),
            _buildDivider(),
            _buildIconAndAddressAndPickup(),
            _buildDivider(),
            _buildCircleImageAndName(),
            _buildDivider1(),
            _buildDistance(),
            SizedBox(height: 15),
            _buildDuration(),
            SizedBox(height: 15),
            _buildItems(),
            SizedBox(height: 25),
            _buildShareYourExperience(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryText() {
    return Text(
      "Delivery Complete!!!",
      style: TextStyle(
        fontSize: 16,
        fontFamily: "Inter",
        fontWeight: FontWeight.w600,
        color: blackFont,
      ),
    );
  }

  Widget _buildImageOrderComplete() {
    return Lottie.asset('assets/lottie/successful.json',
        height: 180, width: 180);
  }

  Widget _buildRideNumber() {
    return Text(
      'Ride #267',
      style: TextStyle(
        fontSize: 18,
        fontFamily: "Inter",
        fontWeight: FontWeight.w700,
        color: blackFont,
      ),
    );
  }

  Widget _buildEarningText() {
    return Text(
      "Your Earning",
      style: TextStyle(
        fontSize: 16,
        fontFamily: "Inter",
        fontWeight: FontWeight.w600,
        color: black,
      ),
    );
  }

  Widget _buildEarningAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "₦",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            color: navyBlue,
          ),
        ),
        Text(
          "3,000.00",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            color: navyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildIconAndAddressAndPickup() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconImage(),
        SizedBox(width: 7.0),
        Expanded(child: _buildMainAddressColumn())
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 55,
    );
  }

  Widget _buildCircleImageAndName() {
    return Row(
      children: [
        Container(
          height: 37,
          width: 37,
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
                      imageUrl: defaultImage,
                      colorBlendMode: BlendMode.darken,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      errorWidget: imageErrorWidget,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Tolani James',
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
            color: blackFont,
          ),
        ),
      ],
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KFC, O&O Filling station berger  expressway',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackFont,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(height: 25),
        Text(
          '46  Musa Johnson Road, Agege',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackFont,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildDistance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Distance Covered",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            Text(
              "23",
              style: TextStyle(
                color: navyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "km",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Duration",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            Text(
              "1",
              style: TextStyle(
                color: navyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "hr",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              " 30",
              style: TextStyle(
                color: navyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "mins",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "8 items",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            Text(
              "36",
              style: TextStyle(
                color: navyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "kg",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildShareYourExperience() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CurvedButton(
        text: 'Share your experience',
        textColor: white,
        backgroundColor: navyBlue,
        fontSize: 15,
        onPressed: () {
          Navigator.of(context).popAndPushNamed(Routes.SHARE_EXPERIENCE);
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
      child: Divider(
        color: greyBorderColor,
        thickness: 0.8,
      ),
    );
  }

  Widget _buildDivider1() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      child: Divider(
        color: greyBorderColor,
        thickness: 0.8,
      ),
    );
  }
}
