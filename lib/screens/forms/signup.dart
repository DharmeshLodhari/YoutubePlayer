import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(AppLocalization.of(context).signUp),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  getPhoneNumberField(),
                  SizedBox(height: 10),
                  getFullNameField(),
                  SizedBox(height: 10),
                  Container(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            AppLocalization.of(context).useFourDigitNumber)),
                  ),
                  SizedBox(height: 10),
                  getPassword1Field(),
                  SizedBox(height: 10),
                  getPassword2Field(),
                  SizedBox(height: 10),
                  Container(
                    child: Text(AppLocalization.of(context).termsAndCondition),
                  ),
                  SizedBox(height: 10),
                  getSubmitButton(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ));
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
        setState(() {
          fullName = val.trim();
        });
      },
    );
  }

  Widget getPassword1Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
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
      validator: (val) =>
          val.length != 4 ? AppLocalization.of(context).invalidPassword : null,
      onChanged: (val) {
        setState(() {
          password1 = val.trim();
        });
      },
    );
  }

  Widget getPassword2Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      maxLength: 4,
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
      validator: (val) {
        if (val.length != 4) {
          return AppLocalization.of(context).invalidPassword;
        } else if (val != password1) {
          return AppLocalization.of(context).passwordMismatch;
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          password2 = val.trim();
        });
      },
    );
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

            //TODO: Call The USER REGISTRATION API
            bool isRegistered;
            _auth.userRegistration(data).then((value) {
              isRegistered = value;
              if (isRegistered) {
                _auth.authenticate(phoneNumber, password1).then((value) {
                  Navigator.pop(context);
                  Navigator.of(context).popAndPushNamed('/add-document');
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
