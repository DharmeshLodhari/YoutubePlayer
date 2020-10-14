import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
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
        AppLocalization.of(context).payout,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    getUserBankAccount(),
                    flexibleSpace(),
                    displayAmountField(),
                    flexibleSpace(),
                    noteForUser(),
                    flexibleSpace(),
                    accountBalance <= 0 ? Container() : getSubmitButton(),
                    flexibleSpace(flex: 2),
                  ],
                ),
              ),
            ),
            flexibleSpace()
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
            bankAccountBloc.bankAccount.bankName,
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            '******' +
                bankAccountBloc.bankAccount.accountNumber
                    .toString()
                    .substring(5, 9),
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          leading: CachedNetworkImage(
            imageUrl: bankAccountBloc.bankAccount.bankAvatar,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) =>
                bankAccountBloc.bankAccount.bankAvatar == ""
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
      keyboardType: TextInputType.number,
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
        return AppLocalization.of(context).invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context).submitButton,
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    // duration for close keyboard and open passcode bottomsheet
    await Future.delayed(Duration(milliseconds: 500));

    if (_formKey.currentState.validate()) {
      try {
        var data = {
          "amount": amount,
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
                      errorMessage = AppLocalization.of(context).serverError;
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
                      errorMessage =
                          AppLocalization.of(context).somethingWentWrong;
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
                content: Text(AppLocalization.of(context).invalidPassword),
              ));
            });
      } catch (e) {
        debugPrint(e);
        Toast.show(e, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
      }
    }
  }

  Widget noteForUser() {
    return Text(
      AppLocalization.of(context).noteForUser,
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
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
