import 'dart:async';
import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../widget/quick_action.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';
import '../shopping/models/store.dart';
import '../shopping/shopping_auth.dart';
import '../shopping/tiles/order_tile.dart';

class VirtualCardHome extends StatefulWidget {
  @override
  _VirtualCardHomeState createState() => _VirtualCardHomeState();
}

class _VirtualCardHomeState extends State<VirtualCardHome> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerPaymentListKey =
      GlobalKey<ScaffoldMessengerState>();

  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =/**/
      RefreshController(initialRefresh: false);

  bool isFirstTime = true;
  late UserBloc userBloc;
  bool isAPILoading = false;
  late AppLocalization appLocalization;
  List transactionList = [];
  bool noItemInList = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isLoading = false;

  // final _auth = ShoppingAuthService();
  final _auth = PaymentAndBankingAuth();/**/
  bool isBalanceHidden = true;

  // variables for to getting filter orderList
  String filterValue = "";
  DateTimeRange? newDateTimeRange;
  bool isMerchant = true;
  String currency = '\$';
  List<CreditCardData> creditCards = [
    CreditCardData(
      cardLabel: "My Dollar Card",
      accountBalance: 5000.0,
      currency: "\$",
      cardNumber: "4521 5678 9101 1121",
      cardHolderName: "Yusuf Adefolahan",
      expirationDate: "13/24",
      securityCode: "235",
      cardColor: Colors.blue,
      cardType: 'visa',
      isBalanceHidden: false,
    ),
    CreditCardData(
      cardLabel: "Savings Card",
      accountBalance: 12000.0,
      currency: "\$",
      cardNumber: "1234 5678 9012 3456",
      cardHolderName: "John Doe",
      expirationDate: "08/25",
      securityCode: "789",
      cardColor: Colors.green,
      cardType: 'mastercard',
      isBalanceHidden: false,
    ),
    CreditCardData(
      cardLabel: "Travel Card",
      accountBalance: 2500.0,
      currency: "\$",
      cardNumber: "9876 5432 1098 7654",
      cardHolderName: "Jane Smith",
      expirationDate: "11/26",
      securityCode: "456",
      cardType: 'visa',
      cardColor: Colors.orange,
      isBalanceHidden: true,
    ),
  ];
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;

  @protected
  void initState() {
    getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;

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
            Container(
                // margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: creditCardCarousel(creditCards)),
            Expanded(child: _buildOtherView()),
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
        addBtn(),
        const SizedBox(width: 12),
        settingBtn(),
        const SizedBox(width: 12.0),
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
        // Navigator.of(context).pushNamed(Routes.REQUEST_PAYMENT,
        //     arguments: <String, bool>{
        //       'isRequest': true,
        //       'isFromProfile': true
        //     });
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

  Widget creditCardCarousel(List<CreditCardData> cardsData) {
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
              });
            },
          ),
          items: cardsData.map((cardData) => creditCard(cardData)).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cardsData.asMap().entries.map((entry) {
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

  Widget creditCard(CreditCardData cardData) {
    var formatter = NumberFormat('#,##,000');

    return Card(
      elevation: 0,
      color: cardData.cardColor,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    cardData.cardLabel,
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
                        cardData.isBalanceHidden
                            ? '****'
                            : "${cardData.currency} ${formatter.format(cardData.accountBalance)}",
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
                    cardData.isBalanceHidden ? '' : cardData.cardNumber,
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
                        cardData.isBalanceHidden ? '' : cardData.cardHolderName,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        cardData.isBalanceHidden ? '' : cardData.expirationDate,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        cardData.isBalanceHidden ? '' : cardData.securityCode,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          SvgPicture.asset(
                            "slydo".toSVG(),
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 5.0),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Column(
                        children: [
                          cardData.cardType == 'visa'
                              ? SvgPicture.asset(
                            "visa".toSVG(),
                            fit: BoxFit.cover,
                          )
                              : SvgPicture.asset(
                            "mastercard".toSVG(),
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 5.0),
                          cardData.cardType == 'visa'
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
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget creditCardOld(CreditCardData cardData) {
    var formatter = NumberFormat('#,##,000');

    return Card(
      elevation: 0,
      color: cardData.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side with text
          Container(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                Text(
                  cardData.cardLabel,
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
                      cardData.isBalanceHidden
                          ? '****'
                          : "${cardData.currency} ${formatter.format(cardData.accountBalance)}",
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
                  cardData.isBalanceHidden ? '' : cardData.cardNumber,
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
                      cardData.isBalanceHidden ? '' : cardData.cardHolderName,
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      cardData.isBalanceHidden ? '' : cardData.expirationDate,
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      cardData.isBalanceHidden ? '' : cardData.securityCode,
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

          // Right side with background image and text
          Expanded(
            child: Container(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      "arrow_card".toSVG(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Text(
                          'Slydo',
                          style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        SvgPicture.asset(
                          "slydo".toSVG(),
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

  Widget getAccountBalanceBtn(CreditCardData cardData) {
    // Add the parameter here
    return cardData.isBalanceHidden
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
            const SizedBox(height: 30.0),
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
            const SizedBox(
              height: 25,
            ),
            _buildTransactionList(),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayCardQuickActionButtons() {
    return Wrap(
      spacing: 15,
      runSpacing: 10,
      children: QuickAction.actionsCard
          .map((data) => ActionChip(
                padding: const EdgeInsets.all(8.0),
                avatar: SvgPicture.asset(data.image!.toSVG()),
                label: Text(
                  data.title ?? '',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: navyBlue),
                ),
                onPressed: () {
                  _actions(data.action);
                },
                backgroundColor: navyBlue.withOpacity(.1),
                shape: StadiumBorder(
                    side: BorderSide(
                  color: navyBlue.withOpacity(0.65),
                )),
              ))
          .toList(),
    );
  }

  void _actions(ActionValue? action) {
    switch (action) {
      case ActionValue.fundCard:
        // hideBalance();
        // Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
        //     arguments: <String, bool>{'isFromProfile': true});
        break;
      case ActionValue.freezeCard:
        // hideBalance();
        // Navigator.pushNamed(context, Routes.ACCOUNTS);
        break;

      default:
        break;
    }
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
        // Navigator.pushNamed(context, Routes.SEARCH_MY_JOBS);
      },
      // backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget _buildTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noOrdersPresent,
          )
        : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: transactionList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == transactionList.length) {
                return _buildIndicator(isLoading: isLoading);
              } else {
                return showCardTransaction(transactionList[index]);
              }
            },
            controller: _scrollController,
          );
  }

  Widget showCardTransaction(Transaction? transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TransactionTile(
        transaction: transaction!,
        expandedWidget: expandedWidget(),
        // key: widget.key,
      ),
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
    transactionList = [];
    isFirstTime = true;
    noItemInList = false;
    getList();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result = await _auth.getTransactions(
          next,
          previous,
          false,
          newDateTimeRange,
          userName: 'sanxy',
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
        transactionList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (transactionList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && transactionList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
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

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Widget expandedWidget() {
    return Container();
  }
}

class CreditCardData {
  // Existing properties
  String cardLabel;
  double accountBalance;
  String currency;
  String cardNumber;
  String cardHolderName;
  String expirationDate;
  String securityCode;
  String cardType;
  Color cardColor;

  // New property to track the visibility of balance
  bool isBalanceHidden;

  // Constructor
  CreditCardData({
    // Existing parameters
    required this.cardLabel,
    required this.accountBalance,
    required this.currency,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.securityCode,
    required this.cardColor,
    required this.cardType,
    // Initialize isBalanceHidden to false by default
    this.isBalanceHidden = false,
  });
}
