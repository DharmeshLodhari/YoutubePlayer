import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryOption extends StatefulWidget {
  DeliveryOption({Key? key, this.arguments}) : super(key: key);

  var arguments;

  @override
  State<DeliveryOption> createState() => _DeliveryOptionState();
}

class _DeliveryOptionState extends State<DeliveryOption> {
  List<String?> deliveryOption = ["Shipping", "Eat in", "Pickup"];
  String? selectedValue = "Shipping";
  bool isShipping = true;
  bool isChecked = false;
  bool switchValue = false;
  ShippingAddress? shippingAddress;
  String? merchantName;

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      merchantName = widget.arguments?["merchantName"];
    }
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
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Delivery Option',
        style: TextStyle(
          fontSize: 20,
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
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dropDownPickItemWidget(
                      label: 'Delivery Option',
                      selectedItem: selectedValue,
                      onTap: () => pickDeliveryOptions(),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    isShipping
                        ? _buildDeliveryAddressAndOptions()
                        : _buildNote(),
                    Visibility(
                      visible: false,
                      child: _buildShippingOptionSelected(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressAndOptions() {
    return Column(
      children: [
        _buildDeliveryAddress(),
        const SizedBox(
          height: 16,
        ),
        _buildShippingOption(),
      ],
    );
  }

  Widget ShippingOptionalWid(
      {required String title, required String subTitle}) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              subTitle,
              style: TextStyle(
                color: darkGrey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right_outlined,
            color: black,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Text(
          'Note',
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(height: 5),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: greyBorderColor, // Border color
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: greyBorderColor, // Border color
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: greyBorderColor, // Change the focus color here
                width: 1.0,
              ),
            ),
            filled: true,
            fillColor: white, // Background color
          ),
        ),
      ],
    );
  }

  pickDeliveryOptions() async {
    String? pickedDeliveryOption = await showPickItemDialog<String>(
      context: context,
      items: deliveryOption,
      selectedItem: selectedValue,
    );
    if (pickedDeliveryOption != null) {
      selectedValue = pickedDeliveryOption;
      if (selectedValue == "Shipping") {
        isShipping = true;
      } else {
        isShipping = false;
      }
      if (mounted) setState(() {});
    }
  }

  Widget _buildDeliveryAddress() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.DISPATCH_ADDRESS,
          arguments: {
            "isForSelection": true,
            "shippingAddress": shippingAddress,
            "onShippingAddressChange": (address) {
              shippingAddress = address;
              setState(() {});
            }
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: TextStyle(
              color: darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
          ),
          // if (shippingAddress != null)
          //   Text(
          //       "${shippingAddress?.addressLineOne} ${shippingAddress?.addressLineTwo} ${shippingAddress?.country}" ??
          //           ""),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              shippingAddress != null
                  ? "${shippingAddress?.line_1}, ${shippingAddress?.line_2}, ${shippingAddress?.city}, ${shippingAddress?.stateName},  ${shippingAddress?.country}, ${shippingAddress?.zip}"
                  : "No 5, Adetutu street,ikeja, lagos, Nigeria, 100001",
              style: TextStyle(
                color: black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_right_outlined,
              color: black,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Shipping Option",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION, arguments: {
              'shippingType': 'slydo',
              'merchantName': merchantName
            });
          },
          child: ShippingOptionalWid(
            title: "Ship with Slydo",
            subTitle: "Use slydo dispatch rider to get your orders.",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION, arguments: {
              'shippingType': 'merchant',
              'merchantName': merchantName
            });
          },
          child: ShippingOptionalWid(
            title: "Merchant Option",
            subTitle: "Use merchant rider to get your orders delivered",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION, arguments: {
              'shippingType': 'courier',
              'merchantName': merchantName
            });
          },
          child: ShippingOptionalWid(
            title: "Ship with Courier",
            subTitle: "Use courier service to get your order delivered to you.",
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {},
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Done',
      ),
    );
  }

  Widget _buildShippingOptionSelected() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select Shipping Option",
              style: TextStyle(
                color: darkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Reset Option",
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        _buildShipping(),
        const SizedBox(
          height: 16,
        ),
        _buildInsurePackage(),
        const SizedBox(
          height: 16,
        ),
        _buildShippingNotes(),
      ],
    );
  }

  Widget _buildInsurePackage() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "Insure Package",
        style: TextStyle(
          color: navyBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
      onTap: () {
        setState(() {
          switchValue = !switchValue;
        });
      },
      trailing: CupertinoSwitch(
          value: switchValue,
          onChanged: (value) {
            setState(() {
              switchValue = value;
            });
          },
          activeColor: const Color(0xff3F61DB) // Color when switch is ON
          ),
    );
  }

  Widget _buildShipping() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          minVerticalPadding: 0,
          minLeadingWidth: 10,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity(horizontal: 0, vertical: 0),
          leading: SvgPicture.asset(
            "assets/images/slydo.svg",
            width: 40,
            height: 40,
            color: navyBlue,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SLYDO",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              Checkbox(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                checkColor: Colors.white,
                value: isChecked,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Estimated delivery time 2-5 days",
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Text(
                "₦3,000.00",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "No 4, ilewole street, Ogba -➜ No 5, Adetutu street,ikeja, lagos",
                style: TextStyle(
                  color: black,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
            ),
            _buildTrackingTag(),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: greyBorderColor,
      ),
      child: Text(
        'Live Feed',
        style: TextStyle(
          color: darkGrey,
          fontSize: 8,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildShippingNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Note",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: greyBorderColor, // Border color
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: greyBorderColor, // Change the focus color here
                width: 1.0,
              ),
            ),
            filled: true,
            fillColor: white, // Background color
          ),
        ),
      ],
    );
  }
}
