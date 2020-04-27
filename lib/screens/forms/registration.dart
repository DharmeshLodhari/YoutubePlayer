import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/country_picker/country.dart';
import 'package:Slydo/models/country_picker/country_picker_dialog.dart';
import 'package:Slydo/models/country_picker/utils.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool isOTPSent = false;
  final _formKey = GlobalKey<FormState>();
  String sentOTP = "";
  String enteredPhoneNumber = "";
  String phoneNumberWithCountryCode = "";
  final _auth = AuthService();

  List<DropdownMenuItem> dropdownlist = new List<DropdownMenuItem>();
  int selectedCountry = 0;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('IE');

  @override
  void initState() {
    super.initState();
  }

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
                title: Center(child: Text(AppLocalization.of(context).signUp)),
                backgroundColor: darkBlue()),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    getCountryDropdown(),
                    SizedBox(
                      height: 10,
                    ),
                    getPhoneNumberWidget(),
                    isOTPSent
                        ? SizedBox(
                            height: 10,
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
          prefixText: "+" + _selectedDialogCountry.phoneCode,
          hintText: AppLocalization.of(context).enterYourPhoneNumber,
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isNotEmpty && val.length >= 9) {
          return null;
        }
        if (val.startsWith("0")) {
          return AppLocalization.of(context).invalidPhoneNumber;
        }
        if (val.contains('+') ||
            val.contains('-') ||
            val.contains('*') ||
            val.contains('#') ||
            val.contains(',') ||
            val.contains(';') ||
            val.contains('(') ||
            val.contains(')') ||
            val.contains('/') ||
            val.contains('N') ||
            val.contains(' ')) {
          return AppLocalization.of(context).invalidPhoneNumber;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
      onChanged: (val) {
        enteredPhoneNumber = val;
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
          hintText: AppLocalization.of(context).enterYourOtpHere,
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
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: isOTPSent ? verifyOTP : sendOTP,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(isOTPSent
            ? AppLocalization.of(context).verifyOtp
            : AppLocalization.of(context).continueMsg),
      ),
    );
  }

  void verifyOTP() {
    //final phoneNumber with countrycode
    phoneNumberWithCountryCode =
        "+" + _selectedDialogCountry.phoneCode + enteredPhoneNumber;

    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      String passwordToken = "false";
      _auth
          .verifyPhoneNumber(phoneNumberWithCountryCode, sentOTP, passwordToken)
          .then((value) {
        String resetToken = value;
        Navigator.of(context).popAndPushNamed('/register', arguments: {
          'phoneNumber': phoneNumberWithCountryCode,
        });
      });
    }
  }

  void sendOTP() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      _auth.registerPhoneNumber(phoneNumberWithCountryCode).then((value) {
        setState(() {
          isOTPSent = true;
        });
      });
    }
  }

  getCountryDropdown() {
    return Card(
      margin: EdgeInsets.all(0),
      borderOnForeground: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
            child: Center(
              child: Text(
                AppLocalization.of(context).selectYourCountry,
                style: TextStyle(color: darkBlue()),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            onTap: isOTPSent ? () {} : _openCountryPickerDialog,
            title: _buildDialogItem(_selectedDialogCountry),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text("+${country.phoneCode}"),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name))
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration:
                InputDecoration(hintText: AppLocalization.of(context).search),
            isSearchable: true,
            title: Text(AppLocalization.of(context).selectYourPhoneCode),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _buildDialogItem,
          ),
        ),
      );
}
