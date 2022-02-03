import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../payment_and_banking_auth.dart';

class PayoutScreen extends StatefulWidget {
  @override
  _PayoutScreenState createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();

  late UserBloc userBloc;
  late BankAccountBloc bankAccountBloc;

  int? amount;
  String errorMessage = "";
  int? accountBalance = 0;

  VirtualAccount? virtualAccount;
  bool isAccountFound = false;
  bool isLoading = false;

  @override
  void initState() {
    getBankAccountDetail();

    super.initState();
  }

  void getBankAccountDetail() async {
    isLoading = true;
    setState(() {});
    await getAccountBalance();
    virtualAccount = await DatabaseHelper().getVirtualAccount();
    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
    }
    if (virtualAccount != null) {
      isAccountFound = true;
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Cashout",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: Container(
              child: CircularLoadingIndicator(),
            ),
          )
        : SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  isAccountFound
                      ? Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              getUserBankAccount(),
                              SizedBox(
                                height: 20,
                              ),
                              displayAmountField(),
                              SizedBox(
                                height: 20,
                              ),
                              noteForUser(),
                              SizedBox(
                                height: 40,
                              ),
                              accountBalance! <= 0
                                  ? Container()
                                  : getSubmitButton(),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "Please add Bank Account for cashout.",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: blackFont,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                        ),
                ],
              ),
            ),
          );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getUserBankAccount() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: Text(
            bankAccountBloc.bankAccount!.bankName!,
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            getFormattedAccountNumber(
                accountNumber:
                    bankAccountBloc.bankAccount!.accountNumber.toString()),
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          leading: CachedNetworkImage(
            imageUrl: bankAccountBloc.bankAccount!.bankAvatar!,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
            placeholder: (context, url) =>
                bankAccountBloc.bankAccount!.bankAvatar == ""
                    ? Icon(Icons.account_balance)
                    : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmount: true,
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = int.parse(val);
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            int.parse(val);
            return null;
          } catch (e) {}
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context)!.submitButton,
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    // duration for close keyboard and open passcode bottomsheet
    await Future.delayed(Duration(milliseconds: 500));

    if (_formKey.currentState!.validate()) {
      debugPrint(
          "virtualAccount?.accountTier?.dailyCumulativeTransactionLimit! ${virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!}");
      if (amount! <=
          int.parse(
              virtualAccount?.accountTier?.dailyCumulativeTransactionLimit! ??
                  "0")) {
        try {
          var data = {
            "amount": moneyInputNormalizer(amount.toString()),
            "currency": userBloc.user.currency,
          };
          BottomSheetPassCode(
              context: context,
              isValidCallback: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        Center(child: CircularLoadingIndicator()));

                _auth.accountPayout(data).then((value) {
                  response = value;
                  if (response.statusCode == 201) {
                    Navigator.pop(context);
                    Navigator.of(context).popAndPushNamed('/payout-list');
                  } else if (response.statusCode == 500) {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        errorMessage = AppLocalization.of(context)!.serverError;
                        showToast(message: errorMessage);
                      });
                    }
                  }
                  // else if (response.statusCode == 800) {
                  //   Navigator.pop(context);
                  //   Navigator.pushNamed(context, "/add-document");
                  // }
                  else {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        errorMessage =
                            AppLocalization.of(context)!.somethingWentWrong;
                        showToast(message: errorMessage);
                      });
                    }
                  }
                });
              },
              cancelCallBack: () {
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalization.of(context)!.invalidPassword),
                ));
              });
        } catch (e) {
          debugPrint(e.toString());
          showToast(message: e.toString());
        }
      } else {
        showToast(
            message:
                "Please Upgrade your account tier to make bigger transactions.");
      }
    }
  }

  Widget noteForUser() {
    return Text(
      AppLocalization.of(context)!.noteForUser,
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Future<void> getAccountBalance() async {
    await _auth.getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      if (mounted) {
        setState(() {
          accountBalance = spendableBalance;
        });
      }
    });
  }
}
