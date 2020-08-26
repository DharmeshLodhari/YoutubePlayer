import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

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

  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String newPassword = "";
  String confirmPassword = "";
  String phoneNumber = "";
  String resetToken = "";

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    resetToken = arguments['resetToken'];
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: lightBlue(),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                title: Center(
                    child: Text(AppLocalization.of(context).resetPassword)),
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
                    resetPasswordButton(),
                  ],
                ),
              ),
            )));
  }

  newPasswordWidget() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      maxLength: 6,
      maxLengthEnforced: true,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).newPassword,
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
          return AppLocalization.of(context).passwordShouldNotEmpty;
        } else if (val.length != 6) {
          return "Password must be of 6 digit";
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
      maxLength: 6,
      maxLengthEnforced: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).confirmPassword,
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
          return AppLocalization.of(context).passwordShouldNotEmpty;
        } else if (val.length != 6) {
          return "Password must be of 6 digit";
        } else if (newPassword != confirmPassword) {
          return AppLocalization.of(context).passwordMismatch;
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
        child: Text(AppLocalization.of(context).resetPassword),
      ),
    );
  }

  void verifyPassword() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      _auth
          .passwordReset(newPassword, confirmPassword, phoneNumber, resetToken)
          .then((value) {
        if (value) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
