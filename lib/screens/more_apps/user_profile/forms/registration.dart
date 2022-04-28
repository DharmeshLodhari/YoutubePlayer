import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../widget/LoadingIndicator.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _registrationFormKey = GlobalKey<FormState>();

  String phoneNumberWithCountryCode = "";

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  TextEditingController? phoneNumberController;

  // this variable is responsible to enable and disable submit btn
  bool isValid = false;

  @override
  void initState() {
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
            child: Form(
              key: _registrationFormKey,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    appIcon(),
                    SizedBox(
                      height: 20,
                    ),
                    registerTitle(),
                    SizedBox(
                      height: 50,
                    ),
                    selectCountryField(),
                    SizedBox(
                      height: 12,
                    ),
                    phoneNumberField(),
                    SizedBox(
                      height: 40,
                    ),
                    continueBtn(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
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

  Widget selectCountryField() {
    return Container(
      child: getCountryDropdown(),
    );
  }

  Widget phoneNumberField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Phone number",
      hintText: "08023000000",
      keyboardType: TextInputType.phone,
      controller: phoneNumberController,
      validator: validatePhoneNumber,
      onChanged: (val) {
        validateField();
      },
    );
  }

  String? validatePhoneNumber(number) {
    if (number.contains('+') ||
        number.contains('-') ||
        number.contains('*') ||
        number.contains('#') ||
        number.contains(',') ||
        number.contains(';') ||
        number.contains('(') ||
        number.contains(')') ||
        number.contains('/') ||
        number.contains('N') ||
        number.contains(' ')) {
      return "Please enter phone number without country code";
    }
    if (number.isNotEmpty && number.length >= 9) {
      return null;
    }
    return AppLocalization.of(context)!.invalidPhoneNumber;
  }

  void validateField() {
    if (phoneNumberController!.text.length >= 9) {
      isValid = true;
      setState(() {});
    } else {
      isValid = false;
      setState(() {});
    }
  }

  Widget continueBtn() {
    return isValid
        ? CurvedButton(
            onPressed: submit,
            text: "Continue",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : Container(height: 42);
  }

  void submit() {
    var phoneNumberFromTextField = phoneNumberController!.text.trim();

    if (phoneNumberFromTextField.substring(0, 1) == "0") {
      phoneNumberFromTextField = phoneNumberFromTextField.replaceFirst("0", "");
    }

    //adding country code and '+' sign to phoneNumber
    phoneNumberWithCountryCode =
        "+" + _selectedDialogCountry.phoneCode! + phoneNumberFromTextField;

    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_registrationFormKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      UserAuth().registerPhoneNumber(phoneNumberWithCountryCode).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).popAndPushNamed(
          Routes.VERIFY_REGISTRATION_OTP,
          arguments: {
            "phoneNumber": phoneNumberWithCountryCode,
          },
        );
      }).catchError((error) {
        Navigator.of(context).pop();
        showToast(message: "$error");
      });
    }
  }

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.selectYourCountry,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            onTap: _openCountryPickerDialog,
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

  //showing select country dialog
  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration:
                InputDecoration(hintText: AppLocalization.of(context)!.search),
            isSearchable: true,
            title: Text(AppLocalization.of(context)!.selectYourPhoneCode),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _buildDialogItem,
          ),
        ),
      );

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
          country.name!,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ))
      ],
    );
  }
}
