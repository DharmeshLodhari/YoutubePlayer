import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class DeliveryDetails extends StatefulWidget {
  var arguments;

  DeliveryDetails({Key? key, this.arguments}) : super(key: key);

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DeliveryModel? deliveryDetails;
  bool isRejectAPILoading = false;
  bool isAcceptAPILoading = false;
  bool isStartAPILoading = false;
  bool isEndedAPILoading = false;
  bool isCancelAPILoading = false;
  double _initialSheetChildSize = 0.0;
  bool isShowDetails = false;
  bool isDeliveryAccepted = false;
  bool isDeliveryStarted = false;
  bool isDeliveryEnded = false;
  bool isDeliveryCancel = false;
  bool isChecked = false;

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

  @override
  void initState() {
    deliveryDetails = widget.arguments['deliveryDetail'];
    isShowDetails = widget.arguments['showDetails'];
    if (isShowDetails) {
      isDeliveryAccepted = false;
      _initialSheetChildSize = 0.38;
    } else {
      isDeliveryAccepted = true;
      _initialSheetChildSize = 0.45;
    }
    super.initState();
  }

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
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      title: Text(
        'Ride #267',
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
    return Stack(
      children: [
        // MapUI(),
        Image.asset(
          "assets/images/map.png",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: EdgeInsets.all(50.0),
          child: Image.asset(
            "assets/images/taxi/route_map_image.png",
            fit: BoxFit.fill,
          ),
        ),
        isShowDetails ? _buildShowDetails() : Container(),
        isDeliveryAccepted ? _buildAccepted() : Container(),
        isDeliveryStarted ? _buildStarted() : Container(),
        isDeliveryEnded ? _buildEnded() : Container(),
        isDeliveryCancel ? _buildCancel() : Container(),
      ],
    );
  }

  Widget _buildShowDetails() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getDeliveryDetails(),
        ),
      ),
    );
  }

  Widget _buildAccepted() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: startDelivery(),
        ),
      ),
    );
  }

  Widget _buildStarted() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: endDelivery(),
        ),
      ),
    );
  }

  Widget _buildEnded() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: deliveryProof(),
        ),
      ),
    );
  }

  Widget _buildCancel() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: cancelDelivery(),
        ),
      ),
    );
  }

  Widget getDeliveryDetails() {
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
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoAndDeliveryAndAmount(),
                  _buildItemsAndKg(),
                  SizedBox(height: 10.0),
                  _buildIconAndAddressAndPickup(),
                  SizedBox(height: 10.0),
                  _buildButtonCancelAndPickup(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget startDelivery() {
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
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrivingToPickupLocation(),
                  SizedBox(height: 15.0),
                  _buildDistanceAndHoursAndImageAndAddress(),
                  SizedBox(height: 10.0),
                  _buildCheckBoxAndItems(),
                  _buildStartDelivery(),
                  SizedBox(height: 15.0),
                  _buildCancelDelivery(),
                  SizedBox(height: 15.0),
                  _buildCallButton(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget endDelivery() {
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
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrivingToDestination(),
                  SizedBox(height: 10.0),
                  _buildDistanceAndHoursAndImageAndAddress(),
                  SizedBox(height: 10.0),
                  _buildItems(),
                  SizedBox(height: 15.0),
                  _buildEndDelivery(),
                  SizedBox(height: 15.0),
                  _buildCallButton(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget deliveryProof() {
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
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildDeliveryProofTitle(),
                SizedBox(height: 20.0),
                _buildQRCode(),
                SizedBox(height: 20.0),
                _buildTakePicture(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelDelivery() {
    return Form(
      key: _formKey,
      child: Container(
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
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    SizedBox(height: 10.0),
                    _buildCancelDeliveryReason(),
                    SizedBox(height: 10.0),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildLogoAndDeliveryAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLogo(),
            _buildVerticalDivider(),
            _buildDelivery(),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrencySymbols(),
            _buildAmount(),
          ],
        )
      ],
    );
  }

  Widget _buildLogo() {
    return Image.network(
      deliveryDetails?.merchantAvatar ?? "",
      height: 24,
      width: 24,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      cacheHeight: 24,
      cacheWidth: 24,
      frameBuilder: imageFrameBuilder,
      errorBuilder: (context, error, stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            defaultImage,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 55,
      child: VerticalDivider(
        color: greySecondaryYarn,
        thickness: 1,
        indent: 10,
        endIndent: 10,
        width: 20,
      ),
    );
  }

  Widget _buildDelivery() {
    return Text(
      deliveryDetails?.merchantFullName ?? "",
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildCurrencySymbols() {
    return Text(
      "₦ ",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildAmount() {
    return Text(
      deliveryDetails?.currency ?? "",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildItemsAndKg() {
    return Text(
      "${deliveryDetails?.totalNoOfItems} Items (${deliveryDetails?.totalWeight}Kg)",
      style: TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildIconAndAddressAndPickup() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconImage(),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        _buildMainAddressColumn()
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 65,
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deliveryDetails?.pickupAddress?.addressLineOne}, ${deliveryDetails?.pickupAddress?.addressLineTwo}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontSize: 12,
                fontFamily: "Inter",
              ),
            ),
            Text(
              deliveryDetails?.expectedPickupTime.toString() ?? "",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        SizedBox(height: 19),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deliveryDetails?.deliveryAddress?.addressLineOne}, ${deliveryDetails?.deliveryAddress?.addressLineTwo}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontSize: 12,
                fontFamily: "Inter",
              ),
            ),
            Text(
              deliveryDetails?.expectedDeliveryTime.toString() ?? "",
              style: TextStyle(
                color: navyBlue,
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

  Widget _buildButtonCancelAndPickup() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                  : () {
                      FocusScope.of(context).unfocus();
                      isRejectAPILoading = true;
                      if (mounted) setState(() {});
                      rejectOffer();

                      isRejectAPILoading = false;
                      if (mounted) setState(() {});
                    },
              isLoading: isRejectAPILoading,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: CurvedButton(
              text: 'Accept(4:49)',
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
        .rejectOffer(deliveryDetails?.id)
        .then((value) {
      showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
      Navigator.pop(context, 'HomeScreen');
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> acceptOffer() async {
    await RiderDeliveryAuthService()
        .acceptOffer(deliveryDetails?.id)
        .then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobAcceptedFromListing);
        isShowDetails = false;
        isDeliveryAccepted = true;
        _initialSheetChildSize = 0.45;
        setState(() {});
      } else {
        showToast(message: 'Offer already accepted by a dispatcher');
        Navigator.pop(context, 'HomeScreen');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Widget _buildDrivingToPickupLocation() {
    return Center(
      child: Text(
        'Driving to pickup location',
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
        'Driving to destination',
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildDistanceAndHoursAndImageAndAddress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDistanceAndHours(),
        SizedBox(width: 15.0),
        _buildRouteIconImage(),
        _buildAddressColumn()
      ],
    );
  }

  Widget _buildDistanceAndHours() {
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
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Text(
              "20",
              style: TextStyle(
                color: blackFont,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
              ),
            ),
            SizedBox(width: 5),
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

  Widget _buildAddressColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${deliveryDetails?.deliveryAddress?.addressLineOne}, ${deliveryDetails?.deliveryAddress?.addressLineTwo}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDeliveryStarted ? darkGrey : blackFont,
              fontSize: 12,
              fontFamily: "Inter",
            ),
          ),
          SizedBox(height: 25),
          Text(
            'Festus street ,Agege',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDeliveryStarted ? blackFont : darkGrey,
              fontSize: 12,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckBoxAndItems() {
    return Row(
      children: [
        Checkbox(
            shape: RoundedRectangleBorder(
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
              });
            }),
        Text(
          "I have picked up - ${deliveryDetails?.totalNoOfItems} Items (${deliveryDetails?.totalWeight}kg)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isChecked ? blackFont : darkGrey,
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
          "${deliveryDetails?.totalNoOfItems} Items (${deliveryDetails?.totalWeight}kg)",
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

  Widget _buildStartDelivery() {
    return CurvedButton(
      text: 'Start Delivery',
      backgroundColor: isChecked ? navyBlue : greyBorderColor,
      textColor: white,
      onPressed: isChecked
          ? () {
              if (isStartAPILoading == false) {
                FocusScope.of(context).unfocus();
                isStartAPILoading = true;
                if (mounted) setState(() {});
                startOffer();
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
      textColor: isChecked ? navyBlue : greyBorderColor,
      onPressed: isChecked
          ? () {
              isDeliveryAccepted = false;
              isDeliveryCancel = true;
              _initialSheetChildSize = 0.73;
              setState(() {});
            }
          : null,
      backgroundColor: white,
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_in_talk_outlined,
            size: 25,
          ),
          SizedBox(width: 10.0),
          Text(
            "Tap to call package sender",
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

  Future<void> startOffer() async {
    await RiderDeliveryAuthService()
        .startJourney(deliveryDetails?.id)
        .then((value) {
      showToast(
          message: AppLocalization.of(context)!.journyStartedSuccessfully);
      isDeliveryAccepted = false;
      isDeliveryStarted = true;
      _initialSheetChildSize = 0.35;
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
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
              isEndedAPILoading = true;
              if (mounted) setState(() {});
              endOffer();

              isEndedAPILoading = false;
              if (mounted) setState(() {});
            },
      isLoading: isEndedAPILoading,
    );
  }

  Future<void> endOffer() async {
    await RiderDeliveryAuthService()
        .endJourney(deliveryDetails?.id)
        .then((value) {
      showToast(message: AppLocalization.of(context)!.endJob);
      isDeliveryStarted = false;
      isDeliveryEnded = true;
      _initialSheetChildSize = 0.3;
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
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

  void _validateInputs() {
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
          // cancelOffer();
          isDeliveryCancel = false;
          Navigator.pop(context, 'HomeScreen');
          isCancelAPILoading = false;
          if (mounted) setState(() {});
        }
        ;
      }
    }
  }

  Future<void> cancelOffer() async {
    await RiderDeliveryAuthService()
        .cancelJourney(deliveryDetails?.id)
        .then((value) {
      showToast(
          message: AppLocalization.of(context)!
              .cancelledApplicactionForJobSuccessfully);
      isDeliveryCancel = false;
      Navigator.pop(context, 'HomeScreen');
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Widget _buildDeliveryProofTitle() {
    return Padding(
      padding: EdgeInsets.all(15.0),
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
          SizedBox(width: 15.0),
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
        Navigator.of(context).pushNamed(Routes.TAKE_PROOF_PHOTO);
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
          SizedBox(width: 15.0),
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
