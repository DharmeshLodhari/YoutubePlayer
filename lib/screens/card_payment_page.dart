import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:toast/toast.dart';

import '../utils/colors.dart';

class CardPaymentPage extends StatefulWidget {
  @override
  _CardPaymentPageState createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  GlobalKey<ScaffoldState> cardPaymentPageKey = GlobalKey<ScaffoldState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  int amount = 0;
  bool isCvvFocused = false;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _auth = AuthService();

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: cardPaymentPageKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Text(AppLocalization.of(context).cardPayment),
        ),
        body: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
            ),
            Expanded(
              child: SingleChildScrollView(child: creditCardForm()),
            )
          ],
        ),
      ),
    );
  }

  creditCardForm() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: TextFormField(
                    controller: _cardNumberController,
                    cursorColor: darkBlue(),
                    style: TextStyle(
                      color: darkBlue(),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: darkBlue(), width: 1.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkBlue())),
                      hintStyle: TextStyle(color: darkBlue()),
                      labelStyle: TextStyle(color: darkBlue()),
                      labelText: AppLocalization.of(context).cardNumber,
                      hintText: 'xxxx xxxx xxxx xxxx',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        cardNumber = val;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: TextFormField(
                    controller: _expiryDateController,
                    cursorColor: darkBlue(),
                    style: TextStyle(
                      color: darkBlue(),
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkBlue(), width: 1.3),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: darkBlue())),
                        hintStyle: TextStyle(color: darkBlue()),
                        labelStyle: TextStyle(color: darkBlue()),
                        labelText: AppLocalization.of(context).expiredDate,
                        hintText: 'MM/YY'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        expiryDate = val;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: TextField(
                    focusNode: cvvFocusNode,
                    controller: _cvvCodeController,
                    cursorColor: darkBlue(),
                    style: TextStyle(
                      color: darkBlue(),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: darkBlue(), width: 1.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkBlue())),
                      hintStyle: TextStyle(color: darkBlue()),
                      labelStyle: TextStyle(color: darkBlue()),
                      labelText: AppLocalization.of(context).cvv,
                      hintText: 'XXXX',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      setState(() {
                        cvvCode = val;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: TextFormField(
                    controller: _cardHolderNameController,
                    cursorColor: darkBlue(),
                    style: TextStyle(
                      color: darkBlue(),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: darkBlue(), width: 1.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkBlue())),
                      hintStyle: TextStyle(color: darkBlue()),
                      labelStyle: TextStyle(color: darkBlue()),
                      labelText: AppLocalization.of(context).cardHolder,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        cardHolderName = val;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: TextFormField(
                    controller: _amountController,
                    cursorColor: darkBlue(),
                    style: TextStyle(
                      color: darkBlue(),
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkBlue(), width: 1.3),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: darkBlue())),
                        hintStyle: TextStyle(color: darkBlue()),
                        labelStyle: TextStyle(color: darkBlue()),
                        labelText: AppLocalization.of(context).amount,
                        hintText: AppLocalization.of(context).enterAmount),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        amount = int.parse(val);
                      });
                    },
                    validator: (val) {
                      try {
                        int.parse(val);
                      } catch (e) {
                        return AppLocalization.of(context).invalidAmount;
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    color: darkBlue(),
                    child: Text(
                      AppLocalization.of(context).topUp,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        sendPaymentData();
                      } else {
                        Toast.show(
                            AppLocalization.of(context).invalidDetails + " !!",
                            context,
                            textColor: Colors.white,
                            backgroundColor: darkBlue());
                      }
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }

  void sendPaymentData() {
    _auth.topUpAccountByCC({"data": "data"}).then((value) {
      if (value == true) {
        Toast.show(
            AppLocalization.of(context).topUp +
                " " +
                AppLocalization.of(context).done,
            context,
            textColor: Colors.white,
            backgroundColor: darkBlue());
        Navigator.pop(context);
      } else {
        Toast.show(AppLocalization.of(context).somethingWentWrong, context,
            textColor: Colors.white, backgroundColor: darkBlue());
      }
    });
  }

  @override
  void initState() {
    cvvFocusNode.addListener(textFieldFocusDidChange);
    super.initState();
  }

  void textFieldFocusDidChange() {
    setState(() {
      isCvvFocused = cvvFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();
    _amountController.dispose();
    _cvvCodeController.dispose();
    cvvFocusNode.dispose();
    super.dispose();
  }
}
