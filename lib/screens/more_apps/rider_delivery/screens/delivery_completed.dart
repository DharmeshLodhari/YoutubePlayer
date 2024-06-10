import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class DeliveryCompleted extends StatefulWidget {
  final dynamic arguments;

  const DeliveryCompleted({Key? key, this.arguments}) : super(key: key);

  @override
  State<DeliveryCompleted> createState() => _DeliveryCompletedState();
}

class _DeliveryCompletedState extends State<DeliveryCompleted> {
  late RiderDeliveryBloc riderDeliveryBloc;
  late UserBloc userBloc;
  String? journeyId;
  bool isLoading = false;

  @override
  void initState() {
    if (widget.arguments['isCallAPI'] == true) {
      journeyId = widget.arguments['journeyId'];

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        fetchJobData();
      });
    }
    super.initState();
  }

  Future<void> fetchJobData() async {
    isLoading = true;
    if (mounted) setState(() {});
    await RiderDeliveryAuthService().fetchJob(journeyId).then((value) {
      if (value != null) {
        riderDeliveryBloc.updateDeliveryModel(value);
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
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: lightGrey,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDeliveryText(),
                  _buildImageOrderComplete(),
                  _buildRideNumber(),
                  const SizedBox(height: 15),
                  _buildEarningText(),
                  const SizedBox(height: 7),
                  _buildEarningAmount(),
                  _buildDivider(),
                  _buildIconAndAddressAndPickup(),
                  _buildDivider(),
                  _buildCircleImageAndName(),
                  _buildDivider(),
                  _buildDistance(),
                  const SizedBox(height: 15),
                  _buildDuration(),
                  const SizedBox(height: 15),
                  _buildItems(),
                  const SizedBox(height: 30),
                  _buildShareYourExperience(),
                  const SizedBox(height: 15),
                  _buildShareLater(),
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
    return Lottie.asset(
      'assets/lottie/completed.json',
      height: 180,
      width: 180,
    );
  }

  Widget _buildRideNumber() {
    return Text(
      'Ride #${riderDeliveryBloc.deliveryDetails?.orderId ?? ""}',
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
          worldCurrencies[riderDeliveryBloc.deliveryDetails?.currency] ?? 'NGN',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            color: navyBlue,
          ),
        ),
        Text(
          moneyDisplayNormalizer(
              riderDeliveryBloc.deliveryDetails?.riderPayment),
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
        const SizedBox(width: 7.0),
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
                child: CachedNetworkImage(
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
            )),
          ),
        ),
        const SizedBox(width: 10),
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

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineOne}, ${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineTwo}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 14,
            fontFamily: "Inter",
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
            'Pickup by ${riderDeliveryBloc.deliveryDetails?.convertDateFormat(riderDeliveryBloc.deliveryDetails?.expectedPickupTime.toString() ?? "")}',
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            )),
        const SizedBox(height: 20),
        Text(
          '${riderDeliveryBloc.deliveryDetails?.deliveryAddress?.addressLineOne}, ${riderDeliveryBloc.deliveryDetails?.deliveryAddress?.addressLineTwo}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 14,
            fontFamily: "Inter",
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deliver by ${riderDeliveryBloc.deliveryDetails?.convertDateFormat(riderDeliveryBloc.deliveryDetails?.expectedDeliveryTime.toString() ?? "")}',
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 20,
              ),
            ),
          ],
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
    final DateTime? pickupTime =
        riderDeliveryBloc.deliveryDetails?.actualDeliveryTime;
    final DateTime? deliveryTime =
        riderDeliveryBloc.deliveryDetails?.actualPickupTime;
    final Duration? duration = pickupTime?.difference(deliveryTime!);

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

  Widget _buildShareYourExperience() {
    return CurvedButton(
      text: 'Share your experience',
      textColor: white,
      backgroundColor: navyBlue,
      fontSize: 15,
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.SHARE_EXPERIENCE);
      },
    );
  }

  Widget _buildShareLater() {
    return OutlineCurvedButton(
      text: "Share Later",
      textColor: navyBlue,
      onPressed: () {
        Navigator.of(context).popUntil(ModalRoute.withName(Routes.SUPER_HUB));
      },
      backgroundColor: white,
    );
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
}
