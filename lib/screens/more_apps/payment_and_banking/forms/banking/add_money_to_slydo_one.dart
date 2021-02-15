import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../payment_and_banking_auth.dart';

class AddMoneyToSlydoOne extends StatefulWidget {
  @override
  _AddMoneyToSlydoOneState createState() => _AddMoneyToSlydoOneState();
}

class _AddMoneyToSlydoOneState extends State<AddMoneyToSlydoOne> {
  final _formKeyTwo = GlobalKey<FormState>();

  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;

  String errorMessage = "";

  String amount = "";

  @override
  void initState() {
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
      centerTitle: false,
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
        "Topup",
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
        child: Form(
          key: _formKeyTwo,
          child: Column(
            children: <Widget>[
              displayAmountField(),
              SizedBox(
                height: 60,
              ),
              amountUserGetMsg(),
              SizedBox(
                height: 20,
              ),
              amountUserGet(),
              SizedBox(
                height: 60,
              ),
              getReferenceButton(),
              SizedBox(
                height: 24,
              ),
              noteForUser(),
            ],
          ),
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: decorateBox(),
        child: CustomizedTextFormField(
          labelText: "Amount",
          isAmount: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onChanged: (val) {
            amount = val.toString();
            setState(() {});
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
        ),
      ),
    );
  }

  Widget getReferenceButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Get reference",
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    var data = {"amount": amount.toString(), "currency": "NGN"};

    showDialog(
        context: context,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    if (_formKeyTwo.currentState.validate()) {
      PaymentAndBankingAuth().topUpAccountByBank(data).then((value) {
        if (value != null) {
          Navigator.pop(context);
          var result = value;
          Navigator.popAndPushNamed(context, "/add-money-to-slydo-two",
              arguments: result);
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e);
        Toast.show(e, context, gravity: Toast.BOTTOM, textColor: Colors.white);
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget noteForUser() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        "You are about to transfer money into your Slydo wallet",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14,
            color: darkGrey,
            fontWeight: FontWeight.w400,
            height: 1.5),
      ),
    );
  }

  Widget amountUserGetMsg() {
    return Text(
      "You will get following amount in your Slydo wallet",
      style: TextStyle(
          fontSize: 14, color: blackFont, fontWeight: FontWeight.w400),
    );
  }

  Widget amountUserGet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          SlydoAppIcon.naira,
          color: navyBlue,
          size: 22,
        ),
        Text(
          " " + getFinalAmount(),
          style: TextStyle(
              fontSize: 36, color: navyBlue, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String getFinalAmount() {
    if (amount != "") {
      return amount;
    }
    // if (amount != "") {
    //   return (double.parse(amount) - (double.parse(amount) * 0.03)).toString();
    // }
    return "0.0";
  }
}
