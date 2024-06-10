import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class AddMoneyToSlydoTwo extends StatefulWidget {
  var arguments;

  AddMoneyToSlydoTwo({this.arguments});

  @override
  _AddMoneyToSlydoTwoState createState() => _AddMoneyToSlydoTwoState();
}

class _AddMoneyToSlydoTwoState extends State<AddMoneyToSlydoTwo> {
  final _formKeyTwo = GlobalKey<FormState>();

  String errorMessage = "";

  String amount = "0";

  String referenceNumber = "";
  String currency = "NGN";

  bool isChecked = false;

  String? bankName;
  String? bankAccountName;
  String? bankAccountNumber;

  bool isBankDetailsIsEmpty = false;
  bool alreadyHaveReference = false;

  @override
  void initState() {
    debugPrint("response ${widget.arguments}");
    amount = widget.arguments["amount"].toString();
    referenceNumber = widget.arguments["reference"].toString();
    currency = widget.arguments["currency"].toString();
    final Map? bankDetails = widget.arguments["bank_details"];
    if (bankDetails == null || bankDetails.isEmpty) {
      // isBankDetailsIsEmpty = true;
      isBankDetailsIsEmpty = false;
    } else {
      bankName = bankDetails["bank_name"].toString();
      bankAccountName = bankDetails["account_name"].toString();
      bankAccountNumber = bankDetails["account_number"].toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Form(
          key: _formKeyTwo,
          child: Column(
            children: <Widget>[
              amountUserGetMsg(),
              const SizedBox(
                height: 20,
              ),
              amountUserGet(),
              const SizedBox(
                height: 28,
              ),
              getOtherDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
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
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 20),
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
                          bankName ?? "",
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
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
                          bankAccountName ?? "",
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
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
                          bankAccountNumber ?? "",
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

  Widget getOtherDetails() {
    if (isBankDetailsIsEmpty) {
      return getBankAccountEmptyWidget();
    } else {
      return Column(
        children: [
          referenceIdFiled(),
          const SizedBox(
            height: 20,
          ),
          getUserBankAccountSlydo(),
          const SizedBox(
            height: 24,
          ),
          userTopUpNote(),
          const SizedBox(
            height: 16,
          ),
          transferredMoneyCheck(),
          const SizedBox(
            height: 20,
          ),
          if (isChecked) getSubmitButton() else Container(),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }
  }

  Widget getBankAccountEmptyWidget() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: decorateBox(),
        child: Text("Information not available",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
                height: 1.5)),
      ),
    );
  }

  Widget referenceIdFiled() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: blackFont.withOpacity(0.05),
                ),
                child: Text(
                  referenceNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: blackFont,
                      fontWeight: FontWeight.w700),
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: referenceNumber));
                showToast(message: "Reference number copied !!");
              },
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
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.transparent,
                  ),
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      isChecked = !isChecked;
                      if (mounted) setState(() {});
                    },
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            "Have you transferred money?",
            style: TextStyle(color: blackFont, fontSize: 14),
          ),
        ],
      ),
      onTap: () {
        isChecked = !isChecked;
        if (mounted) setState(() {});
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

    if (_formKeyTwo.currentState!.validate()) {
      final data = {"reference": referenceNumber};
      PaymentAndBankingAuth()
          .confirmTopUpWithReferenceNumber(data)
          .then((value) {
        if (value) {
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e.toString());
        showToast(message: e);
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
        "Please tick the box below after you have transferred payment.",
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
          " ${moneyDisplayNormalizer(int.parse(amount))}",
          style: TextStyle(
              fontSize: 36, color: navyBlue, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
