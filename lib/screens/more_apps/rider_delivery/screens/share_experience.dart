import 'dart:io';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class ShareExperience extends StatefulWidget {
  @override
  State<ShareExperience> createState() => _ShareExperienceState();
}

class _ShareExperienceState extends State<ShareExperience> {
  TextEditingController feedbackController = TextEditingController();
  late RiderDeliveryBloc riderDeliveryBloc;
  bool isLoading = false;
  final FocusNode _nodeText1 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Color(0xFFC5C9D1),
      nextFocus: false,
      defaultDoneWidget: Text(
        'Done',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: lightGrey,
            body: _buildBody(context),
            floatingActionButton: _buildSubmitButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: KeyboardActions(
        config: _buildConfig(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
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
      focusNode: _nodeText1,
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
        onPressed: () async {
          if (isLoading == false) {
            FocusScope.of(context).unfocus();
            isLoading = true;
            if (mounted) setState(() {});
            shareRiserExperience();
            isLoading = false;
            if (mounted) setState(() {});
          }
        },
        isLoading: isLoading,
      ),
    );
  }

  Future<void> shareRiserExperience() async {
    Map<String, dynamic> data = {
      "experience": feedbackController.text.trim().toString(),
    };
    await RiderDeliveryAuthService()
        .shareExperience(riderDeliveryBloc.deliveryDetails?.id, data: data)
        .then(
      (value) async {
        if (value == true) {
          showToast(
              message: AppLocalization.of(context)!.responseSendSuccessfully);
          Navigator.of(context).popAndPushNamed(Routes.RESPONSE_RECEIVED);
        } else {
          showToast(message: 'Error');
        }
      },
    ).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }
}
