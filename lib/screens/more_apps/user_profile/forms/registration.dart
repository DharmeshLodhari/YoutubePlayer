import 'dart:async';
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
  String phoneNumberWithCountryCode = "";

  final _registrationFormKey = GlobalKey<FormState>();

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  TextEditingController phoneNumberController = TextEditingController();

  // this variable is responsible to enable and disable submit btn
  bool showButton = false;
  bool isUserAgree = false;


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
                    SizedBox(height: 20),
                    appIcon(),
                    SizedBox(height: 20),
                    registerTitle(),
                    SizedBox(height: 8),
                    Text(
                      AppLocalization.of(context)!.registerTopInformation,
                      style: TextStyle(color: darkGrey, fontSize: 14),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    selectCountryField(),
                    SizedBox(height: 12),
                    phoneNumberField(),
                    SizedBox(height: 12),
                    getUserAgreeCheckBoxWidget(),
                    SizedBox(height: 12),

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
            "Slydo ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
          Text(
            "Registration",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
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
      isNumberOnlyInput: true,
      keyboardType: TextInputType.phone,
      controller: phoneNumberController,
      validator: validatePhoneNumber,
      onChanged: (value) {
        if (value.isEmpty || value.length < 10) {
          setState(() {
            showButton = false;
          });
        }
      },
      whenToVerifyInputFromServer: (value) => value.length >= 10,
      verifyInputFromServerFunc: () => _verifyPhoneNumber(),
      extraFunctionWhenInputWasVerifiedFromServerSuccessfully: () {
        if (phoneNumberController.text.length >= 10) {
          setState(() {
            showButton = true;
          });
        }
      },
      extraFunctionWhenInputWasNotVerifiedFromServer: () {
        setState(() {
          showButton = false;
          showToast(message: 'Phone number already exists');
        });
      },
    );
  }

  Future<bool> _verifyPhoneNumber() async {
    setState(() => showButton = false);
    bool verified = false;
    await UserAuth()
        .canContinueRegistrationWithPhoneNumber(
            phoneNumber: phoneNumberController.text)
        .then((verifiedPhoneNumber) {
      if (verifiedPhoneNumber) {
        verified = true;
      } else {
        verified = false;
        setState(() => showButton = false);
      }
    }).catchError((e) {
      Navigator.pop(context);
      showToast(message: 'VERIFY PHONE NUMBER ERROR :- ${e.toString()}');
    });

    return verified;
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
    if (phoneNumberController.text.length >= 9) {
      showButton = true;
      setState(() {});
    } else {
      showButton = false;
      setState(() {});
    }
  }

  Widget getUserAgreeCheckBoxWidget() {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onChanged: (value) {
                      // if (mounted) {
                      //   setState(() {
                      //     isUserAgree = value;
                      //   });
                      // }
                    },
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
            AppLocalization.of(context)!.registerAccountUserAgreeTerm,
            style: TextStyle(color: blackFont, fontSize: 14),
          ))
        ],
      ),
      onTap: () {
        if (mounted) {
          isUserAgree = !isUserAgree;
          setState(() {});
        }
      },
    );
  }

  Widget continueBtn() {
    return showButton
        ? CurvedButton(
            onPressed: submit,
            text: "Continue",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : Container(height: 42);
  }

  void submit() {
    var phoneNumberFromTextField = phoneNumberController.text.trim();

    if (isUserAgree == false) {
      return showToast(message: "Accept the Terms first");
    }

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

