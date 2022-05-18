import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';

import '../../../../../utils/util.dart';
import '../../../../../widget/LoadingIndicator.dart';
import '../../../../../widget/curved_btn.dart';
import '../../payment_and_banking_auth.dart';
import 'models/credit_card_data_model.dart';

// ignore: must_be_immutable
class EnterAddressOrPinPinPage extends StatefulWidget {
  bool isAddress; // To check if user will enter and address for verification;
  bool isWalletFunding;
  final CreditCardData? creditCardData;
  EnterAddressOrPinPinPage(
      {Key? key,
      this.isWalletFunding = false,
      this.isAddress = false,
      this.creditCardData})
      : super(key: key);

  @override
  State<EnterAddressOrPinPinPage> createState() =>
      _EnterAddressOrPinPinPageState();
}

class _EnterAddressOrPinPinPageState extends State<EnterAddressOrPinPinPage> {
  TextEditingController? pinController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !widget.isAddress ? enterPinTitle() : enterAddressTitle(),
                    flexibleSpace(flex: 1),
                    !widget.isAddress
                        ? enterPinDescription()
                        : enterAddressDescription(),
                    flexibleSpace(flex: 3),
                    !widget.isAddress
                        ? pinFillUpField()
                        : CustomizedTextFormField(
                            hintText: 'Enter your address',
                          ),
                    flexibleSpace(flex: 2),
                    submitBtn(),
                    flexibleSpace(flex: 1),
                  ],
                ),
              ),
            ),
            flexibleSpace(flex: 4),
          ],
        ),
      ),
    );
  }

  void submitCreditCard() {
    late CreditCardData creditCardData;
    if (formKey.currentState!.validate()) {
      String enteredPin = pinController!.text.trim();
      creditCardData = widget.creditCardData!.copyWith(pin: enteredPin);

      showDialog(context: context, builder: (context) => LoadingIndicator());

      print('CREDIT CARD :::: ${creditCardData.toJson()}');
      if (widget.isWalletFunding) {
        PaymentAndBankingAuth().fundWallet(creditCardData).then(
          (walletFunded) {
            Navigator.pop(context);
            _processResponse(walletFunded);
          },
        ).catchError(
          (e) {
            Navigator.pop(context);
            showToast(message: e.toString());
          },
        );
      } else {
        PaymentAndBankingAuth().addCreditCard(creditCardData).then(
          (cardDetailsSubmitted) {
            Navigator.pop(context);
            _processResponse(cardDetailsSubmitted);
          },
        ).catchError(
          (e) {
            Navigator.pop(context);
            showToast(message: e.toString());
          },
        );
      }
    } else {
      showToast(message: 'Enter a valid pin');
    }
  }

  _processResponse(String response) {
    switch (response) {
      case 'otp':
        Navigator.of(context).popAndPushNamed('/verify-registration-otp',
            arguments: {"isWalletFunding": widget.isWalletFunding});
        return;
      case 'address':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return EnterAddressOrPinPinPage(isAddress: true);
            },
          ),
        );
        return;
      case 'invalid pin':
        showToast(message: 'Invalid pin');
        return;
      case 'insufficient funds':
        Navigator.pop(context);
        showToast(message: 'You do not have sufficient funds');
        return;
      case 'too many connections':
        Navigator.pop(context);
        showToast(message: 'Server error. Please try again');
        return;
      default:
        showToast(message: response);
        return;
    }
  }

  Widget submitBtn() {
    return CurvedButton(
      text: "Submit",
      textColor: Colors.white,
      backgroundColor: navyBlue,
      onPressed: submitCreditCard,
    );
  }

  Widget pinFillUpField() {
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
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 28),
        child: PinPut(
          eachFieldWidth: 40,
          eachFieldHeight: 45,
          fieldsCount: 4,
          obscureText: '●',
          controller: pinController,
          submittedFieldDecoration: navyBlueBorder,
          selectedFieldDecoration: grayBorder,
          followingFieldDecoration: grayBorder,
          pinAnimationType: PinAnimationType.scale,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textStyle: TextStyle(
              color: blackFont, fontSize: 32, fontWeight: FontWeight.w600),
          validator: (val) {
            if (val!.length != 4) {
              return "Please enter a valid pin";
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget enterPinTitle() {
    return Container(
      child: Text(
        "Enter Pin",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget enterAddressTitle() {
    return Container(
      child: Text(
        "Enter address",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
      ),
    );
  }

  Widget enterPinDescription() {
    return Container(
      child: Text(
        "Enter your pin below",
        style: TextStyle(fontSize: 14, color: darkGrey),
      ),
    );
  }

  Widget enterAddressDescription() {
    return Container(
      child: Text(
        "Enter your address below",
        style: TextStyle(fontSize: 14, color: darkGrey),
      ),
    );
  }
}
