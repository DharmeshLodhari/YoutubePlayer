import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class VerifyResetPasswordOTPScreen extends StatefulWidget {
  var arguments;

  VerifyResetPasswordOTPScreen({this.arguments});

  @override
  _VerifyResetPasswordOTPScreenState createState() =>
      _VerifyResetPasswordOTPScreenState();
}

class _VerifyResetPasswordOTPScreenState
    extends State<VerifyResetPasswordOTPScreen> {
  TextEditingController? otpController;
  String? phoneNumber = '';
  FocusNode? _pinPutFocusNode;

  final _verifyOtpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    otpController = TextEditingController();
    phoneNumber = widget.arguments['phoneNumber'];
    _pinPutFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: whiteBackground,
        appBar: AppBar(
          backgroundColor: whiteBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Form(
                    key: _verifyOtpFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        verifyOTPTitle(),
                        flexibleSpace(flex: 1),
                        expirationNote(),
                        flexibleSpace(flex: 3),
                        otpFillUpField(),
                        flexibleSpace(flex: 2),
                        verifyBtn(),
                        flexibleSpace(flex: 1),
                      ],
                    ),
                  ),
                ),
                flexibleSpace(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget verifyOTPTitle() {
    return Text(
      "Verify OTP",
      style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
    );
  }

  Widget expirationNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Please enter code that sent to your phone number in the form below.",
          style: TextStyle(fontSize: 14, color: darkGrey),
        ),
        Row(
          children: <Widget>[
            Text(
              "This code will expired in",
              style: TextStyle(fontSize: 14, color: darkGrey),
            ),
            const Text(
              " 00:30 ",
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            Text(
              "seconds.",
              style: TextStyle(fontSize: 14, color: darkGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget otpFillUpField() {
    final BoxDecoration navyBlueBorder = BoxDecoration(
      border: Border(
          bottom: BorderSide(
        color: navyBlue,
        width: 2,
      )),
    );
    final BoxDecoration grayBorder = BoxDecoration(
      border: Border(
          bottom: BorderSide(
        color: HexColor("#E6E5EB"),
        width: 2,
      )),
    );
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: whiteBackground)),
      shadowColor: whiteBackground,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 28),
        child: Pinput(
          length: 6,
          focusNode: _pinPutFocusNode,
          controller: otpController,
          defaultPinTheme: PinTheme(
            width: 40,
            height: 45,
            textStyle: TextStyle(
              fontSize: 32,
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          focusedPinTheme: PinTheme(
            decoration: grayBorder,
          ),
          submittedPinTheme: PinTheme(
            decoration: navyBlueBorder,
          ),
          followingPinTheme: PinTheme(
            decoration: grayBorder,
          ),
          pinAnimationType: PinAnimationType.scale,
          validator: (val) {
            if (val!.length != 6) {
              return "Please enter code that sent to you";
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget verifyBtn() {
    return CurvedButton(
      onPressed: verifyOTP,
      text: "Verify",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  void verifyOTP() {
    if (_verifyOtpFormKey.currentState!.validate()) {
      final String enteredOTP = otpController!.text.trim();
      final String passwordToken = "true";

      UserAuth()
          .verifyPhoneNumber(phoneNumber, enteredOTP, passwordToken)
          .then((value) {
        final String? resetToken = value;
        Navigator.of(context).popAndPushNamed('/reset-password',
            arguments: {'phoneNumber': phoneNumber, "resetToken": resetToken});
      });
    }
  }
}
