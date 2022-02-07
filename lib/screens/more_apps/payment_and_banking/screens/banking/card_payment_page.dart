import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/colors.dart';

class CardPaymentPage extends StatefulWidget {
  dynamic argument;
  CardPaymentPage({this.argument = false});

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
  bool securelySaveCardChecked = false;

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

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: cardPaymentPageKey,
        backgroundColor: Colors.white,
        appBar: customAppBar(
          context: context,
          title: widget.argument
              ? AppLocalization.of(context)!.walletFunding
              : AppLocalization.of(context)!.addCreditCard,
        ) as PreferredSizeWidget?,
        body: SingleChildScrollView(child: creditCardForm()),
      ),
    );
  }

  Widget creditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused,
          onCreditCardWidgetChange: (creditCardBrand) {},
          cardBgColor: navyBlue,
        ),
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            AppLocalization.of(context)!.slydoPayAccepts,
            style: TextStyle(color: Color(0XFF75818f)),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/visa_icon.png',
              ),
              SizedBox(width: 10),
              Image.asset('assets/images/mastercard_icon.png'),
            ],
          ),
        ),
        Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: boxShadow,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: CustomizedTextFormField(
              controller: _amountController,
              isAmount: true,
              labelText: "Amount",
              onChanged: (val) {
                setState(() {
                  amount = int.parse(val);
                });
              },
              validator: (val) {
                try {
                  int.parse(val!);
                } catch (e) {
                  return AppLocalization.of(context)!.invalidAmount;
                }
                return null;
              },
            ),
          ),
        ),
        Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: boxShadow,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  CustomizedTextFormField(
                    controller: _cardNumberController,
                    hintText: 'xxxx xxxx xxxx xxxx',
                    labelText: AppLocalization.of(context)!.cardNumber,
                    onChanged: (val) {
                      setState(() {
                        cardNumber = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomizedTextFormField(
                            controller: _expiryDateController,
                            hintText: 'MM/YY',
                            labelText: "Expiry date",
                            onChanged: (val) {
                              setState(() {
                                expiryDate = val;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: CustomizedTextFormField(
                            controller: _cvvCodeController,
                            focusNode: cvvFocusNode,
                            hintText: '123',
                            labelText: "CVV",
                            onChanged: (val) {
                              setState(() {
                                cvvCode = val;
                              });
                            }),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  //   child: TextFormField(
                  //     controller: _cardNumberController,
                  //     cursorColor: navyBlue,
                  //     style: TextStyle(
                  //       color: navyBlue,
                  //     ),
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.white)),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(color: navyBlue, width: 1.3),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: navyBlue)),
                  //       hintStyle: TextStyle(color: navyBlue),
                  //       labelStyle: TextStyle(color: navyBlue),
                  //       labelText: AppLocalization.of(context)!.cardNumber,
                  //       hintText: 'xxxx xxxx xxxx xxxx',
                  //     ),
                  //     keyboardType: TextInputType.number,
                  //     textInputAction: TextInputAction.next,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         cardNumber = val;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  //   child: TextFormField(
                  //     controller: _expiryDateController,
                  //     cursorColor: navyBlue,
                  //     style: TextStyle(
                  //       color: navyBlue,
                  //     ),
                  //     decoration: InputDecoration(
                  //         border: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.white)),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: navyBlue, width: 1.3),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: navyBlue)),
                  //         hintStyle: TextStyle(color: navyBlue),
                  //         labelStyle: TextStyle(color: navyBlue),
                  //         labelText: AppLocalization.of(context)!.expiredDate,
                  //         hintText: 'MM/YY'),
                  //     keyboardType: TextInputType.number,
                  //     textInputAction: TextInputAction.next,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         expiryDate = val;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  //   child: TextField(
                  //     focusNode: cvvFocusNode,
                  //     controller: _cvvCodeController,
                  //     cursorColor: navyBlue,
                  //     style: TextStyle(
                  //       color: navyBlue,
                  //     ),
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.white)),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(color: navyBlue, width: 1.3),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: navyBlue)),
                  //       hintStyle: TextStyle(color: navyBlue),
                  //       labelStyle: TextStyle(color: navyBlue),
                  //       labelText: AppLocalization.of(context)!.cvv,
                  //       hintText: 'XXXX',
                  //     ),
                  //     keyboardType: TextInputType.number,
                  //     textInputAction: TextInputAction.done,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         cvvCode = val;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  //   child: TextFormField(
                  //     controller: _cardHolderNameController,
                  //     cursorColor: navyBlue,
                  //     style: TextStyle(
                  //       color: navyBlue,
                  //     ),
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.white)),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(color: navyBlue, width: 1.3),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: navyBlue)),
                  //       hintStyle: TextStyle(color: navyBlue),
                  //       labelStyle: TextStyle(color: navyBlue),
                  //       labelText: AppLocalization.of(context)!.cardHolder,
                  //     ),
                  //     keyboardType: TextInputType.text,
                  //     textInputAction: TextInputAction.next,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         cardHolderName = val;
                  //       });
                  //     },
                  //   ),
                  // ),

                  CustomizedTextFormField(
                    controller: _amountController,
                    isAmount: true,
                    labelText: "Amount",
                    onChanged: (val) {
                      setState(() {
                        amount = int.parse(val);
                      });
                    },
                    validator: (val) {
                      try {
                        int.parse(val!);
                      } catch (e) {
                        return AppLocalization.of(context)!.invalidAmount;
                      }
                      return null;
                    },
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  //   child: TextFormField(
                  //     controller: _amountController,
                  //     cursorColor: navyBlue,
                  //     style: TextStyle(
                  //       color: navyBlue,
                  //     ),
                  //     decoration: InputDecoration(
                  //         border: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.white)),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: navyBlue, width: 1.3),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: navyBlue)),
                  //         hintStyle: TextStyle(color: navyBlue),
                  //         labelStyle: TextStyle(color: navyBlue),
                  //         labelText: AppLocalization.of(context)!.amount,
                  //         hintText: AppLocalization.of(context)!.enterAmount),
                  //     keyboardType: TextInputType.number,
                  //     textInputAction: TextInputAction.next,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         amount = int.parse(val);
                  //       });
                  //     },
                  //     validator: (val) {
                  //       try {
                  //         int.parse(val!);
                  //       } catch (e) {
                  //         return AppLocalization.of(context)!.invalidAmount;
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: securelySaveCardChecked,
                        onChanged: (isChecked) {
                          setState(() {
                            securelySaveCardChecked = isChecked!;
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      Text(AppLocalization.of(context)!.securelySaveCard),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        widget.argument
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalization.of(context)!.youWillGetAmount,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(SlydoAppIcon.naira, color: navyBlue),
                      SizedBox(width: 5),
                      Text(
                        '97',
                        style: TextStyle(
                            color: navyBlue,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              )
            : SizedBox.shrink(),
        SizedBox(height: 30),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CurvedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                sendPaymentData();
              } else {
                showToast(
                    message:
                        AppLocalization.of(context)!.invalidDetails + " !!");
              }
            },
            text: AppLocalization.of(context)!.topUp,
            textColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void sendPaymentData() {
    PaymentAndBankingAuth().topUpAccountByCC({"data": "data"}).then((value) {
      if (value == true) {
        showToast(
          message: AppLocalization.of(context)!.topUp +
              " " +
              AppLocalization.of(context)!.done,
        );
        Navigator.pop(context);
      } else {
        showToast(message: AppLocalization.of(context)!.somethingWentWrong);
      }
    });
  }

  @override
  void initState() {
    if (widget.argument == null) {
      widget.argument = false;
    }
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
