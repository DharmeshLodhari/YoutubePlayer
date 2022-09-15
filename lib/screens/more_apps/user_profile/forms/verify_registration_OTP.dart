import 'dart:async';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';

import '../../../../widget/LoadingIndicator.dart';
import '../../payment_and_banking/payment_and_banking_auth.dart';

// ignore: must_be_immutable
class VerifyRegistrationOTPScreen extends StatefulWidget {
  var arguments;

  VerifyRegistrationOTPScreen({this.arguments});

  @override
  _VerifyRegistrationOTPScreenState createState() =>
      _VerifyRegistrationOTPScreenState();
}

class _VerifyRegistrationOTPScreenState
    extends State<VerifyRegistrationOTPScreen> {
  int _timerCount = 30;

  String? phoneNumber = '';
  FocusNode? _pinPutFocusNode;
  TextEditingController? otpController;
  final _verifyOtpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    otpController = TextEditingController();
    if (widget.arguments['phoneNumber'] != null) {
      phoneNumber = widget.arguments['phoneNumber'];
    }
    _pinPutFocusNode = FocusNode();
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
                  flex: 6,
                  child: Form(
                    key: _verifyOtpFormKey,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          verifyOTPTitle(),
                          flexibleSpace(flex: 1),
                          expirationNote(),
                          flexibleSpace(flex: 3),
                          otpFillUpField(),
                          flexibleSpace(flex: 2),
                          verifyBtn(),
                          flexibleSpace(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
                flexibleSpace(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget verifyOTPTitle() {
    return Container(
      child: Text(
        "Verify OTP",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget expirationNote() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerCount != 0) {
        setState(() {
          _timerCount -= 1;
        });
      }
    });
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Please enter the code sent to your phone number.",
            style: TextStyle(fontSize: 14, color: darkGrey),
          ),
          Row(
            children: <Widget>[
              Text(
                "This code will expire in",
                style: TextStyle(fontSize: 14, color: darkGrey),
              ),
              Text(
                " 5 ",
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              Text(
                "minutes.",
                style: TextStyle(fontSize: 14, color: darkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget otpFillUpField() {
    BoxDecoration navyBlueBorder = BoxDecoration(
      border: Border(
          bottom: BorderSide(
        color: navyBlue,
        width: 2,
      )),
    );
    BoxDecoration grayBorder = BoxDecoration(
      border: Border(
          bottom: BorderSide(
        color: HexColor("#E6E5EB"),
        width: 2,
      )),
    );
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: whiteBackground)),
      shadowColor: whiteBackground,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 28),
        child: PinPut(
          eachFieldWidth: 40,
          eachFieldHeight: 45,
          fieldsCount: widget.arguments['isWalletFunding'] != null ? 5 : 6,
          focusNode: _pinPutFocusNode,
          controller: otpController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          submittedFieldDecoration: navyBlueBorder,
          selectedFieldDecoration: grayBorder,
          followingFieldDecoration: grayBorder,
          pinAnimationType: PinAnimationType.scale,
          textStyle: TextStyle(
              color: blackFont, fontSize: 32, fontWeight: FontWeight.w600),
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
      onPressed: widget.arguments['phoneNumber'] != null
          ? verifyOTP
          : verifyCreditCardOtp,
      text: "Verify",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  void verifyOTP() {
    if (_verifyOtpFormKey.currentState!.validate()) {
      String enteredOTP = otpController!.text.trim();
      String passwordToken = "false";
      showDialog(context: context, builder: (context) => LoadingIndicator());

      UserAuth()
          .verifyPhoneNumber(phoneNumber, enteredOTP, passwordToken)
          .then((verified) {
        Navigator.pop(context);

        debugPrint('Phone number verify -> $phoneNumber');

        Navigator.of(context).popAndPushNamed(Routes.SIGN_UP, arguments: {
          'phoneNumber': phoneNumber,
        });
      }).catchError((e) {
        Navigator.pop(context);
        showToast(message: 'ERROR -> ${e.toString()}');
      });
    }
  }

  void verifyCreditCardOtp() {
    if (_verifyOtpFormKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      PaymentAndBankingAuth().verifyCreditCardOtp(otpController!.text).then(
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

  _processVerifyCreditCardOtp(BuildContext context, String response) {
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
}

// class ExpirationNoteWidget extends StatefulWidget {
//   const ExpirationNoteWidget({Key? key}) : super(key: key);
//
//   @override
//   State<ExpirationNoteWidget> createState() => _ExpirationNoteWidgetState();
// }
//
// class _ExpirationNoteWidgetState extends State<ExpirationNoteWidget> {
//   @override
//   void initState() {
//     super.initState();
//     Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_timerCount != 0) {
//         setState(() {
//           _timerCount -= 1;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             "Please enter the code sent to your phone number.",
//             style: TextStyle(fontSize: 14, color: darkGrey),
//           ),
//           Row(
//             children: <Widget>[
//               Text(
//                 "This code will expire in",
//                 style: TextStyle(fontSize: 14, color: darkGrey),
//               ),
//               Text(
//                 " $_timerCount ",
//                 style: TextStyle(fontSize: 14, color: Colors.red),
//               ),
//               Text(
//                 "seconds.",
//                 style: TextStyle(fontSize: 14, color: darkGrey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
