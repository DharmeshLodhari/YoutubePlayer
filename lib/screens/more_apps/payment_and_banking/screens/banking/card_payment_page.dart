import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/enter_address_or_pin_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/models/credit_card_data_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CardPaymentPage extends StatefulWidget {
  dynamic isWalletFunding;
  CardPaymentPage({super.key, this.isWalletFunding = false});

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  int amount = 0;
  int cappedFee = 2000;
  int calculatedFee = 0;
  late UserBloc userBloc;
  bool showButton = false;
  int amountLimit = 50000;
  bool isCvvFocused = false;
  bool showFinalAmount = false;
  int creditCardProcessingFee = 0;
  int waivedTransactionFeeLimit = 2500;
  int amountToDeductWhenAddingCard =
      500; // This is the amount that will be deducted when we are adding a user's credit card (this is N5 in kobo).
  double creditCardProcessingFeePercentage = 1.4;
  GlobalKey<ScaffoldState> cardPaymentPageKey = GlobalKey<ScaffoldState>();

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '000');

  bool? cardNumberVerified;
  FocusNode cvvFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    widget.isWalletFunding ??= false;
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

  Future<bool> _verifyCardNumber() async {
    bool verified = false;
    await PaymentAndBankingAuth()
        .verifyCardNumber(cardNumber: _cardNumberController.text.trim())
        .then((verifiedCardNumber) {
      if (verifiedCardNumber) {
        verified = true;
      } else {
        verified = false;
      }
    }).catchError((e) {
      Navigator.pop(context);
      showToast(message: 'EROOR - ${e.toString()}');
    });

    return verified;
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        key: cardPaymentPageKey,
        backgroundColor: Colors.white,
        appBar: customAppBar(
          context: context,
          title: widget.isWalletFunding
              ? AppLocalization.of(context)!.walletFunding
              : AppLocalization.of(context)!.addPaymentCard,
        ) as PreferredSizeWidget?,
        body: SingleChildScrollView(child: creditCardForm()),
      ),
    );
  }

  int calculateCreditCardFee(
      {required int amount, required double percentage}) {
    var finalFee;

    final percentageAmount = amount * (percentage / 100);

    // ₦100 fee waived for transactions under ₦2500.
    if (percentageAmount > waivedTransactionFeeLimit) {
      finalFee = percentageAmount.toInt();
    } else {
      finalFee = percentageAmount.toInt() + creditCardProcessingFee;
    }
    // Local transactions fees are capped at ₦2000, meaning that's the absolute maximum you'll ever pay in fees per transaction.

    if (finalFee > cappedFee) {
      finalFee = cappedFee;
    }

    return finalFee;
  }

  Widget creditCardForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CreditCardWidget(
          //   cardNumber: cardNumber,
          //   expiryDate: expiryDate,
          //   cardHolderName: cardHolderName,
          //   cvvCode: cvvCode,
          //   showBackView: isCvvFocused,
          //   onCreditCardWidgetChange: (creditCardBrand) {},
          //   cardBgColor: navyBlue,
          // ),
          // SizedBox(
          //   height: 16,
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              AppLocalization.of(context)!.slydoPayAccepts,
              style: const TextStyle(color: Color(0XFF75818f)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/visa_icon.png',
                ),
                const SizedBox(width: 10),
                Image.asset('assets/images/mastercard_icon.png'),
              ],
            ),
          ),
          if (widget.isWalletFunding)
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              shadowColor: boxShadow,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomizedTextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.phone,
                      controller: _amountController,
                      isAmountField: true,
                      labelText: AppLocalization.of(context)!.amount,
                      onChanged: (value) {
                        _amountFieldOnChanged(
                            value.replaceAll(',', '').replaceAll('.', ''));
                      },
                      validator: (val) {
                        try {
                          final double userAmount =
                              double.parse(val.replaceAll(',', ''));
                          if (userAmount > amountLimit) {
                            return 'You cannot fund more than $amountLimit';
                          }
                        } catch (e) {
                          return AppLocalization.of(context)!.invalidAmount;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'You cannot fund more than NGN50000',
                      style: TextStyle(color: Colors.black.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 5,
            shadowColor: boxShadow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: <Widget>[
                  CustomizedTextFormField(
                    controller: _cardNumberController,
                    hintText: 'xxxx xxxx xxxx xxxx',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.phone,
                    labelText: AppLocalization.of(context)!.cardNumber,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          showButton = false;
                        });
                      }
                    },
                    whenToVerifyInputFromServer: (value) =>
                        value.replaceAll(' ', '').length == 16,
                    verifyInputFromServerFunc: () => _verifyCardNumber(),
                    extraFunctionWhenInputWasVerifiedFromServerSuccessfully:
                        () {
                      setState(() {
                        if (amount <= amountLimit) {
                          showButton = true;
                        }
                      });
                    },
                    extraFunctionWhenInputWasNotVerifiedFromServer: () {
                      setState(() {
                        showButton = false;
                        showToast(message: 'Card not valid');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomizedTextFormField(
                    controller: _cardHolderNameController,
                    hintText: 'John Doe',
                    keyboardType: TextInputType.name,
                    labelText: AppLocalization.of(context)!.cardHolderName,
                    validator: (value) {
                      return value.toString().isEmpty
                          ? AppLocalization.of(context)!.fieldCannotBeEmpty
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomizedTextFormField(
                          controller: _expiryDateController,
                          hintText: 'MM/YY',
                          labelText: "Expiry date",
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            return _validateExpiryDate(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomizedTextFormField(
                            controller: _cvvCodeController,
                            focusNode: cvvFocusNode,
                            hintText: '123',
                            labelText: AppLocalization.of(context)!.cvv,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              try {
                                int.parse(value);
                              } catch (e) {
                                return AppLocalization.of(context)!
                                    .invalidFormat;
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalization.of(context)!.doesNotSaveUsersCard,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.isWalletFunding)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalization.of(context)!.youWillGetAmount,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (showFinalAmount)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getUserCurrencySymbol(context, fontSize: 30),
                      Text(
                        getUserFinalAmount(),
                        style: TextStyle(
                            fontSize: 32,
                            color: navyBlue,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                else
                  const SizedBox.shrink(),
              ],
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 30),
          if (showButton)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CurvedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    widget.isWalletFunding ? _fundWallet() : _addCreditCard();
                  } else {
                    showToast(
                        message:
                            "${AppLocalization.of(context)!.invalidDetails} !!");
                  }
                },
                text: AppLocalization.of(context)!.submit,
                textColor: Colors.white,
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String getUserFinalAmount() {
    return moneyDisplayNormalizer((amount - calculatedFee) * 100);
  }

  String formattedExpiryDate() {
    final String expiryYear = _expiryDateController.text.split('/').last;
    final String expiryMonth = _expiryDateController.text.split('/').first;

    final String formattedExpiryDate = '20$expiryYear-$expiryMonth-01';
    return formattedExpiryDate;
  }

  String getUsersEmail() {
    return '${userBloc.user.userName}@slydo.co';
  }

  void _addCreditCard() {
    final CreditCardData creditCardData = CreditCardData(
      email: getUsersEmail(),
      cvv: _cvvCodeController.text,
      expiryDate: formattedExpiryDate(),
      amount: amountToDeductWhenAddingCard,
      cardHolder: _cardHolderNameController.text,
      cardNumber: int.parse(_cardNumberController.text.replaceAll(' ', '')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EnterAddressOrPinPinPage(creditCardData: creditCardData);
        },
      ),
    );
  }

  void _fundWallet() {
    final int amount =
        int.parse(_amountController.text) * 100; // Convert naira to kobo.

    final CreditCardData creditCardData = CreditCardData(
      amount: amount,
      email: getUsersEmail(),
      cvv: _cvvCodeController.text,
      currency: userBloc.user.currency,
      expiryDate: formattedExpiryDate(),
      cardHolder: _cardHolderNameController.text,
      cardNumber: int.parse(_cardNumberController.text.replaceAll(' ', '')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EnterAddressOrPinPinPage(
              creditCardData: creditCardData, isWalletFunding: true);
        },
      ),
    );
  }

  String? _validateExpiryDate(value) {
    if (value.isNotEmpty) {
      final String yearInputted = value.split('/').last;
      final String monthInputted = value.split('/').first;
      final String currentYear = DateTime.now().year.toString();
      final String monthInDigit = DateTime.now().month.toString();
      //To get the last two digit of the year
      final String formattedYear =
          currentYear.substring(currentYear.toString().length - 2);

      if (int.parse(yearInputted) < int.parse(formattedYear)) {
        return AppLocalization.of(context)!.invalidDate;
      }
      if (int.parse(monthInputted) < 1 || int.parse(monthInputted) > 12) {
        return AppLocalization.of(context)!.invalidDate;
      }
      if (int.parse(yearInputted) <= int.parse(formattedYear) &&
          int.parse(monthInputted) < int.parse(monthInDigit)) {
        return AppLocalization.of(context)!.invalidDate;
      }
    } else {
      return AppLocalization.of(context)!.invalidDate;
    }

    return null;
  }

  void _amountFieldOnChanged(String value) {
    try {
      setState(() {
        amount = int.parse(value);
        calculatedFee = calculateCreditCardFee(
            amount: amount, percentage: creditCardProcessingFeePercentage);
        if (value.isNotEmpty && !(amount > amountLimit)) {
          showFinalAmount = true;
        } else {
          showFinalAmount = false;
        }

        if (!(amount > amountLimit) && cardNumberVerified == true) {
          showButton = true;
        } else {
          showButton = false;
        }
      });
    } catch (e) {
      setState(() {
        showFinalAmount = false;
      });
    }
  }
}
