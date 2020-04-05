//TODO: first page take phone number and verify OTP and submit Button
//TODO: Second Screen registration screen with disabled phone number take password and register Button
//TODO: Third page add Document

import 'dart:io';

import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../widget/LoadingIndicator.dart';

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
          title: Text('Sign up'),
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
                        child: Text('Use 4 Digit Number')),
                  ),
                  SizedBox(height: 10),
                  getPassword1Field(),
                  SizedBox(height: 10),
                  getPassword2Field(),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                        'By clicking Register you are agreeing to the Terms and Conditions.'),
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
        hintText: "Phone Number",
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
        return "Invalid phone number";
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
        hintText: "Full Name",
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
      validator: (val) =>
          val.length < 5 ? "Enter a valid name matching account number." : null,
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
        hintText: "Password",
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
      validator: (val) => val.length != 4 ? "Enter a valid Password." : null,
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
        hintText: "Confirm Password",
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
          return "Enter a valid Password.";
        } else if (val != password1) {
          return "Password MissMatch";
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
            var msg = "Invalid Details !!";
            Toast.show(msg, context,
                gravity: Toast.BOTTOM,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Register"),
      ),
    );
  }
}
