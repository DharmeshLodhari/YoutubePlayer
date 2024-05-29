import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../messaging/chat/utils.dart';
import '../../payment_and_banking_auth.dart';

class VirtualAccountDetail extends StatefulWidget {
  @override
  _VirtualAccountDetailState createState() => _VirtualAccountDetailState();
}

class _VirtualAccountDetailState extends State<VirtualAccountDetail> {
  final _formKeyTwo = GlobalKey<FormState>();

  UserBloc? userBloc;
  BankAccountBloc? bankAccountBloc;

  String errorMessage = "";

  String amount = "";

  bool isLoading = false;
  bool isAccountExist = false;
  bool isKYCInProcess = false;
  String? _currentTier;

  VirtualAccount? virtualAccount;

  List<String> tiers = [];

  @override
  void initState() {
    getSlydoAccount();
    super.initState();
  }

  void getSlydoAccount() async {
    isLoading = true;
    setState(() {});
    bool isFromServer = false;

    virtualAccount = await DatabaseHelper().getVirtualAccount();

    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
      isFromServer = true;
    }

    isLoading = false;

    if (virtualAccount != null) {
      isAccountExist = true;
      if (isFromServer) {
        await DatabaseHelper().saveVirtualAccount(virtualAccount!);
      }
    }

    _currentTier = virtualAccount?.accountTier?.tierType;

    debugPrint("CURRENT TIER => $_currentTier");
    // if (_currentTier == "1") {
    //   _selectedTier = "Tier 2";
    // } else if (_currentTier == "2") {
    //   _selectedTier = "Tier 3";
    // }

    /// TODO: REMOVE THIS COMMENT AND LINES WHEN IMPLEMENTATION DONE FOR KYC
    // isKYCInProcess = true;
    // isAccountExist = false;
    if (mounted) setState(() {});
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
        "Wallet Details",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(child: CircularLoadingIndicator())
        : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  (AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: _formKeyTwo,
                child: Column(
                  children: <Widget>[
                    getUserBankAccountSlydo(),
                    const SizedBox(height: 20),
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

  Widget getReferenceButton() {
    return CurvedButton(
      // onPressed: onSubmit,
      onPressed: isAccountExist ? onSubmit : () {},
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "TOP UP",
      // text: "Get reference",
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    final data = {
      "amount": moneyInputNormalizer(amount.toString()),
      "currency": userBloc!.user.currency,
    };

    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularLoadingIndicator(),
      ),
    );

    if (_formKeyTwo.currentState!.validate()) {
      await PaymentAndBankingAuth().topUpAccountByBank(data).then((value) {
        if (value != null) {
          Navigator.pop(context);
          final result = value;
          Navigator.popAndPushNamed(context, Routes.ADD_MONEY_TO_SLYDO_TWO,
              arguments: result);
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e);
        showToast(message: e);
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget noteForUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
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

  Widget getUserBankAccountSlydo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: !isAccountExist
            ? ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                title: Text(
                  isKYCInProcess
                      ? "Your KYC is in Process.\nCheck back later."
                      : "Account not available now.\nCheck back later.",
                  style: TextStyle(
                      fontSize: 14,
                      color: navyBlue,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  getBankAccountName(),
                  Divider(
                    thickness: 1,
                    color: dividerColor,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Column(
                          children: [
                            getAccountName(),
                            const SizedBox(height: 8),
                            getAccountNumber(),
                            const SizedBox(height: 8),
                            getTierInstruction(),
                            const SizedBox(height: 24),
                            getSlydoBankAccountDetail(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget getTierInstruction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text("Tier "),
            ),
            Expanded(
                child: Text(
              "1",
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
            )),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            const Expanded(
              child: Text("Account limit"),
            ),
            Expanded(
              child: Text(
                getAmountFormatter(
                    virtualAccount?.accountTier?.cumulativeBalance.toString()),
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            const Expanded(
              child: Text("Maximum pay limit"),
            ),
            Expanded(
              child: Text(
                getAmountFormatter(virtualAccount
                    ?.accountTier?.dailyCumulativeTransactionLimit
                    .toString()),
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ],
    );
  }

  Widget getSlydoBankAccountDetail() {
    return Column(
      children: [
        Text(
          "Please transfer funds into your virtual account to fund your slydo wallet",
          style: TextStyle(
              color: naturalGreen, fontWeight: FontWeight.w600, fontSize: 14),
        )
      ],
    );
  }

  Widget getBankAccountName() {
    return ListTile(
      title: Text(virtualAccount!.financialInstitution!.name ?? "",
          style: TextStyle(
              fontSize: 14, color: blackFont, fontWeight: FontWeight.w600)),
      leading: CachedNetworkImage(
        imageUrl: virtualAccount!.financialInstitution!.logo ?? "",
        height: 36,
        width: 36,
        errorWidget: imageErrorWidget,
      ),
      trailing: getCopyButton(onTap: () {
        Clipboard.setData(ClipboardData(
            text:
                "Bank name: ${virtualAccount!.financialInstitution!.name}\nAccount name: ${virtualAccount!.accountName}\nAccount number: ${virtualAccount!.accountNumber}"));
        showToast(message: "Account details copied !!");
      }),
    );
  }

  Widget getAccountName() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Account name",
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        Expanded(
          child: Text(
            virtualAccount!.accountName ?? "",
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        getCopyButton(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: "${virtualAccount!.accountName}"));
              showToast(message: "Account name copied !!");
            },
            size: 17)
      ],
    );
  }

  Widget getAccountNumber() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Account number',
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        Expanded(
          child: Text(
            virtualAccount!.accountNumber ?? "",
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        getCopyButton(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: "${virtualAccount!.accountNumber}"));
              showToast(message: "Account number copied !!");
            },
            size: 17)
      ],
    );
  }

  Widget getCopyButton({Function? onTap, double size = 20}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Icon(
        Icons.copy,
        color: blackFont,
        size: size,
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
        getUserCurrencySymbol(context),
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
    return "0";
  }

  String getAmountFormatter(String? value) {
    final commaFormatter = NumberFormat('#,###.##');
    final double? amount = double.tryParse(value!);
    final String formattedAmount = commaFormatter.format(amount);

    return formattedAmount;
  }
}
