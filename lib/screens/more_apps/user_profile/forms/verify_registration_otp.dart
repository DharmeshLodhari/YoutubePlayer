import 'dart:async';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../utils/country_picker/country.dart';

class VerifyRegistrationOTPScreen extends StatefulWidget {
  final dynamic arguments;

  const VerifyRegistrationOTPScreen({super.key, this.arguments});

  @override
  State<VerifyRegistrationOTPScreen> createState() =>
      _VerifyRegistrationOTPScreenState();
}

class _VerifyRegistrationOTPScreenState
    extends State<VerifyRegistrationOTPScreen> {
  String? phoneNumber = '';
  FocusNode? _pinPutFocusNode;
  TextEditingController? otpController;
  final _verifyOtpFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showResend = false;

  Timer? _timer;
  int _duration = 10 * 60; // 10 minutes in seconds
  bool _isRunning = false;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  TextEditingController phoneNumberController = TextEditingController();
  bool showButton = false;
  String phoneNumberWithCountryCode = "";

  @override
  void initState() {
    otpController = TextEditingController();
    if (widget.arguments['phoneNumber'] != null) {
      phoneNumber = widget.arguments['phoneNumber'];
    }
    _pinPutFocusNode = FocusNode();

    startTimer();

    super.initState();
  }

  void startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration > 0) {
          _duration--;
        } else {
          stopTimer();
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      showResend = true;
      _isRunning = false;
    });
  }

  void restartTimer() {
    stopTimer();
    setState(() {
      showResend = false;
      _duration = 10 * 60; // Reset duration to 10 minutes
    });
  }

  String getTimerText() {
    final int minutes = _duration ~/ 60;
    final int seconds = _duration % 60;
    final String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    final String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';
    return '$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
          return;
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
            width: MediaQuery.of(context).size.width,
            child: isLoading == true
                ? Center(child: CircularLoadingIndicator())
                : Column(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Form(
                          key: _verifyOtpFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              verifyOTPTitle(),
                              flexibleSpace(flex: 1),
                              expirationNote(),
                              flexibleSpace(flex: 3),
                              if (phoneNumber == null || phoneNumber == "") ...[
                                selectCountryField(),
                                const SizedBox(height: 12),
                                phoneNumberField(),
                                const SizedBox(height: 12),
                              ],
                              otpFillUpField(),
                              flexibleSpace(flex: 1),
                              if (phoneNumber != null) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: resendOtp(),
                                ),
                              ],
                              flexibleSpace(flex: 2),
                              verifyBtn(),
                              flexibleSpace(flex: 1),
                            ],
                          ),
                        ),
                      ),
                      flexibleSpace(flex: 3),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget verifyOTPTitle() {
    return Text(
      "Verify OTP",
      style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
    );
  }

  Widget expirationNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Please enter the code sent to your phone number.",
          style: TextStyle(fontSize: 14, color: darkGrey),
        ),
        if (phoneNumber != null) ...[
          Row(
            children: <Widget>[
              Text(
                "This code will expire in ",
                style: TextStyle(fontSize: 14, color: darkGrey),
              ),
              Text(
                getTimerText(),
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              Text(
                " minutes.",
                style: TextStyle(fontSize: 14, color: darkGrey),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget resendOtp() {
    return GestureDetector(
      onTap: () {
        showResend == false ? null : reSendOtpCode();
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: showResend == true ? navyBlue : greySecondaryYarn,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: const Text('Resend OTP',
            style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget otpFillUpField() {
    final defaultPinTheme = PinTheme(
      height: 44,
      width: 44,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      textStyle: TextStyle(
        fontSize: 35,
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );

    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: whiteBackground)),
      shadowColor: whiteBackground,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Pinput(
          length: widget.arguments['isWalletFunding'] != null ? 5 : 6,
          focusNode: _pinPutFocusNode,
          controller: otpController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          showCursor: false,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: HexColor("#E6E5EB"),
                    width: 2), // Underline with different color when focused
              ),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: navyBlue,
                    width: 2), // Underline with different color when focused
              ),
            ),
          ),
          followingPinTheme: defaultPinTheme.copyWith(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: HexColor("#E6E5EB"),
                    width: 2), // Underline with different color when focused
              ),
            ),
          ),
          validator: (val) {
            if (widget.arguments['isWalletFunding'] != null) {
              if (val!.length != 5) {
                return "Please enter code that sent to you";
              }
            } else {
              if (val!.length != 6) {
                return "Please enter code that sent to you";
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget verifyBtn() {
    return CurvedButton(
      onPressed: verifyOTP,
      // onPressed: widget.arguments['phoneNumber'] != null
      //     ? verifyOTP
      //     : verifyCreditCardOtp,
      text: "Verify",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  Future<void> verifyOTP() async {
    if (phoneNumber == null || phoneNumber == "") {
      var phoneNumberFromTextField = phoneNumberController.text.trim();

      if (phoneNumberController.text.trim().length <= 9) {
        showToast(message: AppLocalization.of(context)!.invalidPhoneNumber);
        return;
      }

      if (phoneNumberFromTextField.substring(0, 1) == "0") {
        phoneNumberFromTextField =
            phoneNumberFromTextField.replaceFirst("0", "");
      }

      //adding country code and '+' sign to phoneNumber
      phoneNumberWithCountryCode =
          "+${_selectedDialogCountry.phoneCode!}$phoneNumberFromTextField";

      phoneNumber = phoneNumberWithCountryCode;
    }

    debugPrint('Phone number fola -> $phoneNumberWithCountryCode');

    if (_verifyOtpFormKey.currentState!.validate()) {
      final String enteredOTP = otpController!.text.trim();
      const String passwordToken = "false";
      showDialog(context: context, builder: (context) => LoadingIndicator());

      await UserAuth()
          .verifyPhoneNumber(phoneNumber, enteredOTP, passwordToken)
          .then((verified) {
        Navigator.pop(context);

        debugPrint('Phone number verify -> $phoneNumber');

        // Navigator.of(context).popAndPushNamed(Routes.SIGN_UP, arguments: {
        //   'phoneNumber': phoneNumber,
        // });
        Navigator.of(context).popAndPushNamed(Routes.ACCOUNT_TYPE,
            arguments: {'phoneNumber': phoneNumber, 'otpCode': enteredOTP});
      }).catchError((e) {
        Navigator.pop(context);
        showToast(message: 'ERROR -> ${e.toString()}');
      });
    }
  }

  Future<void> verifyCreditCardOtp() async {
    if (_verifyOtpFormKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      await PaymentAndBankingAuth()
          .verifyCreditCardOtp(otpController!.text)
          .then(
        (cardVerifiedResponse) {
          _processVerifyCreditCardOtp(context, cardVerifiedResponse);
        },
      ).catchError(
        (e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        },
      );
    } else {
      showToast(message: 'Enter a valid otp');
    }
  }

  void _processVerifyCreditCardOtp(BuildContext context, String response) {
    Navigator.pop(context); // pop loading indicator;

    switch (response) {
      case 'successful':
        Navigator.pop(context); // pop this page;
        Navigator.pop(context); // pop card_payment_page;
        Navigator.pop(context); // pop credit_card_list;
        if (widget.arguments['isWalletFunding'] == true) {
          showToast(message: 'Wallet Funded successfully');
        } else {
          Navigator.pushNamed(context,
              Routes.CREDIT_CARD_LIST); //To reload credit-card-list page.
        }
        break;
      case 'invalid otp':
        showToast(message: 'Please enter a valid otp');
        break;
      case 'session expired':
        Navigator.pop(context); // pop this page;
        showToast(message: 'Session expired, please try again.');

        break;
      case 'insufficient funds':
        Navigator.pop(context); // pop this page;
        showToast(message: 'You do not have sufficient funds');

        break;
      default:
        Navigator.pop(context); // pop this page;
        showToast(message: response);
        break;
    }
  }

  void reSendOtpCode() {
    UserAuth().registerPhoneNumber(phoneNumber!).then((value) {
      // Navigator.of(context).pop();
      Future.delayed(const Duration(seconds: 2), () {
        startTimer();
        showResend = false;
        showToast(message: "OTP resent to $phoneNumber");
      });
    }).catchError((error) {
      showToast(message: "$error");
    });
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
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validatePhoneNumber,
      onChanged: (value) {
        if (value.isEmpty || value.length < 10) {
          setState(() {
            showButton = false;
          });
        }
      },
      // whenToVerifyInputFromServer: (value) => value.length >= 10,
      // verifyInputFromServerFunc: () => true,
      // extraFunctionWhenInputWasVerifiedFromServerSuccessfully: () {
      //   if (phoneNumberController.text.length >= 10) {
      //     setState(() {
      //       showButton = true;
      //     });
      //   }
      // },
      // extraFunctionWhenInputWasNotVerifiedFromServer: () {
      //   setState(() {
      //     showButton = false;
      //     showToast(message: 'Phone number already exists');
      //   });
      // },
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

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.selectYourCountry,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
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
            titlePadding: const EdgeInsets.all(8.0),
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
        const SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ),
        const SizedBox(width: 8.0),
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
