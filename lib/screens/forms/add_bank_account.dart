import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/bank.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../locale/app_localization.dart';

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _auth = AuthService();
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
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text(AppLocalization.of(context).addBankAccountMsg),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    AppLocalization.of(context).bankAccountTerms,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  getBankNameDropDownMenu(),
                  SizedBox(height: 10),
                  getAccountName(),
                  SizedBox(height: 10),
                  getAccountNumber(),
                  SizedBox(height: 20),
                  Text(
                    AppLocalization.of(context).setDefaultAccountMsg,
                    style: TextStyle(color: Colors.white),
                  ),
                  checkButton(),
                  SizedBox(height: 10),
                  errorMessage != ""
                      ? Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                  getUserAgreeCheckBoxWidget(),
                  SizedBox(
                    height: 10,
                  ),
                  isUserAgree
                      ? getSubmitButton(userBloc.user.userName)
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBankNameDropDownMenu() {
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
              width: 1, color: Colors.white, style: BorderStyle.solid),
        ),
      ),
      value: bankName,
      icon: Flexible(
        child: Icon(
          Icons.keyboard_arrow_down,
        ),
        fit: FlexFit.loose,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      onChanged: (String val) {
        if (mounted) {
          setState(() {
            bankName = val.trim();
          });
        }
      },
      items: banks.map((bank) {
        return DropdownMenuItem(
          value: bank.slug.trim(),
          child: Text(
            bank.name,
            style: TextStyle(color: darkBlue(), fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  Widget getAccountName() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).accountNameHint,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) => val.length < 5
          ? AppLocalization.of(context).validationTextMessage
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
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.format_list_numbered),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).accountNumber,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) => val.length < 10
          ? AppLocalization.of(context).validationTextMessage1
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
    return Switch(
      value: isDefault,
      onChanged: (value) {
        if (mounted) {
          setState(() {
            isDefault = value;
          });
        }
      },
      activeTrackColor: darkBlue(),
      activeColor: darkBlue(),
    );
  }

  Widget getSubmitButton(String userName) {
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    return ButtonTheme(
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            Map data = {
              "customer_username": userName,
              "bank": bankName,
              "account_name": accountName,
              "account_number": accountNumber,
              "is_default": isDefault,
            };
            bool wasSuccessful = await _auth.addBankAccount(data);
            if (wasSuccessful) {
              BankAccount _bankAccount;
              _auth.getBankAccounts().then((accounts) {
                try {
                  _bankAccount = accounts[0];
                  print(_bankAccount);
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
                  errorMessage = AppLocalization.of(context).errorMsg1;
                });
              }
            }
          } else {
            var msg = AppLocalization.of(context).errorMsg2;
            Toast.show(msg, context,
                gravity: Toast.BOTTOM,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).submitButton),
      ),
    );
  }

  Widget getUserAgreeCheckBoxWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          value: isUserAgree,
          activeColor: darkBlue(),
          onChanged: (value) {
            if (mounted) {
              setState(() {
                isUserAgree = value;
              });
            }
          },
        ),
        Expanded(
            child: Text(
          AppLocalization.of(context).bankAccountUserAgreeTerm,
          style: TextStyle(
            color: Colors.white,
          ),
        ))
      ],
    );
  }
}
