import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/bank.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../locale/app_localization.dart';
import '../../payment_and_banking_auth.dart';

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _auth = PaymentAndBankingAuth();
  late UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  String bankName = 'first-bank-nigeria-limited';
  String accountName = "";
  String accountNumber = "";
  bool isDefault = false;
  List<Bank> banks = getBanks();
  bool isUserAgree = false;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

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
        "Add a bank account",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    AppLocalization.of(context)!.bankAccountTerms,
                    style: TextStyle(color: darkGrey, fontSize: 14),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  getBankNameDropDownMenu(),
                  SizedBox(
                    height: 20,
                  ),
                  getAccountName(),
                  SizedBox(
                    height: 20,
                  ),
                  getAccountNumber(),
                  SizedBox(
                    height: 20,
                  ),
                  checkButton(),
                  SizedBox(
                    height: 20,
                  ),
                  errorMessage != ""
                      ? Column(
                          children: [
                            Text(
                              errorMessage,
                              style: TextStyle(color: mateRed, fontSize: 14),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Container(),
                  getUserAgreeCheckBoxWidget(),
                  SizedBox(
                    height: 40,
                  ),
                  isUserAgree
                      ? getSubmitButton(userBloc.user.userName)
                      : Container(
                          height: 42,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBankNameDropDownMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)!.bank,
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
          child: DropdownButton<String>(
            isExpanded: true,
            value: bankName,
            icon: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
                size: 20,
              ),
            ),
            underline: Divider(
              color: Colors.transparent,
            ),
            hint: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(AppLocalization.of(context)!.bank),
            ),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black),
            onChanged: (String? val) {
              if (mounted) {
                setState(() {
                  bankName = val!.trim();
                });
              }
            },
            items: banks.map((bank) {
              return DropdownMenuItem(
                value: bank.slug.trim(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                  child: Text(
                    bank.name,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget getAccountName() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNameHint,
      validator: (val) => val.length < 5
          ? AppLocalization.of(context)!.validationTextMessage
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountName = val;
          });
        }
      },
    );
  }

  Widget getAccountNumber() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNumber,
      keyboardType: TextInputType.number,
      validator: (val) => val.length < 10
          ? AppLocalization.of(context)!.validationTextMessage1
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountNumber = val;
          });
        }
      },
    );
  }

  Widget checkButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalization.of(context)!.setDefaultAccountMsg,
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: isDefault,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                isDefault = value;
              });
            }
          },
          activeTrackColor: navyBlue,
          activeColor: Colors.white,
          inactiveTrackColor: dividerColor,
        ),
      ],
    );
  }

  Widget getSubmitButton(String? userName) {
    return CurvedButton(
      onPressed: () {
        onSubmit(userName);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context)!.submit,
    );
  }

  void onSubmit(String? userName) async {
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      Map data = {
        "customer_username": userName,
        "bank": bankName,
        "account_name": accountName,
        "account_number": accountNumber,
        "is_default": isDefault,
      };
      bool wasSuccessful = false;

      try {
        wasSuccessful = await _auth.addBankAccount(data);
      } catch (error) {}
      if (wasSuccessful) {
        BankAccount _bankAccount;
        await _auth.getBankAccounts().then((accounts) {
          try {
            _bankAccount = accounts[0];
            if (_bankAccount != null) {
              bankAccountBloc.bankAccount = _bankAccount;
            }
          } catch (e) {}
        });
        Navigator.pop(context);
        Navigator.of(context).popAndPushNamed('/bank-account-list');
      } else {
        if (mounted) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.errorMsg1;
          });
        }
      }
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
            AppLocalization.of(context)!.bankAccountUserAgreeTerm,
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
}
