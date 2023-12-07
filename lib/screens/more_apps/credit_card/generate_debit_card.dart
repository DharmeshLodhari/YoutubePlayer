import 'dart:io';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/credit_card/auth/debit_card_auth.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/exchange_rate.dart';
import 'package:Slydo/screens/more_apps/credit_card/utils/utils.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/currency.dart';
import '../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';

class GenerateDebitCard extends StatefulWidget {
  var arguments;

  GenerateDebitCard({this.arguments, Key? key}) : super(key: key);



  @override
  GenerateDebitCardState createState() => GenerateDebitCardState();
}

class GenerateDebitCardState extends State<GenerateDebitCard> {

  final _formKey = GlobalKey<FormState>();
  UserBloc? userBloc;

  final ScrollController _scrollController = ScrollController();
  String nairaAmount = "";
  String usdAmount = "";
  bool isLoading = false;
  bool isAPILoading = false;
  final _auth = DebitCardAuth();
  int balance = 0;
  final TextEditingController nairaController = TextEditingController();
  final TextEditingController dollarController = TextEditingController();
  ExchangeRate exchangeRate = ExchangeRate();
  int nairaCheck = 0;


  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
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
        "Debit Card",
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
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fund your card",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  "3/3",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            ),
            const SizedBox(height: 15),

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
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Center(
                child: Text(
                  "A card creation fee of \$1 will be deducted \n upon creation.",
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  canCashOut(nairaCheck, balance)
                      ?
                  getSubmitButton()
                      : Container(
                    child: Center(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0),
                            child: Text.rich(TextSpan(
                                text: AppLocalization.of(context)!
                                    .availableFund,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: blackFont,
                                    fontWeight: FontWeight.w600),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: double.parse(moneyDisplayNormalizer(
                                        displayPossibleCashOutAmount(
                                            balance))) >= 35.00 ? worldCurrencies[
                                    userBloc!.user.currency!]! +
                                        moneyDisplayNormalizer(
                                            displayPossibleCashOutAmount(
                                                balance)) :
                                    '${worldCurrencies[
                                    userBloc!.user.currency!]!}0.00',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: blackFont,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w600),
                                  )
                                ])))),
                  ),
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
            nairaCheck = int.parse(val.replaceAll(",", "").split(".")[0]);
            if(mounted)setState(() {});
          } catch (e) {
            // showToast(message: e.toString());
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
      currencySymbol: '\$',
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            usdAmount = double.parse(val.replaceAll(',', '')).toString();

            nairaController.text = convertCurrency(exchangeRate.slydoRateToNgn!, double.parse(usdAmount)).toString();
            nairaCheck = int.parse(nairaController.text.split(".")[0]);
            if(mounted)setState(() {});
          } catch (e) {
            // showToast(message: e.toString());
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
      onPressed: isAPILoading
          ? () {}
          : () async {
        FocusScope.of(context).unfocus();

        await createCard();

      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Generate Debit Card",
      isLoading: isAPILoading,
    );
  }

  createCard() async {
    if (_formKey.currentState!.validate()) {

        BottomSheetPassCode(
            context: context,
            isValidCallback: () async {
              isAPILoading = true;
              if (mounted) setState(() {});

              Map<String, dynamic> result = {
                "first_name": widget.arguments["data"]['first_name'],
                "last_name": widget.arguments["data"]['last_name'],
                "address1": widget.arguments["data"]['address1'],
                "address2": widget.arguments["data"]['address2'],
                "city": widget.arguments["data"]['city'],
                "state": widget.arguments["data"]['state'],
                "zipcode": widget.arguments["data"]['zipcode'],
                "id_number": widget.arguments["data"]['id_number'],
                "id_type": widget.arguments["data"]['id_type'],
                "customer_bvn": widget.arguments["data"]['customer_bvn'],
                "card_brand": widget.arguments["data"]['card_brand'],
                "label": widget.arguments["data"]['label'],
                "country": 'NG',
                "phone": userBloc!.user.phoneNumber,
                "initial_balance": dollarController.text,
                "exchange_rate_id": exchangeRate.id,
                "color": widget.arguments["data"]['color'],
              };

              await _auth.createDebitCard(result).then((value) {
                if(value == true){
                  Navigator.pop(context, value);
                  showToast(message: "Debit Card Created Successfully");
                  return true;
                }else{
                  showToast(message: "Debit Card Creation Failed");
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
