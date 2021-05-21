import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:toast/toast.dart';

class ResetDevice extends StatefulWidget {
  @override
  _ResetDeviceState createState() => _ResetDeviceState();
}

class _ResetDeviceState extends State<ResetDevice> {
  bool isRemember = false;
  final _resetDevice = GlobalKey<FormState>();
  String phoneNumber = '';
  String password = '';

  TextEditingController phoneNumberController;
  TextEditingController passwordController;

  final FocusNode _pinPutFocusNode = FocusNode();

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  String selectedReason;

  List<String> resetDeviceReasons = ["Replacement", "Missing device", "Stolen"];

  bool isReasonIsSelected = false;

  bool isPhoneNumberIsVerified = false;

  String resetDeviceToken = "";

  @override
  void initState() {
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
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
            child: Column(
              children: <Widget>[
                Form(
                  key: _resetDevice,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        appIcon(),
                        SizedBox(height: 20),
                        titleText(),
                        SizedBox(height: 30),

                        // isReasonIsSelected ? getDeviceData() : Container()
                        getDeviceData()
                      ],
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

  Widget titleText() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Slydo",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Reset your Slydo device",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
          ),
        ],
      ),
    );
  }

  Widget getResetDeviceReason() {
    return CustomizedDropDownField(
      title: "Reason for reset device",
      child: ListTile(
        dense: true,
        title: Text(
          selectedReason ?? "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectReason();
        },
      ),
    );
  }

  void selectReason() async {
    final result = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: resetDeviceReasons.map<Widget>((data) {
                          if (selectedReason == data) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  data,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                onTap: () {
                                  Navigator.pop(context, data);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              data,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, data);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (result != null) {
      selectedReason = result;
      isReasonIsSelected = true;
      if (mounted) setState(() {});
    }
  }

  Widget getDeviceData() {
    return Column(
      children: [
        phoneNumberField(),
        isPhoneNumberIsVerified ? getPasswordField() : Container(),
        SizedBox(height: 20),
        getSubmitButton(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget getPasswordField() {
    return Column(
      children: [
        SizedBox(height: 10),
        passwordPinFiled(),
        SizedBox(height: 10),
        getResetDeviceReason(),
      ],
    );
  }

  Widget phoneNumberField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 3,
            child: IgnorePointer(
                ignoring: isPhoneNumberIsVerified,
                child: getCountryDropdown())),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 5,
          child: CustomizedTextFormField(
            enabled: !isPhoneNumberIsVerified,
            labelColor: darkGrey,
            keyboardType: TextInputType.phone,
            controller: phoneNumberController,
            validator: (val) {
              if (val.isNotEmpty && val.length >= 9) {
                return null;
              }
              return AppLocalization.of(context).invalidPhoneNumber;
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
            "(" + country.name + ")",
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
            titlePadding: EdgeInsets.all(8.0),
            isForLogin: isForLogin,
            searchCursorColor: navyBlue,
            searchInputDecoration: InputDecoration(
              hintText: AppLocalization.of(context).search,
              hintStyle: TextStyle(
                fontSize: 16,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            isSearchable: true,
            title: Text(
              AppLocalization.of(context).selectYourPhoneCode,
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
            "Password",
            style: TextStyle(fontSize: 14, color: darkGrey),
          ),
          SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val.length < 4
                ? AppLocalization.of(context).invalidPassword
                : null,
            fieldsCount: 6,
            focusNode: _pinPutFocusNode,
            controller: passwordController,
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

  Widget getSubmitButton() {
    return CurvedButton(
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: isPhoneNumberIsVerified ? "Reset device" : "Send OTP",
      onPressed: isPhoneNumberIsVerified ? resetDevice : sendOTP,
    );
  }

  void resetDevice() async {
    if (_resetDevice.currentState.validate()) {
      if (isReasonIsSelected) {
        showDialog(context: context, builder: (context) => LoadingIndicator());

        var phoneNumberFromTextField = phoneNumberController.text.trim();

        if (phoneNumberFromTextField.substring(0, 1) == "0") {
          phoneNumberFromTextField =
              phoneNumberFromTextField.replaceFirst("0", "");
        }

        phoneNumber =
            "+" + _selectedDialogCountry.phoneCode + phoneNumberFromTextField;
        password = passwordController.text.trim();

        var data = {};
        data["phone_number"] = phoneNumber;
        data["password"] = password;
        data["reason"] = selectedReason;
        data["reset_token"] = resetDeviceToken;

        UserAuth().resetDevice(data: data).then((result) {
          Navigator.pop(context);
          if (result != null) {
            if (result) {
              showAlertDialogForInformation();

              // Navigator.pop(context);

            }
          }
        }).catchError((error) {
          Navigator.pop(context);
          debugPrint("ERROR:- $error");
          Toast.show("$error", context,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              duration: Toast.LENGTH_LONG);
        });
      } else {
        Toast.show("Please select reset device reason !!", context,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG);
      }
    }
  }

  void sendOTP() async {
    if (_resetDevice.currentState.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      var phoneNumberFromTextField = phoneNumberController.text.trim();

      if (phoneNumberFromTextField.substring(0, 1) == "0") {
        phoneNumberFromTextField =
            phoneNumberFromTextField.replaceFirst("0", "");
      }

      phoneNumber =
          "+" + _selectedDialogCountry.phoneCode + phoneNumberFromTextField;

      UserAuth().sendOTPForResetDevice(phoneNumber).then((result) async {
        Navigator.pop(context);

        if (result != null) {
          String otp = result;

          var navigationResult = await Navigator.of(context).pushNamed(
              "/verify-reset-device-otp",
              arguments: {"phone_number": phoneNumber, "otp": otp});
          if (navigationResult != null) {
            if (navigationResult is Map) {
              resetDeviceToken = navigationResult["reset-token"];
              isPhoneNumberIsVerified = true;
              if (mounted) setState(() {});
            }
          }
        }
      }).catchError((error) {
        Navigator.pop(context);
        debugPrint("ERROR:- $error");
        Toast.show("$error", context,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG);
      });
    }
  }

  void showAlertDialogForInformation() async {
    var result = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, rentDurationStateSetter) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Stack(
            overflow: Overflow.visible,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Note",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Your device is reset successfully. You can log in back to your account after 24 hours.",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlatButton(
                                padding: EdgeInsets.zero,
                                child: Text("OK",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context, true);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 100) / 2,
                top: -30,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        color: navyBlue,
                        border: Border.all(color: dividerColor, width: 1.5),
                        borderRadius: BorderRadius.circular(60)),
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Image.asset(
                        "assets/images/appIcon/appIcon_foreground.png",
                        height: 100,
                        fit: BoxFit.fill,
                        scale: 0.5,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );

    if (result == null || result) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
