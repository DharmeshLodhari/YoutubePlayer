import 'dart:ui';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/all_cards.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/card_transactions.dart';
import 'package:Slydo/screens/more_apps/credit_card/tiles/card_action_button.dart';
import 'package:Slydo/screens/more_apps/credit_card/tiles/virtual_card_shimmer.dart';
import 'package:Slydo/screens/more_apps/credit_card/utils/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../routes/route_constants.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_textform_field.dart';
import '../../../widget/dialog.dart';
import '../yarn/widgets/yarn_shimmer.dart';
import 'auth/debit_card_auth.dart';

class VirtualCardHome extends StatefulWidget {

  const VirtualCardHome({Key? key}) : super(key: key);

  @override
  VirtualCardHomeState createState() => VirtualCardHomeState();
}

class VirtualCardHomeState extends State<VirtualCardHome> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerPaymentListKey =
      GlobalKey<ScaffoldMessengerState>();

  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isFirstTime = true;
  bool isFirstTimeTransaction = true;
  late UserBloc userBloc;
  bool isAPILoading = false;
  bool isAPILoadingTransaction = false;
  late AppLocalization appLocalization;
  List<CardTransactions> transactionList = [];
  List<AllCards> cardList = [];
  bool noItemInList = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isLoading = false;

  int? countTransaction = 0;
  String? nextTransaction = "";
  String? previousTransaction = "";
  bool isLoadingTransaction = false;
  bool noItemInTransactionList = false;

  final _auth = DebitCardAuth();
  bool isBalanceHidden = true;

  String currency = '\$';
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;
  List<CardAction> cardActions = [];
  final TextEditingController labelController = TextEditingController();


  @protected
  void initState() {
    getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getTransactionList();
      }
    });
    loadCardActions();

    super.initState();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result = await _auth.getAllCards(
          next,
          previous,
        );
        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        var tempList = result['results'];

        isLoading = false;
        cardList.addAll(tempList);

        if (mounted) setState(() {});

        if(cardList.isNotEmpty){
          //call card history
          getTransactionList();
        }

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (cardList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && cardList.length > 6) {
        // showReachedToBottomSnackBar();
      }
    }
  }

  void getTransactionList() async {
    if (!isLoadingTransaction) {
      if (nextTransaction != null && !isLoadingTransaction) {
        if (mounted) {
          setState(() {
            isLoadingTransaction = true;
          });
        }
        AllCards currentCard = cardList[_currentIndex];
        Map<String, dynamic>? result = await _auth.getSingleCardsTransactions(
          nextTransaction,
          previousTransaction,
            currentCard.cardId,
        );
        if (result == null) {
          isLoadingTransaction = false;
          return;
        }
        nextTransaction = result['next'];
        countTransaction = result['count'];
        previousTransaction = result['previous'];
        var tempList = result['results'];

        isLoadingTransaction = false;
        transactionList.addAll(tempList);

        if (mounted) setState(() {});


        if (isFirstTimeTransaction && nextTransaction != null && nextTransaction != "") {
          isFirstTimeTransaction = false;
          getTransactionList();
        }
      }
      if (transactionList.isEmpty) {
        noItemInTransactionList = true;

        if (mounted) setState(() {});
      } else if (nextTransaction == null && transactionList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;

    if (isLoading) {
      return Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    return ScaffoldMessenger(
      key: _scaffoldMessengerPaymentListKey,
      child: Scaffold(
        key: _scaffoldPaymentListKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            if(cardList.isEmpty)...[
              Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: noCreditCard()),
              Expanded(child: _buildNoCreditCardView()),
            ]
            else...[
              Container(
              // margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: creditCardCarousel(cardList)),
              Expanded(child: _buildOtherView()),],

          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        'Virtual Card',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if(cardList.isNotEmpty)...[
          addBtn(),
          const SizedBox(width: 12),
          // settingBtn(),
          // const SizedBox(width: 12.0),
        ],

      ],
    );
  }

  Widget addBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {

        if(cardList.length >= 3){
          showToast(message: 'Maximum debit card limit reached');
        }else{
          Navigator.pushNamed(context, Routes.ADD_VIRTUAL_CARD);
        }

      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget settingBtn() {
    return SizedBox(
      height: 36,
      width: 36,
      child: InkWell(
        child: Card(
          elevation: 0,
          // color: blackFont,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            SlydoAppIcon.settings,
            size: 16,
            color: blackFont,
          ),
        ),
        onTap: () {
          // hideBalance();
          // Navigator.of(context).pushNamed(Routes.GENERAL_SETTING);
        },
      ),
    );
  }

  Widget creditCardCarousel(List<AllCards> cardsData) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 200,
            enableInfiniteScroll: false,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
                _refreshTransactionList();
              });
            },
          ),
          items: cardsData.asMap().entries.map((entry) {
            int index = entry.key;
            AllCards cardData = entry.value;
            return creditCard(cardData, index);
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cardList.asMap().entries.map((entry) {
            int index = entry.key;
            return Container(
              width: 8.0,
              height: 8.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.black : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget creditCard(AllCards cardData, int index) {

    final cardColors = [navyBlue, darkGreyYarn, Colors.green]; // Example colors
    final cardColor = cardColors[index % cardColors.length];

    bool? card = cardList[_currentIndex].activated;

    return Card(
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
        child: card!
            ? mainCreditCardContent(cardData) :
        Opacity(
          opacity: 0.2,
          child: mainCreditCardContent(cardData),
        ),
      ),
    );
  }

  Widget mainCreditCardContent(AllCards cardData){

    return Row(
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
                    // SizedBox(
                    //   width: 100,
                    //   child: TextFormField(
                    //     initialValue: cardData.label.toString(),
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 14,
                    //     ),
                    //     decoration: InputDecoration(
                    //       hintText: 'Enter Label', // Provide a hint text
                    //       hintStyle: TextStyle(color: Colors.grey),
                    //       // enabledBorder: UnderlineInputBorder(
                    //       //   borderSide: BorderSide(color: Colors.white),
                    //       // ),
                    //       // focusedBorder: UnderlineInputBorder(
                    //       //   borderSide: BorderSide(color: Colors.white),
                    //       // ),
                    //     ),
                    //     // onChanged: (newValue) {
                    //     //   // Handle onChanged if needed
                    //     // },
                    //   ),
                    // ),
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
                      cardData.isBalanceHidden! ? '' : insertSpacesInCardNumber(cardData.cardNumber!),
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
                          cardData.isBalanceHidden! ? '' : '${cardData.nameLine1} ${cardData.nameLine2}',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          cardData.isBalanceHidden! ? '' :
                          "${cardData.expiration!.substring(0, 2)}/${cardData.expiration!.substring(2)}",
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Text(
                        //   cardData.isBalanceHidden! ? '' : cardData.securityCode!,
                        //   style: TextStyle(
                        //     color: white,
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 12,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                  top: 70,
                  left: 10,
                  child: Opacity(
                    opacity: 0.3,
                    child: SvgPicture.asset(
                      "slydo".toSVG(),
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  )
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
                Positioned(
                    bottom: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          cardData.isBalanceHidden! ? '' : cardData.securityCode!,
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget addCardLabelField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.cardLabel,
      controller: labelController,
      // enabled: false,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterLabel;
      },
      onChanged: (val) {
        //save to database onfocus lost
        // cardLabel = val;
        labelController.text = val;
        if(mounted)setState(() {});
      },
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

  void hideBalance() {
    if (isBalanceHidden == false) {
      isBalanceHidden = true;
      if (mounted) setState(() {});
    }
  }

  Widget _buildOtherView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                appLocalization.quickActions,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HexColor("#151515")),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: _displayCardQuickActionButtons()),
            const SizedBox(
              height: 25,
            ),

            //transactions and search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    appLocalization.transaction,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HexColor("#151515")),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                    child: _searchBtn()),
              ],
            ),

            _buildTransactionList(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayCardQuickActionButtons() {
    double opacity = 0.07;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (int i = 0; i < cardActions.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: i > 0 ? 10 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: navyBlue.withOpacity(0.65)),
                  borderRadius: BorderRadius.circular(20),
                  color: navyBlue.withOpacity(opacity),
                ),
                child: CardActionButton(
                  iconAsset: cardActions[i].iconAsset,
                  label: cardActions[i].label,
                  onPressed: cardActions[i].onPressed,
                ),
              ),
            ),
        ],
      ),
    );

  }

  Widget _searchBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Icon(
          SlydoAppIcon.search,
          size: 16,
          color: blackFont,
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.SEARCH_TRANSACTION_CARD, arguments: {
          'data': cardList[_currentIndex].cardId,
        });
      },
      // backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget _buildTransactionList() {
    if (isLoadingTransaction) {
      return _buildLoadingIndicator();
    }

    return noItemInTransactionList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noTransaction,
          )
        : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: transactionList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == transactionList.length) {
                return _buildLoadingIndicator();
              } else {
                return showCardTransaction(transactionList[index]);
              }
            },
            controller: _scrollController,
          );
  }

  Widget showCardTransaction(CardTransactions? transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: CardTransactionTile(
        transaction: transaction!,
        expandedWidget: expandedWidget(),
      ),
    );
  }

  Widget noCreditCard() {
    return Card(
      elevation: 0,
      color: navyBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side with text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, bottom: 20),
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    "slydo".toSVG(),
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              Container(
                padding: const EdgeInsets.only(left: 16, bottom: 30),
                child: Text(
                  "Debit Card",
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),

          //Right side with text
          Expanded(
            child: Container(
              child: Stack(
                children: [
                  SvgPicture.asset(
                    "arrow_card".toSVG(),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        const Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        SvgPicture.asset(
                          "visa".toSVG(),
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 5.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNoCreditCardView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: RichText(
                text: TextSpan(
                  text: 'Get a ',
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'digital card ',
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'and start paying in dollars online securely !',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ListTile(
              leading: SvgPicture.asset(
                "apple_pay".toSVG(),
                fit: BoxFit.cover,
              ),
              title: const Text(
                'Purchase easily in-store',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                  'Set up subscription and pay with your virtual card details'),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              leading: SvgPicture.asset(
                "travel".toSVG(),
                fit: BoxFit.cover,
              ),
              title: const Text(
                'A safer way to pay',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                  'Use a virtual card when you dont trust a company with your details'),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              leading: SvgPicture.asset(
                "shield".toSVG(),
                fit: BoxFit.cover,
              ),
              title: const Text(
                'Travel with your card ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
              const Text('Pay easily with your virtual card when you travel abroad.'),
            ),
            const SizedBox(height: 30),
            getSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed:  () async {
        FocusScope.of(context).unfocus();


        final data = await Navigator.of(context).pushNamed(Routes.ADD_VIRTUAL_CARD);

        // Handle the result (map) received from ADD_VIRTUAL_CARD
        if (data != null && data == true) {
          //refresh list
          _onRefresh();
          if(mounted)setState(() {});
        }

      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Get a debit card",
      isLoading: isAPILoading,
    );
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refresh();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void _refresh() {
    count = 0;
    next = "";
    previous = "";
    countTransaction = 0;
    nextTransaction = "";
    previousTransaction = "";
    cardList = [];
    transactionList = [];
    isFirstTime = true;
    isFirstTimeTransaction = true;
    noItemInList = false;
    noItemInTransactionList = false;
    _currentIndex = 0;
    if(mounted)setState(() {});
    getList();
  }

  void _refreshTransactionList() {
    countTransaction = 0;
    nextTransaction = "";
    previousTransaction = "";
    transactionList = [];
    isFirstTimeTransaction = true;
    noItemInTransactionList = false;
    if(mounted)setState(() {});
    getTransactionList();
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        _scaffoldMessengerPaymentListKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget _buildIndicator({required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isLoadingTransaction ? 1.0 : 00,
      child: isLoadingTransaction ? const VirtualCardShimmer() : Container(),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Widget expandedWidget() {
    return Container();
  }

  void loadCardActions() {
    cardActions = [
      CardAction(
        iconAsset: "fund_card".toSVG(),
        label: "Fund Card",
        onPressed: () async {
          // Handle 'Fund Card' action
          final data = await Navigator.of(context).pushNamed(Routes.FUND_VIRTUAL_CARD, arguments: {
            'data': cardList[_currentIndex],
          });

          // Handle the result (map) received from FUND_VIRTUAL_CARD
          if (data != null && data == true) {
            _refresh();
            if(mounted)setState(() {});
          }

        },
      ),
      CardAction(
        iconAsset: "freeze_card".toSVG(),
        label: "Freeze Card",
        // label: cardList[_currentIndex].activated! ? "Freeze Card" : "Unfreeze Card",
        onPressed: () {
          freezeCardDialog(cardList[_currentIndex]);
        },
      ),
      CardAction(
        iconAsset: "withdraw_card".toSVG(),
        label: "Withdraw",
        onPressed: () async {
          // Handle 'Withdraw' action
          final data = await Navigator.of(context).pushNamed(Routes.WITHDRAW_VIRTUAL_CARD, arguments: {
            'data': cardList[_currentIndex],
          });

          // Handle the result (map) received from WITHDRAW_VIRTUAL_CARD
          if (data != null && data == true) {
            _refresh();
            if(mounted)setState(() {});
          }
        },
      ),
      CardAction(
        iconAsset: "terminate_card".toSVG(),
        label: "Cancel",
        onPressed: () {
          terminateCardDialog(cardList[_currentIndex]);
        },
      ),

    ];
  }

   void freezeCardDialog(AllCards allCards) {
    showDialogBox(
      context: context,
      actionOneTextColor: white,
      actionOneBgColor: navyBlue,
      actionTwoTextColor: blackFont,
      actionTwoBgColor: greyBorderColor,
      title: allCards.activated! ? "Freeze" : "Unfreeze",
      actionTwoText: AppLocalization.of(context)!.cancel,
      actionOneText: AppLocalization.of(context)!.continueMsg,
      description:
      allCards.activated! ? "Are you sure you want to freeze \nthis card?" : "Are you sure you want to unfreeze \nthis card?",
      roundedBackgroundIcon: RoundedBackgroundIcon(
        width: 90,
        height: 90,
        enableMargin: false,
        image: Image.asset('assets/images/dialog_freeze.png'),
      ),
      leftButtonOnPressed: () {
        isLoading = true;
        if(mounted)setState(() {});
        freezeCard(allCards);

      },
    );
  }

   void terminateCardDialog(AllCards allCards) {
    showDialogBox(
      context: context,
      actionOneTextColor: white,
      actionOneBgColor: navyBlue,
      actionTwoTextColor: blackFont,
      actionTwoBgColor: greyBorderColor,
      title: "Cancel Card",
      actionTwoText: AppLocalization.of(context)!.cancel,
      actionOneText: AppLocalization.of(context)!.continueMsg,
      description:
      "Are you sure you want to cancel \nthis card, you will not be able to use this \ncard for any transaction again?",
      roundedBackgroundIcon: RoundedBackgroundIcon(
        width: 90,
        height: 90,
        enableMargin: false,
        image: Image.asset('assets/images/dialog_freeze.png'),
      ),
      leftButtonOnPressed: () {
        isLoading = true;
        if(mounted)setState(() {});
        terminateCard(allCards);
      },
    );
  }

  Future<void> freezeCard(AllCards allCards) async {
    bool? cardStatus = allCards.activated;
    if(cardStatus == true){
      cardStatus = false;
    }else{
      cardStatus = true;
    }
    Map<String, dynamic> result = {
      "activated": cardStatus,
    };

    await _auth.freezeCard(result, allCards.cardId.toString()).then((value) {
      isLoading = false;
      if(mounted)setState(() {});

      if(value == true){
        // refresh layout
        _onRefresh();
        if(cardStatus == true){
          showToast(message: "Debit Card Activated Successfully");
        }else{
          showToast(message: "Debit Card Deactivated Successfully");
        }

        return true;
      }else{

        showToast(message: "Error occurred");
        return true;
      }


    }).catchError((error) {
      debugPrint(error.toString());
      isLoading = false;
      if(mounted)setState(() {});
      showToast(message: error.toString());
    });
  }

  Future<void> terminateCard(AllCards allCards) async {

    await _auth.terminateCard(allCards.cardId.toString()).then((value) {
      isLoading = false;
      if(mounted)setState(() {});

      if(value == true){
        // refresh layout
        _onRefresh();
          showToast(message: "Debit Card Terminated");

        return true;
      }else{

        showToast(message: "Debit Card Termination Failed");
        return true;
      }

    }).catchError((error) {
      debugPrint(error.toString());
      isLoading = false;
      if(mounted)setState(() {});
      showToast(message: error.toString());
    });
  }

}

