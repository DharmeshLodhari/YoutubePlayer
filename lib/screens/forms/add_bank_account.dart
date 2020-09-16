import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/bank.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
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
  UserBloc userBloc;
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
        appBar: appBar(),
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
    // return SingleChildScrollView(
    //   scrollDirection: Axis.vertical,
    //   child: Form(
    //     key: _formKey,
    //     child: Container(
    //       color: lightBlue(),
    //       padding: EdgeInsets.symmetric(horizontal: 24),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.max,
    //         children: <Widget>[
    //           SizedBox(height: 20),
    //           Text(
    //             AppLocalization.of(context).bankAccountTerms,
    //             style: TextStyle(
    //               color: Colors.white,
    //             ),
    //           ),
    //           SizedBox(height: 20),
    //           getBankNameDropDownMenu(),
    //           SizedBox(height: 10),
    //           getAccountName(),
    //           SizedBox(height: 10),
    //           getAccountNumber(),
    //           SizedBox(height: 20),
    //           Text(
    //             AppLocalization.of(context).setDefaultAccountMsg,
    //             style: TextStyle(color: Colors.white),
    //           ),
    //           checkButton(),
    //           SizedBox(height: 10),
    //           errorMessage != ""
    //               ? Text(
    //                   errorMessage,
    //                   style: TextStyle(color: Colors.red),
    //                 )
    //               : Container(),
    //           getUserAgreeCheckBoxWidget(),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           isUserAgree
    //               ? getSubmitButton(userBloc.user.userName)
    //               : Container(),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      flexibleSpace(),
                      Text(
                        AppLocalization.of(context).bankAccountTerms,
                        style: TextStyle(color: darkGrey, fontSize: 14),
                      ),
                      flexibleSpace(flex: 2),
                      getBankNameDropDownMenu(),
                      flexibleSpace(),
                      getAccountName(),
                      flexibleSpace(),
                      getAccountNumber(),
                      flexibleSpace(),
                      checkButton(),
                      flexibleSpace(),
                      errorMessage != ""
                          ? Text(
                              errorMessage,
                              style: TextStyle(color: mateRad, fontSize: 14),
                            )
                          : Container(),
                      getUserAgreeCheckBoxWidget(),
                      flexibleSpace(flex: 2),
                      isUserAgree
                          ? getSubmitButton(userBloc.user.userName)
                          : Container(
                              height: 42,
                            ),
                    ],
                  ),
                ),
              ),
            ),
            flexibleSpace(flex: 2)
          ],
        ),
      ),
    );
  }

  Widget getBankNameDropDownMenu() {
    // return DropdownButtonFormField(
    //   isExpanded: true,
    //   decoration: InputDecoration(
    //     isDense: true,
    //     fillColor: Colors.white,
    //     filled: true,
    //     border: OutlineInputBorder(
    //       borderRadius: BorderRadius.all(Radius.circular(4)),
    //       borderSide: BorderSide(
    //           width: 1, color: Colors.white, style: BorderStyle.solid),
    //     ),
    //   ),
    //   value: bankName,
    //   icon: Flexible(
    //     child: Icon(
    //       Icons.keyboard_arrow_down,
    //     ),
    //     fit: FlexFit.loose,
    //   ),
    //   iconSize: 24,
    //   elevation: 16,
    //   style: TextStyle(color: Colors.black),
    //   onChanged: (String val) {
    //     if (mounted) {
    //       setState(() {
    //         bankName = val.trim();
    //       });
    //     }
    //   },
    //   items: banks.map((bank) {
    //     return DropdownMenuItem(
    //       value: bank.slug.trim(),
    //       child: Text(
    //         bank.name,
    //         style: TextStyle(color: darkBlue(), fontSize: 18),
    //       ),
    //     );
    //   }).toList(),
    // );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).bank,
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
              child: Text(AppLocalization.of(context).bank),
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
    // return TextFormField(
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.text,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.person),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).accountNameHint,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) => val.length < 5
    //       ? AppLocalization.of(context).validationTextMessage
    //       : null,
    //   onChanged: (val) {
    //     if (mounted) {
    //       setState(() {
    //         accountName = val;
    //       });
    //     }
    //   },
    // );
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).accountNameHint,
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
    // return TextFormField(
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.number,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.format_list_numbered),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).accountNumber,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) => val.length < 10
    //       ? AppLocalization.of(context).validationTextMessage1
    //       : null,
    //   onChanged: (val) {
    //     if (mounted) {
    //       setState(() {
    //         accountNumber = val;
    //       });
    //     }
    //   },
    // );

    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).accountNumber,
      keyboardType: TextInputType.number,
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
    // return Switch(
    //   value: isDefault,
    //   onChanged: (value) {
    //     if (mounted) {
    //       setState(() {
    //         isDefault = value;
    //       });
    //     }
    //   },
    //   activeTrackColor: darkBlue(),
    //   activeColor: darkBlue(),
    // );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalization.of(context).setDefaultAccountMsg,
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

  Widget getSubmitButton(String userName) {
    // return ButtonTheme(
    //   //color: Colors.green,
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //     onPressed: () {
    //       onSubmit(userName);
    //     },
    //     textColor: Colors.white,
    //     color: darkBlue(),
    //     height: 50,
    //     child: Text(AppLocalization.of(context).submitButton),
    //   ),
    // );

    // return ButtonTheme(
    //   //color: Colors.green,
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //     onPressed: () {
    //       onSubmit(userName);
    //     },
    //     textColor: Colors.white,
    //     color: darkBlue(),
    //     height: 50,
    //     child: Text(AppLocalization.of(context).submitButton),
    //   ),
    // );

    return CurvedButton(
      onPressed: () {
        onSubmit(userName);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context).submitButton,
    );
  }

  void onSubmit(String userName) async {
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
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
  }

  Widget getUserAgreeCheckBoxWidget() {
    // return Row(
    //   mainAxisSize: MainAxisSize.min,
    //   children: <Widget>[
    //     Checkbox(
    //       value: isUserAgree,
    //       activeColor: darkBlue(),
    //       onChanged: (value) {
    //         if (mounted) {
    //           setState(() {
    //             isUserAgree = value;
    //           });
    //         }
    //       },
    //     ),
    //     Expanded(
    //         child: Text(
    //       AppLocalization.of(context).bankAccountUserAgreeTerm,
    //       style: TextStyle(
    //         color: Colors.white,
    //       ),
    //     ))
    //   ],
    // );
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
            AppLocalization.of(context).bankAccountUserAgreeTerm,
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
