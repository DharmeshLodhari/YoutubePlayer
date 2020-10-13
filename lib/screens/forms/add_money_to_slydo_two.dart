import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddMoneyToSlydoTwo extends StatefulWidget {
  @override
  _AddMoneyToSlydoTwoState createState() => _AddMoneyToSlydoTwoState();
}

class _AddMoneyToSlydoTwoState extends State<AddMoneyToSlydoTwo> {
  http.Response response;

  final _auth = AuthService();
  final _formKeyTwo = GlobalKey<FormState>();

  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;

  String errorMessage = "";

  String amount = "100";

  String referenceNumber;

  bool isChecked = false;

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
              flex: 3,
              child: Form(
                key: _formKeyTwo,
                child: Column(
                  children: <Widget>[
                    amountUserGetMsg(),
                    flexibleSpace(),
                    amountUserGet(),
                    flexibleSpace(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Please enter the reference number below while sending money.",
                          style: TextStyle(
                              fontSize: 12,
                              color: blackFont,
                              fontWeight: FontWeight.w600)),
                    ),
                    flexibleSpace(),
                    referenceIdFiled(),
                    flexibleSpace(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Please transfer the money to our account.",
                          style: TextStyle(
                              fontSize: 12,
                              color: blackFont,
                              fontWeight: FontWeight.w600)),
                    ),
                    flexibleSpace(),
                    getUserBankAccountSlydo(),
                    flexibleSpace(),
                    userTopUpNote(),
                    flexibleSpace(),
                    transferredMoneyCheck(),
                    flexibleSpace(),
                    isChecked ? getSubmitButton() : Container(),
                    flexibleSpace(),
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

  Widget getUserBankAccountSlydo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Bank name:",
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  Text(
                    " GT Bank",
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Account name:",
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  Text(
                    " Slydo Private Limited",
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                'Account number:',
                style: TextStyle(color: darkGrey, fontSize: 12),
              ),
              Text(
                ' 8562014859',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          leading: Image.asset(
            "assets/images/category/slydo.png",
            height: 48,
            width: 48,
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
    return Text(
      "abcdefgr7512",
      style: TextStyle(
          fontSize: 28, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Widget transferredMoneyCheck() {
    return GestureDetector(
      child: Row(
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
                    value: isChecked,
                    onChanged: (value) {
                      if (mounted) {
                        isChecked = value;
                        setState(() {});
                      }
                    },
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            "Have you transferred money?",
            style: TextStyle(color: blackFont, fontSize: 14),
          ),
        ],
      ),
      onTap: () {
        if (mounted) {
          if (isChecked) {
            isChecked = false;
          } else {
            isChecked = true;
          }
          setState(() {});
        }
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isChecked ? onSubmit : () {},
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Topup",
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    if (_formKeyTwo.currentState.validate()) {
      try {
        Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
      } catch (e) {
        print(e);
        Toast.show(e, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
      }
    }
  }

  Widget amountUserGetMsg() {
    return Text(
      "You will get following amount in your Slydo wallet",
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Widget userTopUpNote() {
    return Text(
      "Please press this button only after you have transfer the fund.",
      style:
          TextStyle(fontSize: 12, color: mateRad, fontWeight: FontWeight.w600),
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
