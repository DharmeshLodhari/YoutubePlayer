import 'dart:io';

import 'package:flutter/material.dart';

import '../colors.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  var arguments;

  ResetPassword({@required this.arguments});
  @override
  _ResetPasswordState createState() =>
      _ResetPasswordState(arguments: arguments);
}

class _ResetPasswordState extends State<ResetPassword> {
  var arguments;
  _ResetPasswordState({@required this.arguments});

  final _formKey = GlobalKey<FormState>();
  String newPassword = "";
  String confirmPassword = "";
  String phoneNumber = "";

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    super.initState();
  }

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
                title: Center(child: Text("Reset Password")),
                backgroundColor: darkBlue()),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    newPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    confirmPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    resetPasswordButton()
                  ],
                ),
              ),
            )));
  }

  newPasswordWidget() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      maxLength: 4,
      maxLengthEnforced: true,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: "New Password",
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
          return "Password Should Not Empty";
        } else if (val.length != 4) {
          return "Password Must Be Of 4 Digit";
        }
        return null;
      },
      onChanged: (val) {
        newPassword = val;
      },
    );
  }

  confirmPasswordWidget() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: true,
      maxLength: 4,
      maxLengthEnforced: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: "Confirm Password",
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
          return "Password Should Not Empty";
        } else if (val.length != 4) {
          return "Password Must Be Of 4 Digit";
        } else if (newPassword != confirmPassword) {
          return "Password Mismatch";
        }
        return null;
      },
      onChanged: (val) {
        confirmPassword = val;
      },
    );
  }

  Widget resetPasswordButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: verifyPassword,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Reset Password"),
      ),
    );
  }

  void verifyPassword() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    //TODO: CALL UPDATE PASSWORD API FOR CURRENT USER BY USING phoneNumber VARIABLE

    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
    }
  }
}
