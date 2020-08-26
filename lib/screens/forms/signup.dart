import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../widget/LoadingIndicator.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  var arguments;
  SignUp({@required this.arguments});

  @override
  _SignUpState createState() => _SignUpState(arguments: arguments);
}

class _SignUpState extends State<SignUp> {
  var arguments;
  _SignUpState({@required this.arguments});

  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  String phoneNumber = '';
  String fullName = '';
  String password1 = '';
  String password2 = '';

  UserBloc userBloc;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
//    return Scaffold(
//        backgroundColor: lightBlue(),
//        resizeToAvoidBottomInset: true,
//        appBar: AppBar(
//          title: Text(AppLocalization.of(context).signUp),
//          backgroundColor: darkBlue(),
//          elevation: 0.0,
//        ),
//        body: Center(
//          child: SingleChildScrollView(
//            scrollDirection: Axis.vertical,
//            padding: EdgeInsets.symmetric(horizontal: 40.0),
//            child: Form(
//              key: _formKey,
//              child: Column(
//                children: <Widget>[
//                  getPhoneNumberField(),
//                  SizedBox(height: 10),
//                  Text(
//                    AppLocalization.of(context).termsForName,
//                    style: TextStyle(
//                      color: darkBlue(),
//                    ),
//                  ),
//                  SizedBox(height: 10),
//                  getFullNameField(),
//                  SizedBox(height: 10),
//                  Container(
//                    child: Align(
//                        alignment: Alignment.centerLeft,
//                        child: Text(
//                            AppLocalization.of(context).useFourDigitNumber)),
//                  ),
//                  SizedBox(height: 10),
//                  getPassword1Field(),
//                  SizedBox(height: 10),
//                  getPassword2Field(),
//                  SizedBox(height: 10),
//                  InkWell(
//                    child: Container(
//                      child:
//                          Text(AppLocalization.of(context).termsAndCondition),
//                    ),
//                    onTap: () {
//                      launch('http://slydo.co/terms');
//                    },
//                  ),
//                  SizedBox(height: 10),
//                  getSubmitButton(),
//                  SizedBox(height: 50),
//                ],
//              ),
//            ),
//          ),
//        ));
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
                  child: Form(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appIcon(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          registerTitle(),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 10,
                              )),
                          registrationNote(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          phoneNumberField(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          fullNameField(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          passwordField(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          confirmPasswordField(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          registerBtn(),
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon() {
    return Container(
      child: Image.asset(
        "assets/images/app_logo_navyBlue.png",
        height: MediaQuery.of(context).size.height / 16,
        frameBuilder: imageFrameBuilder,
      ),
    );
  }

  Widget registerTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Register to ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
          ),
          Text(
            "Slydo",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
        ],
      ),
    );
  }

  Widget registrationNote() {
    return Container(
      child: Text(
        "Please enter your phone number. This phone number must be the one registered with your BVN",
        style: TextStyle(fontSize: 14, color: darkGrey),
      ),
    );
  }

  Widget phoneNumberField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Phone number",
      type: TextInputType.phone,
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
    );
  }

  Widget fullNameField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Full number",
      type: TextInputType.text,
    );
  }

  Widget passwordField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "New Password",
      type: TextInputType.number,
    );
  }

  Widget confirmPasswordField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Confirm password",
      type: TextInputType.number,
    );
  }

  Widget registerBtn() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/index",
          (Route<dynamic> route) => false,
        );
      },
      text: "Register",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  Widget getPhoneNumberField() {
    return TextFormField(
      enabled: false,
      cursorColor: darkBlue(),
      autofocus: false,
      initialValue: phoneNumber,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon:
            Icon(Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone),
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalization.of(context).enterYourPhoneNumber,
        labelStyle: TextStyle(
          color: darkBlue(),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
              width: 1, color: Colors.white, style: BorderStyle.solid),
        ),
      ),
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
    );
  }

  Widget getFullNameField() {
    return TextFormField(
      autofocus: true,
      obscureText: false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalization.of(context).fullName,
        labelStyle: TextStyle(
          color: darkBlue(),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.green,
            style: BorderStyle.solid,
          ),
        ),
      ),
      validator: (val) => val.length < 5
          ? AppLocalization.of(context).enterValidNameMatchingAccountNumber
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            fullName = val.trim();
          });
        }
      },
    );
  }

  Widget getPassword1Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      maxLengthEnforced: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalization.of(context).password,
        labelStyle: TextStyle(
          color: darkBlue(),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
      ),
      validator: validatepassword1,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            password1 = val.trim();
          });
        }
      },
    );
  }

  String validatepassword1(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context).invalidPassword;
    } else if (val == "123456" || val == "012345") {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  Widget getPassword2Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      maxLength: 6,
      maxLengthEnforced: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalization.of(context).confirmPassword,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
      ),
      validator: validatepassword2,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            password2 = val.trim();
          });
        }
      },
    );
  }

  String validatepassword2(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context).invalidPassword;
    } else if (val != password1) {
      return AppLocalization.of(context).passwordMismatch;
    } else if (val == "123456" || val == "012345") {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      //elevation: 4,
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
          if (_formKey.currentState.validate()) {
            Map data = {
              "phoneNumber": phoneNumber,
              "fullName": fullName,
              "password1": password1,
              "password2": password2,
            };

            showDialog(
                context: context, builder: (context) => LoadingIndicator());

            bool isRegistered;
            _auth.userRegistration(data).then((value) {
              isRegistered = value;
              if (isRegistered) {
                _auth.authenticate(phoneNumber, password1).then((value) {
                  var user = value;
                  userBloc.user = user;
                  Navigator.pop(context);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    "/dashboard",
                    (Route<dynamic> route) => false,
                  );
                });
              }
            });
          } else {
            var msg = AppLocalization.of(context).invalidDetails;
            Toast.show(msg, context,
                gravity: Toast.BOTTOM,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).register),
      ),
    );
  }
}
