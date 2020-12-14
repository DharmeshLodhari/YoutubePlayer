import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class AddMoneyToSlydoTwo extends StatefulWidget {
  var arguments;

  AddMoneyToSlydoTwo({this.arguments});

  @override
  _AddMoneyToSlydoTwoState createState() => _AddMoneyToSlydoTwoState();
}

class _AddMoneyToSlydoTwoState extends State<AddMoneyToSlydoTwo> {
  final _auth = AuthService();
  final _formKeyTwo = GlobalKey<FormState>();

  String errorMessage = "";

  String amount = "0";

  String referenceNumber = "";

  bool isChecked = false;

  @override
  void initState() {
    amount = widget.arguments["amount"];
    referenceNumber = widget.arguments["token"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Form(
          key: _formKeyTwo,
          child: Column(
            children: <Widget>[
              amountUserGetMsg(),
              SizedBox(
                height: 20,
              ),
              amountUserGet(),
              SizedBox(
                height: 28,
              ),
              referenceIdFiled(),
              SizedBox(
                height: 20,
              ),
              getUserBankAccountSlydo(),
              SizedBox(
                height: 24,
              ),
              userTopUpNote(),
              SizedBox(
                height: 16,
              ),
              transferredMoneyCheck(),
              SizedBox(
                height: 40,
              ),
              isChecked ? getSubmitButton() : Container(),
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

  Widget getUserBankAccountSlydo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Column(
          children: [
            ListTile(
              title: Text("Please transfer the money to our account",
                  style: TextStyle(
                      fontSize: 14,
                      color: blackFont,
                      fontWeight: FontWeight.w400)),
              leading: Image.asset(
                "assets/images/category/slydo.png",
                height: 36,
                width: 36,
              ),
            ),
            Divider(
              thickness: 1,
              color: dividerColor,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Bank name",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "GT Bank",
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Account name",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Slydo Private Limited",
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Account number',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '8562014859',
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget referenceIdFiled() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: decorateBox(),
        child: Column(
          children: [
            Text("Please enter the reference number below while sending money",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.w400,
                    height: 1.5)),
            SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: blackFont.withOpacity(0.05),
              ),
              child: Text(
                "abcdefgr7512",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: blackFont,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
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

    showDialog(
        context: context,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    if (_formKeyTwo.currentState.validate()) {
      var data = {"token": referenceNumber};
      PaymentAndBankingAuth()
          .confirmTopUpWithReferenceNumber(data)
          .then((value) {
        if (value) {
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e);
        Toast.show(e, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget amountUserGetMsg() {
    return Text(
      "You will get following amount in your Slydo wallet",
      style: TextStyle(
          fontSize: 14, color: blackFont, fontWeight: FontWeight.w400),
    );
  }

  Widget userTopUpNote() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Please check the box below only after you transferred",
        style: TextStyle(
            fontSize: 12, color: mateRed, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget amountUserGet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          SlydoAppIcon.naira,
          color: navyBlue,
          size: 22,
        ),
        Text(
          " " + amount,
          style: TextStyle(
              fontSize: 36, color: navyBlue, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
