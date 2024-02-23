import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../../../../widget/loading_indicator.dart';
import '../user_auth.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  var arguments;

  ResetPassword({required this.arguments});

  @override
  _ResetPasswordState createState() =>
      _ResetPasswordState(arguments: arguments);
}

class _ResetPasswordState extends State<ResetPassword> {
  var arguments;

  _ResetPasswordState({required this.arguments});

  final _formKey = GlobalKey<FormState>();
  String newPassword = "";
  String confirmPassword = "";
  String? phoneNumber = "";
  String? resetToken = "";

  TextEditingController? _newPasswordController;
  TextEditingController? _confirmPasswordController;
  final FocusNode _pinPutFocusNode = FocusNode();
  TextEditingController? _resetTokenController;
  bool isLoading = false;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _resetTokenController = TextEditingController();

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
                child: isLoading == true
                    ? Center(child: CircularLoadingIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            resetPasswordTitle(),
                            SizedBox(
                              height: 20,
                            ),
                            passwordPinFiled(),
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
      validator: validateEnteredPassword,
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
      validator: validateEnteredConfirmPassword,
      onChanged: (val) {
        confirmPassword = val;
      },
    );
  }

  // validate password
  String? validateEnteredPassword(String val) {
    ///regexp for repeated number
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  // validate confirm password
  String? validateEnteredConfirmPassword(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    } else if (val != _newPasswordController!.text) {
      return AppLocalization.of(context)!.passwordMismatch;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  Widget passwordPinFiled() {
    BoxDecoration pinPutDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyBorderColor));
    BoxDecoration selectedDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: navyBlue));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Reset Password OTP",
            style: TextStyle(fontSize: 14, color: darkGrey),
          ),
          SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val!.length < 4
                ? AppLocalization.of(context)!.invalidPassword
                : null,
            fieldsCount: 6,
            focusNode: _pinPutFocusNode,
            controller: _resetTokenController,
            submittedFieldDecoration: pinPutDecoration,
            selectedFieldDecoration: selectedDecoration,
            followingFieldDecoration: pinPutDecoration,
            pinAnimationType: PinAnimationType.scale,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            textStyle: TextStyle(color: blackFont, fontSize: 35),
          ),
        ],
      ),
    );
  }

  Widget resetPasswordButton() {
    return CurvedButton(
      onPressed: verifyPassword,
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: AppLocalization.of(context)!.resetPassword,
    );
  }

  void verifyPassword() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState!.validate()) {
      isLoading = true;

      resetToken = _resetTokenController!.text.trim();

      UserAuth()
          .resetPassword(newPassword, confirmPassword, phoneNumber, resetToken)
          .then((value) {
        isLoading = false;
        if (value) {
          Navigator.popUntil(context, ModalRoute.withName(Routes.LOGIN));
        } else {
          showToast(message: "Something went wrong, please try again.");
        }
      }).catchError(
        (e) {
          isLoading = false;
          showToast(message: e.toString());
        },
      );
    }
  }
}
