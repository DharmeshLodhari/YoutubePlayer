import 'dart:io';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/credit_card/auth/debit_card_auth.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/all_cards.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/exchange_rate.dart';
import 'package:Slydo/screens/more_apps/credit_card/utils/utils.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../routes/route_constants.dart';
import '../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';

class FundVirtualCard extends StatefulWidget {
  var arguments;

  FundVirtualCard({this.arguments, Key? key}) : super(key: key);

  @override
  FundVirtualCardState createState() => FundVirtualCardState();
}

class FundVirtualCardState extends State<FundVirtualCard> {

  final _formKey = GlobalKey<FormState>();
  UserBloc? userBloc;

  final ScrollController _scrollController = ScrollController();
  String cardLabel = "";
  String nairaAmount = "";
  String usdAmount = "";
  String label = "";
  bool isLoading = false;
  bool isAPILoading = false;
  final _auth = DebitCardAuth();
  int balance = 0;
  final TextEditingController nairaController = TextEditingController();
  final TextEditingController dollarController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  ExchangeRate exchangeRate = ExchangeRate();
  AllCards allCards = AllCards();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {

    allCards = widget.arguments["data"];
    labelController.text = allCards.label!;

    isLoading = true;
    getExchangeRate();
    super.initState();
  }


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
        "Fund Card",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
      child: CircularLoadingIndicator(),
    )
        : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
        child: Column(
          children: [

            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: iconBtnGrey,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBtnGrey, width: 1)),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10),
                        addCardLabelField(),
                        const SizedBox(
                          height: 10,
                        ),
                        getAmountField(),

                        const SizedBox(
                          height: 10,
                        ),
                        getDollarAmountField(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  getSubmitButton(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget addCardLabelField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.cardLabel,
      controller: labelController,
      enabled: false,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterLabel;
      },
      onChanged: (val) {
        cardLabel = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount to fund wallet",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      controller: nairaController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            nairaAmount = double.parse(val.replaceAll(',', '')).toString();

            dollarController.text = convertCurrency(exchangeRate.slydoNgnToRate!, double.parse(nairaAmount)).toString();
            if(mounted)setState(() {});
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getDollarAmountField() {
    return CustomizedTextFormField(
      labelText: "In dollars (rate: ${userBloc!.user.currency!}${exchangeRate.slydoRateToNgn})",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      controller: dollarController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            usdAmount = double.parse(val.replaceAll(',', '')).toString();

            nairaController.text = convertCurrency(exchangeRate.slydoRateToNgn!, double.parse(usdAmount)).toString();
            if(mounted)setState(() {});
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();

       fundVirtualCard();

      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Fund Card",
      isLoading: isAPILoading,
    );
  }

  Future<void> fundVirtualCard() async {
    if (_formKey.currentState!.validate()) {

      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            isAPILoading = true;
            if (mounted) setState(() {});

            Map<String, dynamic> result = {
              "amount": usdAmount,
              "exchange_rate_id": exchangeRate.id,
            };

            await _auth.fundCard(result, allCards.cardId!).then((value) {
              if(value == true){
                Navigator.pop(context, value);
                showToast(message: "Debit Card Funded");
                return true;
              }else{
                showToast(message: "Funding Debit Card Failed");
                return true;
              }

            }).catchError((error) {
              debugPrint(error.toString());
              showToast(message: error.toString());
            });

            isAPILoading = false;
            if (mounted) setState(() {});

          },
          cancelCallBack: () {
            Navigator.pop(context);
          });

    }
  }


  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      var actualBalance = data["balance"];

      balance = spendableBalance;
      // isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getExchangeRate() async {
    await _auth.getExchangeRate().then((value) {

      exchangeRate = value!;
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
