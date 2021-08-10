import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../user_auth.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isOTPSent = false;
  final _formKey = GlobalKey<FormState>();
  String sentOTP = "";
  String phoneNumber = "";

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //     onWillPop: () async {
    //       return true;
    //     },
    //     child: Scaffold(
    //         backgroundColor: lightBlue(),
    //         resizeToAvoidBottomInset: true,
    //         appBar: AppBar(
    //             title: Center(
    //                 child: Text(AppLocalization.of(context).forgotPassword)),
    //             backgroundColor: darkBlue()),
    //         body: SingleChildScrollView(
    //           padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
    //           scrollDirection: Axis.vertical,
    //           child: Form(
    //             key: _formKey,
    //             child: Column(
    //               children: <Widget>[
    //                 getPhoneNumberWidget(),
    //                 isOTPSent
    //                     ? SizedBox(
    //                         height: 20,
    //                       )
    //                     : Container(),
    //                 isOTPSent ? getVerificationOTPWidget() : Container(),
    //                 SizedBox(
    //                   height: 20,
    //                 ),
    //                 submitButton()
    //               ],
    //             ),
    //           ),
    //         )));
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
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
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: MediaQuery.of(context).size.height -
                    (AppBar().preferredSize.height +
                        MediaQuery.of(context).padding.top),
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      forgotPasswordTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      getPhoneNumberWidget(),
                      isOTPSent
                          ? SizedBox(
                              height: 20,
                            )
                          : Container(),
                      isOTPSent ? getVerificationOTPWidget() : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      submitButton()
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget forgotPasswordTitle() {
    return Container(
      child: Text(
        "Forgot password",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget getPhoneNumberWidget() {
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   enabled: isOTPSent ? false : true,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.phone,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(
    //           Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).enterYourPhoneNumber,
    //       labelStyle: TextStyle(
    //         color: darkBlue(),
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   validator: (val) {
    //     if (val.isNotEmpty && val.length == 13) {
    //       return null;
    //     }
    //     return AppLocalization.of(context).invalidPhoneNumber;
    //   },
    //   onChanged: (val) {
    //     phoneNumber = val;
    //   },
    // );
    return CustomizedTextFormField(
      keyboardType: TextInputType.phone,
      labelText: "Phone number",
      validator: (val) {
        if (val.isNotEmpty && val.length > 9) {
          return null;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
      onChanged: (val) {
        phoneNumber = val;
      },
    );
  }

  Widget getVerificationOTPWidget() {
    return TextFormField(
      cursorColor: blackFont,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).enterYourOtpHere,
          labelStyle: TextStyle(
            color: blackFont,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isEmpty) {
          return AppLocalization.of(context).pleaseEnterOtp;
        } else if (val.length != 6 || val != sentOTP) {
          return AppLocalization.of(context).invalidOtp;
        }
        return null;
      },
      onChanged: (val) {
        sentOTP = val;
      },
    );
  }

  Widget submitButton() {
    // return ButtonTheme(
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //     onPressed: isOTPSent ? verifyOTP : sendOTP,
    //     textColor: Colors.white,
    //     color: darkBlue(),
    //     height: 50,
    //     child: Text(isOTPSent
    //         ? AppLocalization.of(context).verifyOtp
    //         : AppLocalization.of(context).continueMsg),
    //   ),
    // );
    return CurvedButton(
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: AppLocalization.of(context).continueMsg,
      onPressed: sendOTP,
    );
  }

  void verifyOTP() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      String passwordToken = "true";
      UserAuth()
          .verifyPhoneNumber(phoneNumber, sentOTP, passwordToken)
          .then((value) {
        String resetToken = value;
        Navigator.of(context).popAndPushNamed('/reset-password',
            arguments: {'phoneNumber': phoneNumber, "resetToken": resetToken});
      });
    }
  }

  void sendOTP() {
    // for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (_formKey.currentState.validate()) {
      UserAuth().registerPhoneNumber(phoneNumber).then((value) {
        Navigator.of(context).popAndPushNamed(
          "/verify-reset-password-otp",
          arguments: {
            "phoneNumber": phoneNumber,
          },
        );
      });
    }
  }
}
