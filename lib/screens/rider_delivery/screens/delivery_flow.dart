import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/rider_delivery/models/near_by_location.dart';
import 'package:Slydo/screens/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/screens/rider_delivery/tiles/rider_delivery_map.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryFlow extends StatefulWidget {
  final dynamic arguments;

  const DeliveryFlow({super.key, this.arguments});

  @override
  State<DeliveryFlow> createState() => _DeliveryFlowState();
}

class _DeliveryFlowState extends State<DeliveryFlow> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? journeyId;
  bool isRejectAPILoading = false;
  bool isAcceptAPILoading = false;
  bool isPickupLocationAPILoading = false;
  bool isDeliveryLocationAPILoading = false;
  bool isStartAPILoading = false;
  bool isEndedAPILoading = false;
  bool isCancelAPILoading = false;

  Key key = const Key("map");
  bool? isDeliveryCancel = false;
  bool? isRiderAtPickupLocation = false;
  bool? isRiderAtDeliveryLocation = false;
  bool? isChecked = false;
  late UserBloc userBloc;
  late RiderDeliveryBloc riderDeliveryBloc;
  String? username = "";
  final DatabaseHelper _db = DatabaseHelper();
  TextEditingController? codeController;

  List<String> reasons = [
    "Wrong destination",
    "Client not picking up call",
    "Wrong pickup location",
    "The price is not reasonable",
    "Pickup address is incorrect",
    "Damaged Package",
    "Traffic",
  ];
  String? userChecked;
  bool isLoading = false;

  GlobalKey mapKey = GlobalKey();

  @override
  void initState() {
    journeyId = widget.arguments['journeyId'];

    fetchJobData();
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
    userBloc = Provider.of<UserBloc>(context);
    username = userBloc.user.userName;
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
      surfaceTintColor: Colors.transparent,
      backgroundColor: white,
      title: Text(
        'Ride #${riderDeliveryBloc.deliveryDetails?.orderId ?? ""}',
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
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 7,
                    child: RiderDeliveryMap(key: mapKey),
                  ),
                  Expanded(child: Container())
                ],
              ),
              _buildJobAction(),
            ],
          );
  }

  Widget _buildJobAction() {
    if (riderDeliveryBloc.deliveryDetails?.isOfferAccepted(username) == false) {
      return _buildShowDetails();
    } else if (riderDeliveryBloc.deliveryDetails
                ?.isAfterOfferAccepted(username) ==
            true &&
        isDeliveryCancel == false) {
      return _buildAccepted();
    } else if (riderDeliveryBloc.deliveryDetails?.isOfferStarted(username) ==
        true) {
      return _buildStarted();
    } else if (riderDeliveryBloc.deliveryDetails?.isOfferEnded(username) ==
        true) {
      return _buildEnded();
    } else if (isDeliveryCancel == true) {
      return _buildCancel();
    } else {
      return Container();
    }
  }

  Widget _buildShowDetails() {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      maxChildSize: 0.38,
      minChildSize: 0.15,
      builder: (BuildContext context, scrollController) {
        return Container(
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
            child: getDeliveryDetails(),
          ),
        );
      },
    );
  }

  Widget _buildAccepted() {
    return DraggableScrollableSheet(
      initialChildSize: 0.47,
      maxChildSize: 0.47,
      minChildSize: 0.20,
      builder: (context, scrollController) {
        return Container(
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
            child: startDelivery(),
          ),
        );
      },
    );
  }

  Widget _buildStarted() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.45,
      minChildSize: 0.15,
      builder: (context, scrollController) {
        return Container(
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
            child: endDelivery(),
          ),
        );
      },
    );
  }

  Widget _buildEnded() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.3,
      minChildSize: 0.15,
      builder: (context, scrollController) {
        return Container(
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
            child: deliveryProof(),
          ),
        );
      },
    );
  }

  Widget _buildCancel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.73,
      maxChildSize: 0.73,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
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
            child: cancelDelivery(),
          ),
        );
      },
    );
  }

  Widget getDeliveryDetails() {
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
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliveryOrderTile(
                    jobListing: riderDeliveryBloc.deliveryDetails),
                const SizedBox(height: 10.0),
                _buildButtonAcceptReject(),
              ],
            ),
          ],
        ));
  }

  Widget startDelivery() {
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
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDrivingToPickupLocation(),
                const SizedBox(height: 15.0),
                _buildDistanceAndHoursAndImageAndAddress(
                  pickupAddress: "Your Current Location",
                  deliveryAddress:
                      '${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineOne}, ${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineTwo}',
                ),
                const SizedBox(height: 10.0),
                if (riderDeliveryBloc
                        .deliveryDetails?.riderAtLocation?.atPickupLocation ==
                    true)
                  _buildCheckBoxAndItems(),
                if (riderDeliveryBloc
                        .deliveryDetails?.riderAtLocation?.atPickupLocation ==
                    true)
                  _buildStartDelivery()
                else
                  _buildAtPickupLocation(),
                const SizedBox(height: 15.0),
                _buildCancelDelivery(),
                const SizedBox(height: 15.0),
                _buildCallSender(),
              ],
            ),
          ],
        ));
  }

  Widget endDelivery() {
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
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDrivingToDestination(),
              const SizedBox(height: 10.0),
              _buildDistanceAndHoursAndImageAndAddress(
                  pickupAddress:
                      '${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineOne}, ${riderDeliveryBloc.deliveryDetails?.pickupAddress?.addressLineTwo}',
                  deliveryAddress:
                      '${riderDeliveryBloc.deliveryDetails?.deliveryAddress?.addressLineOne}, ${riderDeliveryBloc.deliveryDetails?.deliveryAddress?.addressLineTwo}'),
              const SizedBox(height: 10.0),
              _buildItems(),
              const SizedBox(height: 15.0),
              if (riderDeliveryBloc
                      .deliveryDetails?.riderAtLocation?.atDeliveryLocation ==
                  true)
                _buildEndDelivery()
              else
                _buildAtDeliveryLocation(),
              const SizedBox(height: 15.0),
              _buildCallReceiver(),
            ],
          ),
        ],
      ),
    );
  }

  Widget deliveryProof() {
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
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDeliveryProofTitle(),
              const SizedBox(height: 20.0),
              _buildQRCode(),
              const SizedBox(height: 20.0),
              _buildTakePicture(),
            ],
          ),
        ],
      ),
    );
  }

  Widget cancelDelivery() {
    return Form(
      key: _formKey,
      child: Container(
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
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 10.0),
                  _buildCancelDeliveryReason(),
                  const SizedBox(height: 10.0),
                  _buildSubmitButton(),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildButtonAcceptReject() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: CurvedButton(
              text: 'Reject',
              textColor: white,
              backgroundColor: redBtn,
              fontSize: 15,
              onPressed: isRejectAPILoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      isRejectAPILoading = true;
                      if (mounted) setState(() {});
                      await rejectOffer();
                      isRejectAPILoading = false;
                      if (mounted) setState(() {});
                    },
              isLoading: isRejectAPILoading,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: CurvedButton(
              text: 'Accept',
              textColor: white,
              backgroundColor: navyBlue,
              fontSize: 15,
              onPressed: isAcceptAPILoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAcceptAPILoading = true;
                      if (mounted) setState(() {});
                      await acceptOffer();
                      mapKey = GlobalKey();
                      isAcceptAPILoading = false;
                      if (mounted) setState(() {});
                    },
              isLoading: isAcceptAPILoading,
            ),
          )
        ],
      ),
    );
  }

  Future<void> rejectOffer() async {
    await RiderDeliveryAuthService()
        .rejectOffer(riderDeliveryBloc.deliveryDetails?.id)
        .then((value) {
      if (value == true) {
        Future.delayed(const Duration(seconds: 2)).then((value) => () {
              showToast(
                  message: AppLocalization.of(context)!.jobRemovedFromListing);
              Navigator.pop(context, 'HomeScreen');
            });
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> acceptOffer() async {
    await RiderDeliveryAuthService()
        .acceptOffer(riderDeliveryBloc.deliveryDetails?.id)
        .then((value) async {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobAcceptedFromListing);
        // riderDeliveryBloc.deliveryDetails?.isShowDetails = false;
        // riderDeliveryBloc.deliveryDetails?.isDeliveryAccepted = true;
        // _initialSheetChildSize = 0.45;
        await riderDeliveryBloc
            .refreshJobDetail(riderDeliveryBloc.deliveryDetails?.id);
        setState(() {});
      } else {
        showToast(message: 'Offer already accepted by a dispatcher');
        Navigator.pop(context, 'HomeScreen');
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Widget _buildDrivingToPickupLocation() {
    return Center(
      child: Text(
        riderDeliveryBloc.isNearbyPickupLocation == false
            ? 'Driving to pickup location'
            : 'You have arrived at the pickup location',
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildDrivingToDestination() {
    return Center(
      child: Text(
        riderDeliveryBloc.isNearbyDestinationLocation == false
            ? 'Driving to destination'
            : 'You have arrived at the destination',
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildDistanceAndHoursAndImageAndAddress(
      {String? pickupAddress, String? deliveryAddress}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDistanceAndHours(),
        const SizedBox(width: 15.0),
        _buildRouteIconImage(),
        _buildAddressColumn(pickupAddress, deliveryAddress),
      ],
    );
  }

  Widget _buildDistanceAndHours() {
    final Duration? duration =
        riderDeliveryBloc.deliveryDetails?.travelDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Distance",
          style: TextStyle(
            color: blackFont,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Text(
              duration?.inMinutes.toString() ?? "0",
              style: TextStyle(
                color: blackFont,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'minutes to your\nPickup location',
              style: TextStyle(
                color: blackFont,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteIconImage() {
    return Image.asset(
      'assets/images/taxi/route.png',
      height: 65,
    );
  }

  Widget _buildAddressColumn(String? pickupAddress, String? deliveryAddress) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pickupAddress ?? "",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: riderDeliveryBloc.deliveryDetails
                          ?.isOfferAccepted(username) ==
                      true
                  ? darkGrey
                  : blackFont,
              fontSize: 12,
              fontFamily: "Inter",
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 25),
          Text(
            deliveryAddress ?? "",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: riderDeliveryBloc.deliveryDetails
                          ?.isOfferAccepted(username) ==
                      true
                  ? blackFont
                  : darkGrey,
              fontSize: 12,
              fontFamily: "Inter",
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckBoxAndItems() {
    return Row(
      children: [
        Checkbox(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            checkColor: white,
            activeColor: navyBlue,
            value: isChecked,
            onChanged: (bool? val) {
              setState(() {
                isChecked = val!;
                if (isChecked == true) {
                  RiderDeliveryAuthService().riderPickupOrder(
                      riderDeliveryBloc.deliveryDetails?.orderId);
                }
              });
            }),
        Text(
          "I have picked up - ${riderDeliveryBloc.deliveryDetails?.totalNoOfItems} Items (${riderDeliveryBloc.deliveryDetails?.totalWeight}kg)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isChecked == true ? blackFont : darkGrey,
            fontFamily: "Inter",
          ),
        )
      ],
    );
  }

  Widget _buildItems() {
    return Row(
      children: [
        Text(
          "${riderDeliveryBloc.deliveryDetails?.totalNoOfItems} Items (${riderDeliveryBloc.deliveryDetails?.totalWeight}kg)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: black,
            fontFamily: "Inter",
          ),
        )
      ],
    );
  }

  Widget _buildAtPickupLocation() {
    return CurvedButton(
      text: 'I am at pickup location',
      backgroundColor: navyBlue,
      textColor: white,
      onPressed: () async {
        if (isPickupLocationAPILoading == false) {
          FocusScope.of(context).unfocus();
          isPickupLocationAPILoading = true;
          if (mounted) setState(() {});
          await riderAtPickupLocation();
          mapKey = GlobalKey();
          isPickupLocationAPILoading = false;
          if (mounted) setState(() {});
        }
      },
      isLoading: isPickupLocationAPILoading,
    );
  }

  Widget _buildAtDeliveryLocation() {
    return CurvedButton(
      text: 'I am at drop off location',
      backgroundColor: navyBlue,
      textColor: white,
      onPressed: () async {
        if (isDeliveryLocationAPILoading == false) {
          FocusScope.of(context).unfocus();
          isDeliveryLocationAPILoading = true;
          if (mounted) setState(() {});
          await riderAtDeliveryLocation();
          mapKey = GlobalKey();
          isDeliveryLocationAPILoading = false;
          if (mounted) setState(() {});
        }
      },
      isLoading: isDeliveryLocationAPILoading,
    );
  }

  Widget _buildStartDelivery() {
    return CurvedButton(
      text: 'Start Delivery',
      backgroundColor: isChecked == true ? navyBlue : greyBorderColor,
      textColor: white,
      onPressed: isChecked == true
          ? () async {
              if (isStartAPILoading == false) {
                FocusScope.of(context).unfocus();
                isStartAPILoading = true;
                if (mounted) setState(() {});
                await startOffer();
                mapKey = GlobalKey();
                isStartAPILoading = false;
                if (mounted) setState(() {});
              }
            }
          : null,
      isLoading: isStartAPILoading,
    );
  }

  Widget _buildCancelDelivery() {
    return OutlineCurvedButton(
      text: "Cancel Delivery",
      textColor: navyBlue,
      onPressed: () {
        // riderDeliveryBloc.deliveryDetails?.isDeliveryAccepted = false;
        isDeliveryCancel = true;
        // _initialSheetChildSize = 0.73;
        setState(() {});
      },
      backgroundColor: white,
    );
  }

  Widget _buildCallSender() {
    return GestureDetector(
      onTap: () {
        _makePhoneCall(riderDeliveryBloc.deliveryDetails?.pickupAddress?.phone);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.phone_in_talk_outlined,
            size: 25,
          ),
          const SizedBox(width: 10.0),
          Text(
            "Tap to call package sender",
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallReceiver() {
    return GestureDetector(
      onTap: () {
        _makePhoneCall(
            riderDeliveryBloc.deliveryDetails?.deliveryAddress?.phone);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.phone_in_talk_outlined,
            size: 25,
          ),
          const SizedBox(width: 10.0),
          Text(
            "Tap to call package receiver",
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          )
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String? phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone ?? "",
    );
    await launchUrl(launchUri);
  }

  Future<void> riderAtPickupLocation() async {
    await RiderDeliveryAuthService()
        .atPickupLocation(riderDeliveryBloc.deliveryDetails?.orderId)
        .then((value) async {
      if (value == true) {
        showToast(message: 'You have arrived at the pickup location');
        // riderDeliveryBloc.deliveryDetails?.isDeliveryAccepted = false;
        // riderDeliveryBloc.deliveryDetails?.isDeliveryStarted = true;
        // _initialSheetChildSize = 0.35;
        final Map<String, dynamic> data = {
          "order_id": riderDeliveryBloc.deliveryDetails?.orderId,
          "at_pickup_location": true,
          "at_delivery_location": false,
        };
        final NearByLocation atLocation = NearByLocation.fromJson(data);
        await _db.insertRiderAtLocation(atLocation);

        await riderDeliveryBloc
            .refreshJobDetail(riderDeliveryBloc.deliveryDetails?.id);
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> riderAtDeliveryLocation() async {
    await RiderDeliveryAuthService()
        .atDeliveryLocation(riderDeliveryBloc.deliveryDetails?.orderId)
        .then((value) async {
      if (value == true) {
        showToast(message: 'You have arrived at the destination location');
        // riderDeliveryBloc.deliveryDetails?.isDeliveryAccepted = false;
        // riderDeliveryBloc.deliveryDetails?.isDeliveryStarted = true;
        // _initialSheetChildSize = 0.35;
        // Map<String, dynamic> data = {
        //   "orderId": riderDeliveryBloc.deliveryDetails?.orderId,
        //   "at_pickup_location": false,
        //   "at_delivery_location": true,
        // };
        // NearByLocation atLocation = NearByLocation.fromJson(data);
        await _db.updateRiderAtLocation(
            riderDeliveryBloc.deliveryDetails?.orderId, true);

        await riderDeliveryBloc
            .refreshJobDetail(riderDeliveryBloc.deliveryDetails?.id);
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> startOffer() async {
    await RiderDeliveryAuthService()
        .startJourney(riderDeliveryBloc.deliveryDetails?.id)
        .then((value) async {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.journyStartedSuccessfully);
        // riderDeliveryBloc.deliveryDetails?.isDeliveryAccepted = false;
        // riderDeliveryBloc.deliveryDetails?.isDeliveryStarted = true;
        // _initialSheetChildSize = 0.35;
        await riderDeliveryBloc
            .refreshJobDetail(riderDeliveryBloc.deliveryDetails?.id);
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Widget _buildEndDelivery() {
    return CurvedButton(
      text: 'End Delivery',
      backgroundColor: navyBlue,
      textColor: white,
      onPressed: isEndedAPILoading
          ? null
          : () async {
              FocusScope.of(context).unfocus();
              endDeliveryDialog();
            },
      isLoading: isEndedAPILoading,
    );
  }

  Future<void> endDeliveryDialog() async {
    await showDialogBox(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: navyBlue,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: false,
      title: 'End Delivery',
      description:
          'You are free to browse in different currencies but will always pay in NGN (Naira) at checkout',
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: "End Delivery",
      rightButtonOnPressed: () {
        confirmDeliveryCodeDialog();
      },
    );
  }

  Future<void> confirmDeliveryCodeDialog() async {
    await showDialogBoxValidateCode(
      context: context,
      actionOneBgColor: navyBlue,
      actionOneTextColor: Colors.white,
      firstActionPrimary: false,
      isCloseIconShow: true,
      title: 'Confirm Delivery',
      description: 'Input the code given to the receiver.',
      actionOneText: AppLocalization.of(context)!.submit,
      buttonOnPressed: () async {
        isEndedAPILoading = true;
        if (mounted) setState(() {});
        await endOffer();

        isEndedAPILoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> endOffer() async {
    await RiderDeliveryAuthService()
        .endJourney(riderDeliveryBloc.deliveryDetails?.id)
        .then((value) async {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.endJob);
        // riderDeliveryBloc.deliveryDetails?.isDeliveryStarted = false;
        // riderDeliveryBloc.deliveryDetails?.isDeliveryEnded = true;
        // _initialSheetChildSize = 0.3;
        await riderDeliveryBloc
            .refreshJobDetail(riderDeliveryBloc.deliveryDetails?.id);
        if (mounted) setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Widget _buildTitle() {
    return Text(
      "Please select the reason for cancellation:",
      style: TextStyle(
        color: blackFont,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildCancelDeliveryReason() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: reasons.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(
              reasons[i],
              style: TextStyle(
                color: userChecked == reasons[i] ? blackFont : darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            leading: Radio<String?>(
              value: reasons[i],
              activeColor: navyBlue,
              hoverColor: navyBlue,
              focusColor: navyBlue,
              visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity),
              onChanged: (val) {
                _onSelected(val);
              },
              groupValue: userChecked,
            ),
          );
        });
  }

  void _onSelected(String? dataName) {
    userChecked = dataName;
    setState(() {});
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CurvedButton(
        text: "Submit",
        textColor: white,
        onPressed: _validateInputs,
        isLoading: isCancelAPILoading,
        backgroundColor: navyBlue,
      ),
    );
  }

  void _validateInputs() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      if (userChecked == null || userChecked == "") {
        showSnackbar(context,
            message: 'Please select your reason', duration: 1000);
      } else {
        form.save();
        if (isCancelAPILoading == false) {
          FocusScope.of(context).unfocus();
          isCancelAPILoading = true;
          if (mounted) setState(() {});
          await cancelOffer(userChecked ?? "");
          isCancelAPILoading = false;
          if (mounted) setState(() {});
        }
      }
    }
  }

  Future<void> cancelOffer(String userChecked) async {
    await RiderDeliveryAuthService()
        .cancelJourney(riderDeliveryBloc.deliveryDetails?.id, userChecked)
        .then((value) {
      if (value == true) {
        Future.delayed(const Duration(seconds: 2)).then((value) => () {
              showToast(
                  message: AppLocalization.of(context)!
                      .cancelledApplicactionForJobSuccessfully);
              isDeliveryCancel = false;
              Navigator.pop(context, 'HomeScreen');
            });
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Widget _buildDeliveryProofTitle() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "Kindly take a picture of the receiver and the package for proof of delivery.",
        style: TextStyle(
          color: blackFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQRCode() {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => QRViewExample(),
        //     ));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/rider/scan_qr.svg',
            width: 22,
            height: 22,
            fit: BoxFit.fill,
          ),
          const SizedBox(width: 15.0),
          Text(
            "Scan QRCode",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakePicture() {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).popAndPushNamed(Routes.TAKE_DELIVERY_PROOF);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/cam_pic.svg',
            fit: BoxFit.fill,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 15.0),
          Text(
            "Tap to take a picture",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }
}
