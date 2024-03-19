import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  String? TodayDate;
  String? Amount = "3000";
  int? km = 2;
  int? items = 5;
  int? kg = 38;

  void myDate() {
    var now = DateTime.now();
    var formatter = DateFormat('d MMMM,y');
    String formattedDate = formatter.format(now);
    TodayDate = formattedDate;
  }

  @override
  void initState() {
    myDate();
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
        'Delivery History',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: greyBorderColor,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateAndWaitingButton(),
                    _buildLogoAndDeliveryAndAmount(),
                    _buildItemsAndKg(),
                    SizedBox(height: 10.0),
                    _buildIconAndAddressAndPickup(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
          ],
        );
      },
    );
  }

  Widget _buildDateAndWaitingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildDate()),
        _buildWaitingButton(),
      ],
    );
  }

  Widget _buildDate() {
    return Text(
      TodayDate.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: darkGrey,
        fontSize: 12,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildWaitingButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: naturalGreenLight,
      ),
      child: Text(
        'Completed',
        style: TextStyle(
          color: naturalGreen,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
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
        _buildAmount()
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/rider/kfc.png',
      height: 24,
      width: 24,
      fit: BoxFit.fill,
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
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
      'Delivery',
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildAmount() {
    return Text(
      "₦${Amount}",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildItemsAndKg() {
    return Text(
      "${items} Items (${kg}Kg)",
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
        SizedBox(width: 7.0),
        Expanded(child: _buildMainAddressColumn())
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 45,
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KFC, O&O Filling station berger expressway',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Festus street ,Agege',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }
}
