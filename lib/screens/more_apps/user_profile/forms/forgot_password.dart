import 'dart:convert';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/util.dart';
import '../../../../widget/loading_indicator.dart';
import '../user_auth.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isOTPSent = false;
  final _formKey = GlobalKey<FormState>();
  String sentOTP = "";

  late Country _selectedDialogCountry;

  TextEditingController? phoneNumberController = TextEditingController();
  late http.Response response;
  String errorMessage = "";
  bool isLoading = false;

  @override
  void initState() {
    _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
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
                            forgotPasswordTitle(),
                            SizedBox(
                              height: 20,
                            ),
                            phoneNumberField(),
                            isOTPSent
                                ? SizedBox(
                                    height: 20,
                                  )
                                : Container(),
                            isOTPSent
                                ? getVerificationOTPWidget()
                                : Container(),
                            SizedBox(
                              height: 20,
                            ),
                            submitButton()
                          ],
                        ),
                      ),
              ),
            )));
  }

  Widget forgotPasswordTitle() {
    return Container(
      child: Text(
        AppLocalization.of(context)!.forgotPassword,
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget phoneNumberField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: getCountryDropdown()),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 5,
          child: CustomizedTextFormField(
            labelColor: darkGrey,
            keyboardType: TextInputType.phone,
            controller: phoneNumberController,
            hintText: "08023000000",
            validator: (val) {
              if (val.isNotEmpty && val.length >= 9) {
                return null;
              }
              return AppLocalization.of(context)!.invalidPhoneNumber;
            },
          ),
        ),
      ],
    );
  }

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Phone number",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            onTap: () {
              _openCountryPickerDialog(isForLogin: true);
            },
            title: _buildDialogItem(_selectedDialogCountry),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        SizedBox(width: 4.0),
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            "+${country.phoneCode}",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          color: blackFont,
        ),
        SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildDialogItemWithName(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            "(" + country.name! + ")",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  void _openCountryPickerDialog({bool isForLogin = false}) => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: navyBlue),
          child: CountryPickerDialog(
            isForLogin: isForLogin,
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: navyBlue,
            searchInputDecoration: InputDecoration(
              hintText: AppLocalization.of(context)!.search,
              hintStyle: TextStyle(
                fontSize: 16,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            isSearchable: true,
            title: Text(
              AppLocalization.of(context)!.selectYourPhoneCode,
              style: TextStyle(
                fontSize: 14,
                color: blackFont,
                fontWeight: FontWeight.w400,
              ),
            ),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _buildDialogItemWithName,
          ),
        ),
      );

  Widget getVerificationOTPWidget() {
    return TextFormField(
      cursorColor: blackFont,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dialpad),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context)!.enterYourOtpHere,
          labelStyle: TextStyle(
            color: blackFont,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val!.isEmpty) {
          return AppLocalization.of(context)!.pleaseEnterOtp;
        } else if (val.length != 6 || val != sentOTP) {
          return AppLocalization.of(context)!.invalidOtp;
        }
        return null;
      },
      onChanged: (val) {
        sentOTP = val;
      },
    );
  }

  Widget submitButton() {
    return CurvedButton(
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: AppLocalization.of(context)!.continueMsg,
      onPressed: sendOTP,
    );
  }

  void sendOTP() {
    // for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (_formKey.currentState!.validate()) {
      isLoading = true;

      var phoneNumberFromTextField = phoneNumberController!.text.trim();

      if (phoneNumberFromTextField.substring(0, 1) == "0") {
        phoneNumberFromTextField =
            phoneNumberFromTextField.replaceFirst("0", "");
      }

      String phoneNumber =
          "+" + _selectedDialogCountry.phoneCode! + phoneNumberFromTextField;

      UserAuth().passwordResetOtp(phoneNumber).then((value) {
        response = value;

        try {
          handleServerErrors(response);
        } catch (e) {
          return Future.error(response.body);
        }

        isLoading = false;

        if (response.statusCode == 200) {
          Navigator.of(context).popAndPushNamed('/reset-password',
              arguments: {'phoneNumber': phoneNumber});
        } else if (response.statusCode == 400) {
          setState(() {
            errorMessage = "${jsonDecode(value.body)["error"]}";
            showToast(message: errorMessage);
          });
        } else if (response.statusCode == 500) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.serverError;
            showToast(message: errorMessage);
          });
        } else {
          if (response.statusCode == 406) {
            errorMessage = jsonDecode(value.body)[0];
            showToast(message: "$errorMessage");
            setState(() {});
          } else {
            debugPrint("ERROR:- ${response.body}");
            setState(() {
              errorMessage = AppLocalization.of(context)!.somethingWentWrong;
              showToast(message: "$errorMessage");
            });
          }
        }
      });
    }
  }
}
