import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

// ignore: must_be_immutable
class VerifyOTPScreen extends StatefulWidget {
  var arguments;
  VerifyOTPScreen({this.arguments});
  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  TextEditingController otpController;
  String phoneNumber = '';
  FocusNode _pinPutFocusNode;
  final _auth = AuthService();

  final _verifyOtpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    otpController = TextEditingController();
    phoneNumber = widget.arguments['phoneNumber'];
    _pinPutFocusNode = FocusNode();
    super.initState();
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
            padding: EdgeInsets.symmetric(horizontal: 20),
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
                    child: Container(
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
    return Container(
      child: Text(
        "Verify OTP",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget expirationNote() {
    return Container(
      child: Column(
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
              Text(
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
      ),
    );
  }

  Widget otpFillUpField() {
    BoxDecoration navyBlueBorder = BoxDecoration(
      border: Border(
          bottom: BorderSide(
        color: navyBlue,
        width: 2,
      )),
    );
    BoxDecoration grayBorder = BoxDecoration(
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 28),
        child: PinPut(
          eachFieldWidth: 40,
          eachFieldHeight: 45,
          fieldsCount: 6,
          focusNode: _pinPutFocusNode,
          controller: otpController,
          submittedFieldDecoration: navyBlueBorder,
          selectedFieldDecoration: grayBorder,
          followingFieldDecoration: grayBorder,
          pinAnimationType: PinAnimationType.scale,
          textStyle: TextStyle(
              color: blackFont, fontSize: 32, fontWeight: FontWeight.w600),
          validator: (val) {
            if (val.length != 6) {
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
    if (_verifyOtpFormKey.currentState.validate()) {
      String enteredOTP = otpController.text.trim();
      String passwordToken = "false";
      _auth
          .verifyPhoneNumber(phoneNumber, enteredOTP, passwordToken)
          .then((value) {
        Navigator.of(context).popAndPushNamed('/register', arguments: {
          'phoneNumber': phoneNumber,
        });
      });
    }
  }
}
