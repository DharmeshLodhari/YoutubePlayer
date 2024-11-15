import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:badges/badges.dart' as badges;
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  double _initialSheetChildSize = 0.0;

  bool isPackageReview = false;
  bool isSearchDestination = false;
  bool isSelectDestination = false;
  bool isLocationViaMap = false;
  bool isConfirmPickupLocation = false;

  @override
  void initState() {
    isPackageReview = true;
    _initialSheetChildSize = 0.45;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar() as PreferredSizeWidget?,
        body: _buildBody(),
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
        'Dispatch',
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
      actions: <Widget>[
        historyIcon(),
        const SizedBox(width: 10.0),
      ],
    );
  }

  Widget historyIcon() {
    return SizedBox(
      height: 38,
      width: 38,
      child: IconButton(
        icon: const Icon(
          Icons.history,
          color: Colors.black,
          size: 24,
        ),
        onPressed: () async {},
      ),
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
          padding: const EdgeInsets.all(50.0),
          child: Image.asset(
            "assets/images/taxi/route_map_image.png",
            fit: BoxFit.fill,
          ),
        ),
        if (isPackageReview) _buildPackageReview(),
        if (isSearchDestination) _buildSearchDestination(),
        if (isSelectDestination) _buildSelectDestination(),
        // _buildNoVeshicles(),
        if (isLocationViaMap) _buildSelectOption(),
        if (isConfirmPickupLocation) _buildDestinationLocation(),
        // _buildRiderOption(),
        // _buildYouFare(),
        // _buildPaymentFailed(),
        // _buildPaymentRetryProcess(),
        // _buildArriving(),
        // _buildPartnerArrivingDetails(),
        // _buildArrivedRider(),
        // _buildOnTripRider(),
        // _buildOnTripMiles(),
      ],
    );
  }

  Widget _buildPackageReview() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getPackageReviewDetails(),
        ),
      ),
    );
  }

  Widget getPackageReviewDetails() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPackageLogo(),
                    _buildRightArrow(),
                  ],
                ),
                _buildPackageReviewText(),
                const SizedBox(height: 15),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightArrow() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPackageReview = false;
          isSearchDestination = true;
        });
      },
      child: const Icon(
        Icons.keyboard_arrow_right_outlined,
        size: 20,
      ),
    );
  }

  Widget _buildPackageLogo() {
    return Image.asset(
      "assets/images/package.png",
      fit: BoxFit.fill,
      height: 80,
      width: 100,
      filterQuality: FilterQuality.high,
      cacheHeight: 80,
      cacheWidth: 100,
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

  Widget _buildPackageReviewText() {
    return Text(
      "Package Review",
      style: TextStyle(
        color: blackFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "For a successful delivery, make sure your package is :",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Text(
                '\u2022',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "20kg or less",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Text(
                '\u2022',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Securely sealed and ready for pickup.",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Note : We don't deliver goods prohibited by law.",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildSearchDestination() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      maxChildSize: 0.25,
      minChildSize: 0.25,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getSearchDestination(),
        ),
      ),
    );
  }

  Widget getSearchDestination() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectDestinationText(),
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectDestinationText() {
    return Text(
      "Select Destination",
      style: TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomizedTextFormField(
      hintText: 'Search...',
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            isSearchDestination = false;
            isSelectDestination = true;
          });
        },
        child: const Icon(
          Icons.search,
        ),
      ),
      onChanged: (value) {},
    );
  }

  Widget _buildSelectDestination() {
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      maxChildSize: 0.60,
      minChildSize: 0.60,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getSelectDestination(),
        ),
      ),
    );
  }

  Widget getSelectDestination() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressSelection(),
                const SizedBox(height: 15),
                _buildShowOnMapTextAndIcon(),
                const SizedBox(height: 15),
                _buildRecent(),
                _buildLocationData(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.blue), // replace with navyBlue if defined
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SvgPicture.asset(
              'assets/images/rider/ic_route.svg',
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          // Address List Section (Static items)
          Expanded(
            child: Column(
              children: [
                // First address item
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '24 Bashir Musa Road, Agege',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
                          "isForSelection": true,
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300], thickness: 1),

                // Second address item
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '20, Pedro Street, Alausa, Ikeja',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
                          "isForSelection": true,
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowOnMapTextAndIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelectDestination = false;
          isLocationViaMap = true;
        });
      },
      child: Row(
        children: [
          Image.asset(
            "assets/images/location_pin.png",
            width: 30,
            height: 30,
          ),
          Text(
            "Show on a map",
            style: TextStyle(
              color: navyBlue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecent() {
    return Text(
      "Recent",
      style: TextStyle(
        color: darkGrey,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildLocationData() {
    return GestureDetector(
      onTap: () {},
      child: ListTile(
        horizontalTitleGap: 0,
        leading: Image.asset(
          "assets/images/location_icon.png",
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Agege Post Office, Agege,",
              style: TextStyle(
                color: black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "Lagos",
              style: TextStyle(
                color: darkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVehicles() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getVehiclesDetails(),
        ),
      ),
    );
  }

  Widget getVehiclesDetails() {
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
          Expanded(
            child: Column(
              children: [
                _buildWarningLogo(),
                const SizedBox(height: 25),
                _buildNoVehiclesText(),
                const SizedBox(height: 40),
                _buildChooseAnotherLocation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningLogo() {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 60,
            height: 60,
            color: red.withOpacity(0.1),
            child: Image.asset(
              "assets/images/warning_icon.png",
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoVehiclesText() {
    return Text(
      "Sorry, there are no vehicles in this area.",
      style: TextStyle(
        color: black,
        fontSize: 13,
        fontFamily: "Inter",
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildChooseAnotherLocation() {
    return CurvedButton(
      onPressed: () {},
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Choose another location",
    );
  }

  Widget _buildSelectOption() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getSelectOption(),
        ),
      ),
    );
  }

  Widget getSelectOption() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectOptionText(),
                const SizedBox(height: 20),
                _buildSelectOptionList(),
                const SizedBox(height: 20),
                _buildSelectPackageButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectOptionText() {
    return Text(
      "Select Option",
      style: TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildSelectOptionList() {
    return ListView.builder(
      itemCount: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Image.asset("assets/images/bike_icon.png"),
                    const SizedBox(height: 5),
                    Text(
                      "Bike",
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "₦ 1000",
                      style: TextStyle(
                        fontSize: 20,
                        color: black,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "22 mins",
                      style: TextStyle(
                        fontSize: 12,
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectPackageButton() {
    return CurvedButton(
      onPressed: () {
        setState(() {
          isLocationViaMap = false;
          isConfirmPickupLocation = true;
        });
      },
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Select Package",
    );
  }

  Widget _buildDestinationLocation() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getDestinationLocation(),
        ),
      ),
    );
  }

  Widget getDestinationLocation() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDestinationLocationText(),
                const SizedBox(height: 20),
                _buildDestinationLocationData(),
                const SizedBox(height: 30),
                _buildConfirmDestinationButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationLocationText() {
    return Text(
      "Confirm Pickup Spot",
      style: TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildDestinationLocationData() {
    return ListTile(
      horizontalTitleGap: 0,
      leading: Image.asset(
        "assets/images/location_icon.png",
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "20, Pedro Street, Alausa, Ikeja",
            style: TextStyle(
              color: black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lagos",
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
                    "isForSelection": true,
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmDestinationButton() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.DELIVERY_DETAILS);
      },
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Proceed",
    );
  }

  Widget _buildRiderOption() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getRiderOptionDetails(),
        ),
      ),
    );
  }

  Widget getRiderOptionDetails() {
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFiled(),
                  const SizedBox(height: 15),
                  _buildMobileTextFiled(),
                  _buildItemDescription(),
                  const SizedBox(height: 15),
                  _buildSelectOptionList(),
                  const SizedBox(height: 15),
                  _buildProceedToPayment(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFiled() {
    return Row(
      children: [
        Image.asset(
          "assets/images/thermometer_icon.png",
          height: 24,
          width: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Weight",
              hintStyle: TextStyle(
                fontSize: 13,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Height",
              hintStyle: TextStyle(
                fontSize: 13,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Width",
              hintStyle: TextStyle(
                fontSize: 13,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTextFiled() {
    return Row(
      children: [
        Image.asset("assets/images/phone_icon.png"),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Recipient Number",
              hintStyle: TextStyle(
                fontSize: 13,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemDescription() {
    return Row(
      children: [
        Image.asset("assets/images/item_icon.png"),
        const SizedBox(width: 10),
        Expanded(
          child: CustomizedTextFormField(
            hintText: 'Item Description / Delivery Note',
            maxLines: 3,
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _buildProceedToPayment() {
    return CurvedButton(
      onPressed: () {},
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Proceed to Payment",
    );
  }

  Widget _buildYouFare() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getYouFareDetails(),
        ),
      ),
    );
  }

  Widget getYouFareDetails() {
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildYouFareText(),
                const SizedBox(height: 45),
                _buildPay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouFareText() {
    return Column(
      children: [
        Text(
          "Your fare is",
          style: TextStyle(
            color: black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 17),
        Text(
          "₦ 1000",
          style: TextStyle(
            fontSize: 20,
            color: black,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildPay() {
    return CurvedButton(
      onPressed: () {},
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Pay",
    );
  }

  Widget _buildPaymentFailed() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getPaymentFailedDetails(),
        ),
      ),
    );
  }

  Widget getPaymentFailedDetails() {
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaymentFailedText(),
                const SizedBox(height: 17),
                _buildPaymentRetry(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFailedText() {
    return Column(
      children: [
        Text(
          "Sorry, you have an unpaid order. Order amount:",
          style: TextStyle(
            color: black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 17),
        Text(
          "₦ 1000",
          style: TextStyle(
            fontSize: 20,
            color: black,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRetry() {
    return CurvedButton(
      onPressed: () {},
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Retry payment",
    );
  }

  Widget _buildPaymentRetryProcess() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getPaymentRetryProcessDetails(),
        ),
      ),
    );
  }

  Widget getPaymentRetryProcessDetails() {
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          "Retrying payment.",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "It may take a few seconds...",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        )
      ],
    );
  }

  Widget _buildArriving() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrivingPartner(),
                const SizedBox(height: 30),
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
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            "assets/images/avatar.png",
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ahmad Aminoff",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Volkswagen Jetta",
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

  Widget _buildPartnerArrivingDetails() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getArrivingDetailsData(),
        ),
      ),
    );
  }

  Widget getArrivingDetailsData() {
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildArrivingPartner(),
                  const SizedBox(height: 15),
                  Text(
                    "₦ 1000",
                    style: TextStyle(
                      fontSize: 20,
                      color: black,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                    ),
                  ),
                  _buildAddressDetails(),
                  const SizedBox(height: 26),
                  _buildPartnerContactIcon(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Card(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              "assets/images/ic_route_icon.png",
              width: 16,
              height: 65,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "24 Bashir Musa Road, Agege",
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "20, Pedro Street, Alausa, Ikeja",
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrivedRider() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getArrivedRiderDetails(),
        ),
      ),
    );
  }

  Widget getArrivedRiderDetails() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrivingPartner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnTripRider() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getOnTripDetails(),
        ),
      ),
    );
  }

  Widget getOnTripDetails() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrivingPartner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnTripMiles() {
    return DraggableScrollableSheet(
      initialChildSize: 0.20,
      maxChildSize: 0.20,
      minChildSize: 0.20,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getRiderMiles(),
        ),
      ),
    );
  }

  Widget getRiderMiles() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMilesText(),
                const SizedBox(height: 12),
                _buildAddressText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilesText() {
    return Row(
      children: [
        Text(
          "18 mins / 2.2km",
          style: TextStyle(
            color: black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildAddressText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "20, Pedro Street, Alausa,...",
          style: TextStyle(
            color: black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            _buildSplitTrip(),
            _buildExitButton(),
          ],
        )
      ],
    );
  }

  Widget _buildSplitTrip() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.YOU_TRIP_END);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 36,
            height: 36,
            color: greyTagColor,
            child: Image.asset(
              "assets/images/split_icon.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: CurvedButton(
        onPressed: () {},
        width: 64,
        borderRadius: 10,
        height: 36,
        textColor: white,
        backgroundColor: mateRed,
        text: "Exit",
      ),
    );
  }
}
