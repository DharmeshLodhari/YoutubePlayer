import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/home_tab/explore_menu_page.dart';
import 'package:Slydo/screens/home_tab/widgets/home_tab_selection.dart';
import 'package:Slydo/screens/home_tab/qr_code_page.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import '../data/currency.dart';
import '../routes/route_constants.dart';
import '../utils/navigation_util.dart';
import '../widget/CustomBoxShadow.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/rounded_background_icon.dart';
import 'more_apps/payment_and_banking/payment_and_banking_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late MainSocketProvider socketProvider;

  bool hasMessage = true;
  late BasketBloc basketBloc;
  late AppLocalization appLocalization;
  int accountBalance = 0;
  int actualAccountBalance = 0;
  bool isBalanceHidden = true;
  late BankAccountBloc bankAccountBloc;
  bool isLoading = false;
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences _sharedPreferences;

      _sharedPreferences = await SharedPreferences.getInstance();
      bool isAppTutorialDone = false;
      try {
        isAppTutorialDone =
            _sharedPreferences.getBool('isAppTutorialDone') ?? false;
      } catch (error) {
        isAppTutorialDone = false;
      }

      if (!isAppTutorialDone) {
        bool result =
            await _sharedPreferences.setBool("isAppTutorialDone", true);
        debugPrint("result:- $result");
        await Future.delayed(Duration(milliseconds: 1500)).then((value) {
          AppTutorialController().showTutorial(context);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    socketProvider = Provider.of<MainSocketProvider>(context);

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(child: _foregroundScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            // flex: MediaQuery.of(context).size.height > 600 ? 9 : 50,
            child: Column(
              children: <Widget>[
                Container(height: 10),
                _appBar(),
                // flexibleSpace(flex: 1),
                SizedBox(
                  height: 15,
                ),
                accountBalanceCard(),
                // flexibleSpace(flex: 2),
                SizedBox(
                  height: 30,
                ),
                _buildTabs(),
                _buildPageView(),
              ],
            ),
          ),
          // flexibleSpace()
        ],
      ),
    );
  }

  Widget _appBar() {
    Color borderColor = getUserTypeColorByType(type: userBloc.user.type!);
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.PHOTO_VIEWER, arguments: userBloc.user.avatar);
        },
        child: Container(
          height: 48,
          width: 48,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1)),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: userBloc.user.avatar!,
              fit: BoxFit.cover,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
      title: InkWell(
        key: tutorialUserProfileDetailKey,
        onTap: () {
          Navigator.pushNamed(context, Routes.USER_PROFILE,
              arguments: {"searchedUserName": userBloc.user.userName});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              getGreetingMessage(),
              style: TextStyle(fontSize: 12, color: HexColor("#151515")),
            ),
            userNameWithVerifiedIcon(
              name: userBloc.user.displayName()!,
              isVerified: userBloc.user.isVerified,
              verifiedIconColor: verifyGreen,
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: HexColor("#151515")),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        _searchBtn(),
        SizedBox(width: 4.0),
        _cartBtn(),
        SizedBox(width: 8.0),
        _settingBtn(),
        SizedBox(width: 8.0),
      ],
    );
  }

  Widget _searchBtn() {
    return Stack(
      key: tutorialSearchItemsKey,
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Expanded(
              child: SizedBox(
                height: 34,
                width: 34,
                child: InkWell(
                  child: Icon(
                    SlydoAppIcon.search,
                    size: 16,
                    color: HexColor("#151515"),
                  ),
                  onTap: () async {
                    hideBalance();
                    await Navigator.of(context).pushNamed(Routes.SEARCH_MODULE);

                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingBtn() {
    return SizedBox(
      height: 36,
      width: 36,
      child: InkWell(
        child: Card(
          elevation: 0,
          // color: blackFont,
          margin: EdgeInsets.symmetric(vertical: 10),
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
          hideBalance();
          Navigator.of(context).pushNamed(Routes.GENERAL_SETTING);
        },
      ),
    );
  }

  Widget _cartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      key: tutorialShoppingCartKey,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(
            end: getBadgeCount().length == 1 ? -5 : 0, top: 0),
        badgeAnimation: badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: naturalGreen,
          padding: basketBloc.items.length == 0
              ? EdgeInsets.all(0)
              : EdgeInsets.only(
                  left: getBadgeCount().length == 1 ? 6 : 8,
                  right: 6,
                  top: 4,
                  bottom: 4),
          elevation: 0,
        ),
        child: Center(
          child: Icon(
            SlydoAppIconNew.cart,
            size: 16,
            color: HexColor("#151515"),
          ),
        ),
      ),
      onTap: () {
        hideBalance();
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'] as int;
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  Widget accountBalanceCard() {
    return CustomBoxShadow(
      child: Card(
        shadowColor: boxShadowTwo,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          width: double.infinity,
          decoration: decorateBox(color: navyBlue),
          child: Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height > 600 ? 18 : 12,
                bottom: MediaQuery.of(context).size.height > 600 ? 24 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Balance",
                  style: TextStyle(fontSize: 14, color: white),
                ),
                SizedBox(
                  height: 16,
                ),
                accountBalanceUI()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget accountBalanceUI() {
    return isLoading == true
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularLoadingIndicator(color: naturalGreen),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isBalanceHidden
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                worldCurrencies[userBloc.user.currency!]!,
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  fontFamily: "Roboto",
                                ),
                              ),
                            ),
                      Text(
                        isBalanceHidden
                            ? "*********"
                            : moneyDisplayNormalizer(accountBalance),
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  getAccountBalanceBtn()
                ],
              ),
              Text(
                isBalanceHidden
                    ? ""
                    : "Actual Balance: " +
                        worldCurrencies[userBloc.user.currency!]! +
                        moneyDisplayNormalizer(actualAccountBalance),
                style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    fontFamily: "Roboto"),
              ),
            ],
          );
  }

  Widget getAccountBalanceBtn() {
    return isBalanceHidden
        ? IconButton(
            icon: Icon(
              SlydoAppIcon.eye,
              color: white,
              size: 18,
            ),
            onPressed: () {
              BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  isLoading = true;
                  getAccountBalance();
                  isBalanceHidden = false;
                  setState(() {});
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                },
              );
            },
          )
        : IconButton(
            icon: Icon(
              SlydoAppIcon.eye_close,
              color: white,
              size: 24,
            ),
            onPressed: () {
              isBalanceHidden = true;
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

  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      var actualBalance = data["balance"];

      accountBalance = spendableBalance;
      actualAccountBalance = actualBalance;
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildTabs() {
    return Column(
      children: [
        HomeTabSelection(
          onTap: (index) {
            hideBalance();
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);
            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          QrCodePage(),
          ExploreMenuPage(),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }

  String getGreetingMessage() {
    TimeOfDay currentTime = TimeOfDay.now();

    if (currentTime.hour >= 6 &&
        (currentTime.hour <= 11 && currentTime.minute <= 59)) {
      return "${appLocalization.goodMorning},";
    } else if (currentTime.hour >= 12 &&
        (currentTime.hour <= 16 && currentTime.minute <= 59)) {
      return "${appLocalization.goodAfternoon},";
    } else if (currentTime.hour >= 17 &&
        (currentTime.hour <= 19 && currentTime.minute <= 59)) {
      return "${appLocalization.goodEvening},";
    } else {
      return "${appLocalization.goodEvening},";
    }
  }
}
