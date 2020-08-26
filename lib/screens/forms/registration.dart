import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/country_picker/country.dart';
import 'package:Slydo/models/country_picker/country_picker_dialog.dart';
import 'package:Slydo/models/country_picker/utils.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

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

  List<DropdownMenuItem> dropDownList = new List<DropdownMenuItem>();
  int selectedCountry = 0;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  bool isUserAgree = false;

  TextEditingController phoneNumberController;

  @override
  void initState() {
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    return WillPopScope(
//        onWillPop: () async {
//          return true;
//        },
//        child: Scaffold(
//            backgroundColor: lightBlue(),
//            resizeToAvoidBottomInset: true,
//            appBar: AppBar(
//                title: Center(child: Text(AppLocalization.of(context).signUp)),
//                backgroundColor: darkBlue()),
//            body: SingleChildScrollView(
//              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
//              scrollDirection: Axis.vertical,
//              child: Form(
//                key: _formKey,
//                child: Column(
//                  children: <Widget>[
//                    getCountryDropdown(),
//                    SizedBox(
//                      height: 10,
//                    ),
//                    Text(
//                      AppLocalization.of(context).termsForRegistration,
//                      style: TextStyle(color: darkBlue()),
//                    ),
//                    SizedBox(
//                      height: 10,
//                    ),
//                    getPhoneNumberWidget(),
//                    isOTPSent
//                        ? SizedBox(
//                            height: 10,
//                          )
//                        : Container(),
//                    isOTPSent ? getVerificationOTPWidget() : Container(),
//                    SizedBox(
//                      height: 20,
//                    ),
//                    getUserAgreeCheckBoxWidget(),
//                    SizedBox(
//                      height: 20,
//                    ),
//                    submitButton()
//                  ],
//                ),
//              ),
//            )));
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
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 6,
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
                              flex: 1,
                              child: SizedBox(
                                height: 10,
                              )),
                          registrationNote(),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 10,
                              )),
                          selectCountryField(),
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
                          userAgreementField(),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 10,
                              )),
                          continueBtn(),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 10,
                    ))
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

  Widget selectCountryField() {
    return Container(
      child: getCountryDropdown(),
    );
  }

  Widget phoneNumberField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Phone number",
      type: TextInputType.phone,
      controller: phoneNumberController,
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
    );
  }

  Widget userAgreementField() {
    return getUserAgreeCheckBoxWidget();
  }

  Widget continueBtn() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/verify-registration-otp");
      },
      text: "Continue",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
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
    return isUserAgree && enteredPhoneNumber.length == 9
        ? ButtonTheme(
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
          )
        : Container();
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

    if (_formKey.currentState.validate() && isUserAgree) {
      _auth.registerPhoneNumber(phoneNumberWithCountryCode).then((value) {
        setState(() {
          isOTPSent = true;
        });
      });
    }
  }

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context).selectYourCountry,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: whiteBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            onTap: isOTPSent ? () {} : _openCountryPickerDialog,
            title: _buildDialogItem(_selectedDialogCountry),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ),
        SizedBox(width: 8.0),
        Flexible(
            child: Text(
          country.name,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ))
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

  Widget getUserAgreeCheckBoxWidget() {
    return Row(
      children: <Widget>[
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: SizedBox(
            width: Checkbox.width - 1.5,
            height: Checkbox.width - 1.5,
            child: Container(
              decoration: new BoxDecoration(
                border: Border.all(
                  color: greyBorderColor,
                  width: 1,
                ),
                borderRadius: new BorderRadius.circular(5),
              ),
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.transparent,
                ),
                child: Checkbox(
                  value: isUserAgree,
                  onChanged: (value) {
                    isUserAgree = value;
                    setState(() {});
                  },
                  activeColor: navyBlue,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            AppLocalization.of(context).termsForUserAgreeCheckBox,
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
