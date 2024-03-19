import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class ShareExperience extends StatefulWidget {
  @override
  State<ShareExperience> createState() => _ShareExperienceState();
}

class _ShareExperienceState extends State<ShareExperience> {
  TextEditingController feedbackController = TextEditingController();

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
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
            floatingActionButton: _buildSubmitButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: 20),
                _buildNote(),
                SizedBox(height: 50),
                _buildFeedbackTextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Share your experience",
      style: TextStyle(
        color: blackFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildNote() {
    return Text(
      "Let us know about your experience about the route, product delivered or customer in order to serve you more better. e.g this route has bad road or long traffic, the product is not well packaged etc.",
      style: TextStyle(
        color: blackFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: "Inter",
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeedbackTextField() {
    return TextField(
      controller: feedbackController,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: "Type here",
        hintStyle: TextStyle(
          color: darkGrey,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: "Inter",
        ),
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
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CurvedButton(
        text: 'Submit',
        textColor: white,
        backgroundColor: navyBlue,
        fontSize: 15,
        onPressed: () {
          Navigator.of(context).popAndPushNamed(Routes.RESPONSE_RECEIVED);
        },
      ),
    );
  }
}
