import 'dart:io';

import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShippingOption extends StatefulWidget {
  ShippingOption({Key? key, this.arguments}) : super(key: key);

  var arguments;

  @override
  State<ShippingOption> createState() => _ShippingOptionState();
}

class _ShippingOptionState extends State<ShippingOption> {
  bool isLoading = false;
  List<ShippingOptionModel> shippingList = [];
  String? shippingType;
  String? merchantName;
  // bool isChecked = false;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      shippingType = widget.arguments?["shippingType"];
      merchantName = widget.arguments?["merchantName"];
    }
    if (shippingType == 'slydo') {
      getShippingWithSlydo();
    }
    if (shippingType == 'merchant') {
      getShippingWithMerchant();
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
        'Shipping Option',
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
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  itemCount: shippingList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildShippingItem(index);
                  },
                ),
              ),
            ),
            CurvedButton(
              onPressed: () {},
              backgroundColor: navyBlue,
              textColor: white,
              text: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingItem(int index) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 5),
      shadowColor: boxShadowTwo,
      color: white,
      // child: Container(
      //   decoration: decorateBox(),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
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
                    shippingList[index].name ?? "",
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
                    activeColor: navyBlue,
                    // value: isChecked,
                    shape: const CircleBorder(),
                    // onChanged: (bool? value) {
                    //   setState(() {
                    //     isChecked = value!;
                    //   });
                    // },
                    value: selectedIndex == index,
                    onChanged: (value) {
                      setState(() {
                        selectedIndex = value! ? index : -1;
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
                    "${shippingList[index].currency}${shippingList[index].price}",
                    style: TextStyle(
                      color: blackFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                    ),
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
        ),
      ),
      // ),
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

  Future<void> getShippingWithSlydo() async {
    shippingList.clear();
    isLoading = true;
    if (mounted) setState(() {});

    await ShippingProcessAuthService().getShipWithSlydo().then(
      (value) {
        value.forEach((element) {
          shippingList.add(element);
        });
        isLoading = false;
        if (mounted) setState(() {});
      },
    ).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
      showToast(message: error.toString());
    });
  }

  Future<void> getShippingWithMerchant() async {
    shippingList.clear();
    isLoading = true;
    if (mounted) setState(() {});

    await ShippingProcessAuthService().getShipWithMerchant(merchantName).then(
      (value) {
        value.forEach((element) {
          shippingList.add(element);
        });
        isLoading = false;
        if (mounted) setState(() {});
      },
    ).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
      showToast(message: error.toString());
    });
  }
}
