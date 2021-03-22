import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

// ignore: must_be_immutable
class VerifyResetDeviceOTPScreen extends StatefulWidget {
  var arguments;

  VerifyResetDeviceOTPScreen({this.arguments});

  @override
  _VerifyResetDeviceOTPScreenState createState() =>
      _VerifyResetDeviceOTPScreenState();
}

class _VerifyResetDeviceOTPScreenState
    extends State<VerifyResetDeviceOTPScreen> {
  TextEditingController otpController;
  String phoneNumber = '';
  String requireOtp;

  FocusNode _pinPutFocusNode;

  final _verifyOtpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    otpController = TextEditingController();
    phoneNumber = widget.arguments['data']['phone_number'];
    requireOtp = widget.arguments['data']['otp'];
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
      // String enteredOTP = otpController.text.trim();
      // String passwordToken = "false";

      // if (enteredOTP == requireOtp) {
      // UserAuth()
      //     .verifyOTPForResetDevice(phoneNumber, enteredOTP, passwordToken)
      //     .then((value) {

      showAlertDialogForInformation();

      // });
      // }
    }
  }

  void showAlertDialogForInformation() async {
    var result = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, rentDurationStateSetter) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Stack(
            overflow: Overflow.visible,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Note",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Your device is reset successfully. You can log in back to your account after 24 hours.",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlatButton(
                                padding: EdgeInsets.zero,
                                child: Text("OK",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context, true);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 100) / 2,
                top: -30,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        color: navyBlue,
                        border: Border.all(color: dividerColor, width: 1.5),
                        borderRadius: BorderRadius.circular(60)),
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Image.asset(
                        "assets/images/appIcon/appIcon_foreground.png",
                        height: 100,
                        fit: BoxFit.fill,
                        scale: 0.5,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );

    if (result == null || result) {
      Navigator.pop(context);
    }
  }
}
