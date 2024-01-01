import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShippingOption extends StatefulWidget {
  const ShippingOption({Key? key}) : super(key: key);

  @override
  State<ShippingOption> createState() => _ShippingOptionState();
}

class _ShippingOptionState extends State<ShippingOption> {
  bool isChecked = false;

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
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: selectedListItemBackgroundBlue),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.zero,
                  shadowColor: boxShadowTwo,
                  color: white,
                  child: Container(
                    decoration: decorateBox(),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListTile(
                            minVerticalPadding: 0,
                            minLeadingWidth: 10,
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: 0),
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
                                  visualDensity: VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  checkColor: Colors.white,
                                  activeColor: navyBlue,
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
                      ),
                    ),
                  ),
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

  Widget _buildTrackingTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: greyBorderColor,
      ),
      child: Text(
        'Live Feed',
        style: TextStyle(
          color: darkGrey,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }
}
