import 'dart:io';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/credit_card/auth/debit_card_auth.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/all_cards.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/exchange_rate.dart';
import 'package:Slydo/screens/more_apps/credit_card/utils/utils.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../data/currency.dart';
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
  int nairaCheck = 0;

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {

    allCards = widget.arguments["data"];
    labelController.text = allCards.label!;
    nairaController.text = '';
    dollarController.text = '';

    isLoading = true;
    getAccountBalance();
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

            mainCreditCardContent(allCards),
            const SizedBox(
              height: 20,
            ),

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
                                        fontFamily: "Roboto",
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

  Widget mainCreditCardContent(AllCards cardData){

    var cardColors = [];
    var cardColor;

    if(cardData.color == null){
      cardColors = [navyBlue, richPink, black, orange];
      cardColor = navyBlue;
    }else{
      String? color = cardData.color;
      switch (color) {
        case 'Slydo Blue':
          cardColor = navyBlue;
          break;
        case 'Pink':
          cardColor = richPink;
          break;
        case 'Black':
          cardColor = black;
          break;
        case 'Orange':
          cardColor = orange;
          break;
        default:
        // Handle default case (when color doesn't match any specific case)
          cardColor = navyBlue;
          break;
      }

    }

    return Container(
      height: 200,
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/arrow_card.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: [
              // Left side with text
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Stack(
                  children: [
                    Positioned(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20.0),
                          Text(
                            cardData.label.toString(),
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Text(
                                cardData.isBalanceHidden!
                                    ? '****'
                                    : cardData.currencyCode == 'USD' ? formatAsDollar(cardData.availableBalance!) : formatAsNaira(cardData.availableBalance!),
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              getAccountBalanceBtn(cardData),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            cardData.isBalanceHidden! ? '****************' : insertSpacesInCardNumber(cardData.cardNumber!),
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Text(
                                cardData.isBalanceHidden! ? '**********' : appendStringDot('${cardData.nameLine1} ${cardData.nameLine2}', 15),
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                cardData.isBalanceHidden! ? '****' :
                                "${cardData.expiration!.substring(0, 2)}/${cardData.expiration!.substring(2)}",
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                cardData.isBalanceHidden! ? '***' : cardData.securityCode!,
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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

              // Right side with background image and text
              Expanded(
                child: Container(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Row(
                          children: [
                            Text(
                              'Slydo',
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            SvgPicture.asset(
                              "slydo".toSVG(),
                              fit: BoxFit.cover,
                            ),

                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Column(
                          children: [
                            cardData.cardBrand == 'Visa'
                                ? SvgPicture.asset(
                              "visa".toSVG(),
                              fit: BoxFit.cover,
                            )
                                : SvgPicture.asset(
                              "mastercard".toSVG(),
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 5.0),
                            cardData.cardBrand == 'Visa'
                                ? SizedBox.shrink()
                                : Column(
                              children: [
                                Text(
                                  'Mastercard',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAccountBalanceBtn(AllCards cardData) {
    // Add the parameter here
    return cardData.isBalanceHidden!
        ? IconButton(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      icon: const Icon(
        Icons.visibility,
        color: Colors.white,
        size: 12,
      ),
      onPressed: () {
        cardData.isBalanceHidden = false; // Set the flag on the cardData
        setState(() {});
      },
    )
        : IconButton(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      icon: const Icon(
        Icons.visibility_off,
        color: Colors.white,
        size: 12,
      ),
      onPressed: () {
        cardData.isBalanceHidden = true; // Set the flag on the cardData
        setState(() {});
      },
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
            usdAmount = dollarController.text;

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
      currencySymbol: '\$',
      controller: dollarController,
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

      balance = spendableBalance;
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
