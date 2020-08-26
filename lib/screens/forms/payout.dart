import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class Payout extends StatefulWidget {
  @override
  _PayoutState createState() => _PayoutState();
}

class _PayoutState extends State<Payout> {
  http.Response response;

  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;

  int amount;
  String errorMessage = "";
  int accountBalance = 0;

  @override
  void initState() {
    getAccountBalance();
    super.initState();
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
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            title: Center(child: Text(AppLocalization.of(context).payout)),
            backgroundColor: darkBlue()),
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    displayBalance(),
                    SizedBox(height: 10),
                    getUserBankAccount(),
                    SizedBox(height: 15),
                    displayAmountField(),
                    SizedBox(height: 15),
                    noteForUser(),
                    SizedBox(height: 15),
                    accountBalance <= 0 ? Container() : getSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    //
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
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: ListTile(
        title: Text(
          bankAccountBloc.bankAccount.bankName,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text('******' +
            bankAccountBloc.bankAccount.accountNumber
                .toString()
                .substring(5, 9)),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: bankAccountBloc.bankAccount.bankAvatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) =>
                bankAccountBloc.bankAccount.bankAvatar == ""
                    ? Icon(Icons.account_balance)
                    : CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: lightBlue(),
                      ),
          ),
        ),
      ),
    );
  }

  Widget displayAmountField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        cursorColor: darkBlue(),
        autofocus: false,
        obscureText: false,
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Container(
              width: 20,
              child: Center(
                child: Text(
                  worldCurrencies[userBloc.user.currency],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600]),
                ),
              ),
            ),
            hintText: AppLocalization.of(context).enterAmount,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide(
                    width: 1, color: Colors.white, style: BorderStyle.solid))),
        validator: (val) {
          if (val.isNotEmpty) {
            try {
              int.parse(val);
              return null;
            } catch (e) {}
          }
          return AppLocalization.of(context).invalidAmount;
        },
        onChanged: (val) {
          if (mounted) {
            setState(() {
              amount = int.parse(val);
            });
          }
        },
      ),
    );
  }

  Widget getSubmitButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: ButtonTheme(
        minWidth: double.infinity,
        child: MaterialButton(
            elevation: 4.0,
            textColor: Colors.white,
            color: darkBlue(),
            height: 50,
            child: Text(AppLocalization.of(context).submitButton),
            onPressed: () async {
              //for closing the keypad if it is open
              FocusScope.of(context).unfocus();

              if (_formKey.currentState.validate()) {
                try {
                  var data = {
                    "amount": amount,
                    "currency": userBloc.user.currency,
                  };
                  PassCodePopup(
                      context: context,
                      isValidCallback: () {
                        showDialog(
                            context: context,
                            builder: (context) => Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                  backgroundColor: lightBlue(),
                                )));

                        _auth.accountPayout(data).then((value) {
                          response = value;
                          if (response.statusCode == 201) {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .popAndPushNamed('/payout-list');
                          } else if (response.statusCode == 500) {
                            Navigator.pop(context);
                            if (mounted) {
                              setState(() {
                                errorMessage =
                                    AppLocalization.of(context).serverError;
                                Toast.show(errorMessage, context,
                                    gravity: Toast.TOP,
                                    backgroundColor: darkBlue(),
                                    textColor: Colors.white);
                              });
                            }
                          } else if (response.statusCode == 700) {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/bvn-verification");
                          } else if (response.statusCode == 800) {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/add-document");
                          } else {
                            Navigator.pop(context);
                            if (mounted) {
                              setState(() {
                                errorMessage = AppLocalization.of(context)
                                    .somethingWentWrong;
                                Toast.show(errorMessage, context,
                                    gravity: Toast.TOP,
                                    backgroundColor: darkBlue(),
                                    textColor: Colors.white);
                              });
                            }
                          }
                        });
                      },
                      cancelCallBack: () {
                        Navigator.pop(context);
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content:
                              Text(AppLocalization.of(context).invalidPassword),
                        ));
                      });
                } catch (e) {
                  print(e);
                  Toast.show(e, context,
                      gravity: Toast.BOTTOM, backgroundColor: darkBlue());
                }
              }
            }),
      ),
    );
  }

  Widget displayBalance() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[],
      ),
    );
  }

  Widget noteForUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        AppLocalization.of(context).noteForUser,
        style: TextStyle(
            fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> getAccountBalance() async {
    await _auth.getAccountBalance().then((value) {
      var data = value;
      var spendableBalance = data["spendable_balance"];
      if (mounted) {
        setState(() {
          accountBalance = spendableBalance;
        });
      }
    });
  }
}
