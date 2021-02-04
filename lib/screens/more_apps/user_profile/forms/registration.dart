import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../user_auth.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _registrationFormKey = GlobalKey<FormState>();

  String phoneNumberWithCountryCode = "";

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  bool isUserAgree = false;

  TextEditingController phoneNumberController;

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
                  flex: 7,
                  child: Form(
                    key: _registrationFormKey,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appIcon(),
                          flexibleSpace(flex: 1),
                          registerTitle(),
                          flexibleSpace(flex: 1),
                          registrationNote(),
                          flexibleSpace(flex: 2),
                          selectCountryField(),
                          flexibleSpace(flex: 1),
                          phoneNumberField(),
                          flexibleSpace(flex: 1),
                          userAgreementField(),
                          flexibleSpace(flex: 2),
                          continueBtn(),
                          flexibleSpace(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
                flexibleSpace(flex: 3)
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
      keyboardType: TextInputType.phone,
      controller: phoneNumberController,
      validator: validatePhoneNumber,
      onChanged: (val) {
        validateField();
      },
    );
  }

  String validatePhoneNumber(number) {
    if (number.startsWith("0")) {
      return AppLocalization.of(context).invalidPhoneNumber;
    }
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
    return AppLocalization.of(context).invalidPhoneNumber;
  }

  void validateField() {
    if (phoneNumberController.text.length >= 9 && isUserAgree) {
      isValid = true;
      setState(() {});
    } else {
      isValid = false;
      setState(() {});
    }
  }

  Widget userAgreementField() {
    return getUserAgreeCheckBoxWidget();
  }

  Widget continueBtn() {
    return isValid
        ? CurvedButton(
            onPressed: continuePressed,
            text: "Continue",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : Container(
            height: 42,
          );
  }

  void continuePressed() {
    var phoneNumberFromTextField = phoneNumberController.text.trim();

    if (phoneNumberFromTextField.substring(0, 1) == "0") {
      phoneNumberFromTextField = phoneNumberFromTextField.replaceFirst("0", "");
    }

    //adding country code and '+' sign to phoneNumber
    phoneNumberWithCountryCode =
        "+" + _selectedDialogCountry.phoneCode + phoneNumberFromTextField;

    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_registrationFormKey.currentState.validate() && isUserAgree) {
      UserAuth().registerPhoneNumber(phoneNumberWithCountryCode).then((value) {
        Navigator.of(context).pushNamed(
          "/verify-registration-otp",
          arguments: {
            "phoneNumber": phoneNumberWithCountryCode,
          },
        );
      });
    }
  }

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
                    validateField();
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
                InputDecoration(hintText: AppLocalization.of(context).search),
            isSearchable: true,
            title: Text(AppLocalization.of(context).selectYourPhoneCode),
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
          country.name,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ))
      ],
    );
  }
}
