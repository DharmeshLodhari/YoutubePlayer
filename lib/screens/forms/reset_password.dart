import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
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

  TextEditingController _newPasswordController;
  TextEditingController _confirmPasswordController;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    resetToken = arguments['resetToken'];

    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: navyBlue,
                ),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/login'));
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
                      resetPasswordTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      newPasswordWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      confirmPasswordWidget(),
                      SizedBox(
                        height: 40,
                      ),
                      resetPasswordButton(),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget resetPasswordTitle() {
    return Container(
      child: Text(
        "Reset password",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget newPasswordWidget() {
    return CustomizedTextFormField(
      maxLength: 6,
      obscureText: true,
      keyboardType: TextInputType.number,
      labelText: "New password",
      controller: _newPasswordController,
      isPassword: true,
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

  Widget confirmPasswordWidget() {
    return CustomizedTextFormField(
      obscureText: true,
      maxLength: 6,
      labelText: "Confirm password",
      isPassword: true,
      controller: _confirmPasswordController,
      keyboardType: TextInputType.number,
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
    return CurvedButton(
      onPressed: verifyPassword,
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: AppLocalization.of(context).resetPassword,
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
          Navigator.popUntil(context, ModalRoute.withName('/login'));
        }
      });
    }
  }
}
