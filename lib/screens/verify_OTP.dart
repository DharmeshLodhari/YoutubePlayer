import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class VerifyOTPScreen extends StatefulWidget {
  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  var passwordController;

  FocusNode _pinPutFocusNode;

  @override
  void initState() {
    passwordController = TextEditingController();
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
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Form(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          verifyOTPTitle(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          expirationNote(),
                          Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 10,
                              )),
                          otpFillUpField(),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 10,
                              )),
                          verifyBtn(),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ))
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
        padding: EdgeInsets.symmetric(horizontal: 42, vertical: 28),
        child: PinPut(
          eachFieldWidth: 45,
          eachFieldHeight: 45,
          fieldsCount: 4,
          focusNode: _pinPutFocusNode,
          controller: passwordController,
          submittedFieldDecoration: navyBlueBorder,
          selectedFieldDecoration: grayBorder,
          followingFieldDecoration: grayBorder,
          pinAnimationType: PinAnimationType.scale,
          textStyle: TextStyle(
              color: blackFont, fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget verifyBtn() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).popAndPushNamed('/register', arguments: {
          'phoneNumber': "+353877120700",
        });
      },
      text: "Verify",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }
}
