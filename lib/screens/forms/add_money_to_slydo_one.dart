import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddMoneyToSlydoOne extends StatefulWidget {
  @override
  _AddMoneyToSlydoOneState createState() => _AddMoneyToSlydoOneState();
}

class _AddMoneyToSlydoOneState extends State<AddMoneyToSlydoOne> {
  http.Response response;

  final _auth = AuthService();
  final _formKeyTwo = GlobalKey<FormState>();

  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;

  String errorMessage = "";

  String amount = "0";

  String referenceNumber;

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
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Form(
                key: _formKeyTwo,
                child: Column(
                  children: <Widget>[
                    displayAmountField(),
                    flexibleSpace(),
                    amountUserGetMsg(),
                    flexibleSpace(),
                    amountUserGet(),
                    flexibleSpace(),
                    getReferenceButton(),
                    flexibleSpace(),
                    noteForUser(),
                    flexibleSpace(flex: 3),
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
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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
    );
  }

  Widget referenceIdFiled() {
    return CustomizedTextFormField(
      labelText: "Reference number",
      onChanged: (val) {
        referenceNumber = val.toString();
        setState(() {});
      },
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please add reference number";
      },
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

    if (_formKeyTwo.currentState.validate()) {
      try {
        Navigator.popAndPushNamed(context, "/add-money-to-slydo-two");
      } catch (e) {
        print(e);
        Toast.show(e, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
      }
    }
  }

  Widget noteForUser() {
    return Text(
      "You are about to transfer money into your Slydo wallet",
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Widget amountUserGetMsg() {
    return Text(
      "You will get following amount in your Slydo wallet",
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Widget amountUserGet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          SlydoAppIcon.naira,
          color: blackFont,
          size: 24,
        ),
        Text(
          " " +
              (double.parse(amount) - (double.parse(amount) * 0.03)).toString(),
          style: TextStyle(
              fontSize: 36, color: blackFont, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
