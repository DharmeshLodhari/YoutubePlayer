import 'dart:io';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isOTPSent = false;
  final _formKey = GlobalKey<FormState>();
  String sentOTP = "";
  String phoneNumber = "";
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
            backgroundColor: lightBlue(),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                automaticallyImplyLeading: Platform.isAndroid ? false : true,
                title: Center(child: Text("Forgot Password")),
                backgroundColor: darkBlue()),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
            )));
  }

  getPhoneNumberWidget() {
    return TextFormField(
      cursorColor: darkBlue(),
      enabled: isOTPSent ? false : true,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(
              Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone),
          fillColor: Colors.white,
          filled: true,
          hintText: "Enter Your Phone Number",
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return "Invalid phone number";
      },
      onChanged: (val) {
        phoneNumber = val;
      },
    );
  }

  Widget getVerificationOTPWidget() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: "Enter Your OTP Here",
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isEmpty) {
          return "Please Enter OTP";
        } else if (val.length != 6 || val != sentOTP) {
          return "Invalid OTP";
        }
        return null;
      },
      onChanged: (val) {
        sentOTP = val;
      },
    );
  }

  Widget submitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: isOTPSent ? verifyOTP : sendOTP,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(isOTPSent ? "Verify OTP" : "Continue"),
      ),
    );
  }

  void verifyOTP() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      _auth.verifyPhoneNumber(phoneNumber, sentOTP).then((value) {
        String resetToken = value;
        Navigator.of(context).popAndPushNamed('/reset-password',
            arguments: {'phoneNumber': phoneNumber, "resetToken": resetToken});
      });
    }
  }

  void sendOTP() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    _auth.registerPhoneNumber(phoneNumber).then((value) {
      if (_formKey.currentState.validate()) {
        setState(() {
          isOTPSent = true;
        });
      }
    });
  }
}
