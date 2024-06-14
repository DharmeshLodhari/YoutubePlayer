import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderUpdated extends StatefulWidget {
  final dynamic arguments;

  const OrderUpdated({super.key, this.arguments});

  @override
  State<OrderUpdated> createState() => _OrderUpdatedState();
}

class _OrderUpdatedState extends State<OrderUpdated> {
  @override
  Widget build(BuildContext context) {
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
        child: Scaffold(
          backgroundColor: lightGrey,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSuccessImage(),
                  _buildText(),
                  const SizedBox(height: 10.0),
                  _buildSubText(),
                ],
              ),
            ),
            _buildViewOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessImage() {
    return Lottie.asset(
      'assets/lottie/completed.json',
      height: 250,
      width: 250,
    );
  }

  Widget _buildText() {
    return Text(
      "Status Updated Successfully",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: blackFont,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildSubText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        "Order #${widget.arguments["orderId"]} status has been updated to shipped.",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: blackFont,
          fontFamily: "Inter",
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildViewOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.popAndPushNamed(context, Routes.ORDER_LIST_NEW);
        },
        backgroundColor: navyBlue,
        textColor: white,
        fontSize: 15,
        text: 'Done',
      ),
    );
  }
}
