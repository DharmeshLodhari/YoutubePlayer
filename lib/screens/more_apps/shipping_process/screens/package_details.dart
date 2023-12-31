import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PackageDetails extends StatefulWidget {
  const PackageDetails({Key? key}) : super(key: key);

  @override
  State<PackageDetails> createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
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
          floatingActionButton: floatingActionBar(),
          body: _buildBody(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
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
        'Prineygladhair',
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
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDeliveryBy(),
                  SizedBox(
                    height: 10,
                  ),
                  _buildNote(),
                  SizedBox(
                    height: 10,
                  ),
                  _buildItems(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBy() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery By",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            SizedBox(
              height: 8,
            ),
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

  Widget _buildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Note",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Icon(Icons.edit),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'I will like it to be well packed and beautiful., I will like it to be well packed and beautiful., I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Items",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'I will like it to be well packed and beautiful., I will like it to be well packed and beautiful., I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Total: ',
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                Text(
                  '₦',
                  style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '187,200.00',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            MaterialButton(
              height: 40,
              color: navyBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const SizedBox(
                width: 66,
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
