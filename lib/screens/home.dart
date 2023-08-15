import 'dart:io';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/home_tab/qr_code_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import '../data/currency.dart';
import '../data/database_helper.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../services/auth.dart';
import '../services/secure_storage.dart';
import '../utils/country_picker/country.dart';
import '../utils/country_picker/utils.dart';
import '../utils/navigation_util.dart';
import '../widget/CustomBoxShadow.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/bottom_sheet_item.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/quick_action.dart';
import '../widget/rounded_background_icon.dart';
import '../widget/user_dashboard_item_tile.dart';
import 'more_apps/messaging/button/message_nav_btn.dart';
import 'more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'more_apps/payment_link/payment_link.dart';
import 'more_apps/super_blog/super_blog.dart';
import 'more_apps/user_profile/models/SecureUser.dart';
import 'more_apps/user_profile/models/user.dart';
import 'more_apps/user_profile/user_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey = GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late MainSocketProvider socketProvider;

  bool hasMessage = true;
  late BasketBloc basketBloc;
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;
  int accountBalance = 0;
  int actualAccountBalance = 0;
  bool isBalanceHidden = true;
  late BankAccountBloc bankAccountBloc;
  bool isLoading = false;
  final _auth = AuthService();
  bool storeLocked = true;
  late DashboardBloc dashboardBloc;
  VirtualAccount? virtualAccount;
  String accountNumber = "";
  bool isAccountExist = false;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

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
        await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          AppTutorialController().showTutorial(context);
        });
      }
    });
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

    accountNumber = virtualAccount!.accountNumber!;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    socketProvider = Provider.of<MainSocketProvider>(context);
    dashboardBloc = Provider.of<DashboardBloc>(context);

    if (userBloc.user.type != "User") {
      storeLocked = false;
    }

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height),
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _foregroundScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foregroundScreen() {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 10),
          Container(
              padding: const EdgeInsets.only(left: 8.0), child: _appBar()),
          const SizedBox(
            height: 15,
          ),
          accountBalanceCard(),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              appLocalization.quickActions,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HexColor("#151515")),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: _displayPaymentButtons()),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              appLocalization.explore,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HexColor("#151515")),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: checkUser(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _displayPaymentButtons() {
    double opacity = 0.07;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _sendPaymentButton(),
              ),
            ),
            SizedBox(
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _requestPaymentButton(),
              ),
            ),
            SizedBox(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _paymentLinkButton(),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 102,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _scanButton(),
              ),
            ),
            SizedBox(
              width: 103,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _qrCodeButton(),
              ),
            ),
            SizedBox(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    border: Border.all(color: navyBlue.withOpacity(0.65)),
                    borderRadius: BorderRadius.circular(20),
                    color: navyBlue.withOpacity(opacity)),
                child: _creditCard(),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _requestPaymentButton() {
    return InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                "request_pay".toSVG(),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              appLocalization.request,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          hideBalance();
          Navigator.pushNamed(context, Routes.ACCOUNTS);
        });
  }

  Widget _paymentLinkButton() {
    return InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                "payment_link".toSVG(),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              appLocalization.paymentLink,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          // showToast(message: 'Coming soon');
          NavigationUtil.push(context, screen: PaymentLink());
        });
  }

  Widget _sendPaymentButton() {
    return InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset(
                  "home_naira".toSVG(),
                )),
            const SizedBox(width: 3.5),
            Text(
              "Send ",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          hideBalance();
          Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
              arguments: <String, bool>{'isFromProfile': true});
        });
  }

  Widget _scanButton() {
    return InkWell(
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                "scanny".toSVG(),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "Scan QR",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          hideBalance();
          NavigationUtil.push(context,
              screen: QRCodeView(arguments: {'isRequest': false}));
        });
  }

  Widget _qrCodeButton() {
    return InkWell(
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset("qr_scan_me".toSVG()),
            ),
            const SizedBox(width: 5),
            Text(
              "QR Code",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          hideBalance();
          NavigationUtil.push(context, screen: QrCodePage(arguments: {'isProfile': 'false'}));
        });
  }

  Widget _creditCard() {
    return InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                "home_credit_card".toSVG(),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "Credit Card",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navyBlue),
            ),
          ],
        ),
        onTap: () {
          hideBalance();
          Navigator.of(context).pushNamed(Routes.CREDIT_CARD_OPTION_SELECTION);
        });
  }

  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        onTap: () {
          profileAndroidSheet();
        },
        child: userImageUserInitialsPic(
            userBloc.user.avatar!, userBloc.user.fullName!, 25, 48),
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
        const SizedBox(width: 4.0),
        _cartBtn(),
        const SizedBox(width: 8.0),
        _settingBtn(),
        const SizedBox(width: 8.0),
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
        key: tutorialSettingsKey,
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
        badgeAnimation: const badges.BadgeAnimation.rotation(
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
              ? const EdgeInsets.all(0)
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
      style: const TextStyle(
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
        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Container(
          width: double.infinity,
          decoration: decorateBox(color: navyBlue),
          child: Container(
            padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: MediaQuery.of(context).size.height > 600 ? 18 : 12,
                bottom: MediaQuery.of(context).size.height > 600 ? 24 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //balance, eye icon, bank name/ account number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Balance",
                          style: TextStyle(
                            fontSize: 14,
                            color: white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        getAccountBalanceBtn()
                      ],
                    ),

                    //bank name, account number
                    Column(
                      children: [
                        if (accountNumber != "") ...[
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            "Ampersand MFB ",
                            style: TextStyle(
                                fontSize: 14,
                                color: white,
                                fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              Text(
                                accountNumber,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: white,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "Bank name: ${virtualAccount!.financialInstitution!.name}\nAccount name: ${virtualAccount!.accountName}\nAccount number: ${virtualAccount!.accountNumber}"));
                                  showToast(
                                      message: "Account details copied !!");
                                },
                                child: SvgPicture.asset(
                                  "ampersand".toSVG(),
                                  width: 15,
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    )
                  ],
                ),
                //actual balance
                isLoading == true
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularLoadingIndicator(color: naturalGreen),
                      )
                    : Row(
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
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                      fontFamily: "Roboto",
                                    ),
                                  ),
                                ),
                          Text(
                            isBalanceHidden
                                ? "****"
                                : moneyDisplayNormalizer(accountBalance),
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),

                const SizedBox(
                  height: 5,
                ),
                //book balance
                isLoading == true
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: SizedBox.shrink(),
                      )
                    : Text(
                        isBalanceHidden
                            ? "Book Balance: ****"
                            : "Book Balance: ${worldCurrencies[userBloc.user.currency!]!}${moneyDisplayNormalizer(actualAccountBalance)}",
                        style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: "Roboto"),
                      ),

                const SizedBox(
                  height: 35,
                ),
                //Transaction history, fund wallet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    contentContainer("transaction_icon", "Transaction History",
                        ontap: () {
                      hideBalance();
                      BottomSheetPassCode(
                          context: context,
                          isValidCallback: () {
                            Navigator.of(context).pushNamed(Routes.TRANSACTIONS,
                                arguments: {'page': 0});
                          },
                          cancelCallBack: () {
                            Navigator.pop(context);
                          });
                    }),
                    contentContainer("fund_icon", "Fund Wallet",
                        ontap: () => Navigator.of(context)
                            .pushNamed(Routes.ADD_MONEY_TO_SLYDO_ONE)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget contentContainer(String icon, String text, {Function()? ontap}) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration:
            BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: [
            SvgPicture.asset(
              icon.toSVG(),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 13.4, color: black, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAccountBalanceBtn() {
    return isBalanceHidden
        ? IconButton(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            icon: Icon(
              SlydoAppIcon.eye,
              color: white,
              size: 12,
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
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            icon: Icon(
              SlydoAppIcon.eye_close,
              color: white,
              size: 12,
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

  checkUser() {
    if (userBloc.user.type.toString().toLowerCase() == 'user') {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // first row
          Row(
            children: [
              Expanded(
                  key: tutorialOrderKey,
                  child: UserDashboardItemTile(
                    icon: SlydoAppIcon.cart,
                    title: "Orders",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.ORDERS_LIST);
                    },
                    iconColor: HexColor("#FFAB00"),
                  )),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                key: tutorialInboxKey,
                child: UserDashboardItemTile(
                  iconWidget: const MessageNavBtn(),
                  title: "Inbox",
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
                  },
                  iconColor: HexColor("#374677"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialBlogsKey,
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.news_moreapps,
                  title: AppLocalization.of(context)!.blogs,
                  onTap: () {
                    if (appConfigurationModel?.enableSuperBlog == true) {
                      hideBalance();
                      NavigationUtil.push(
                        context,
                        screen: const SuperBlog(),
                      );
                    } else {
                      showToast(message: 'Feature not available at the moment');
                    }
                  },
                  iconColor: HexColor("#F35B46"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.utility,
                  title: "Utility",
                  onTap: () {
                    if (appConfigurationModel?.enableUtility == true) {
                      hideBalance();
                      Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
                    } else {
                      showToast(message: 'Coming soon.');
                    }
                  },
                  iconColor: HexColor("#FFAB00"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          //second row
          Row(
            children: [
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIconNew.vector_1,
                  title: AppLocalization.of(context)!.services,
                  onTap: () {
                    // if (appConfigurationModel?.enableUtility == true) {
                    //   Navigator.pushNamed(context, Routes.SUPER_HUB);
                    // } else {
                    //   showToast(message: 'Coming soon.');
                    // }
                    hideBalance();
                    Navigator.pushNamed(context, Routes.SUPER_HUB);
                  },
                  iconColor: HexColor("#9B51E0"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
              Expanded(child: Container()),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // first row
          Row(
            children: [
              Expanded(
                  child: UserDashboardItemTile(
                icon: SlydoAppIcon.store,
                title: "My Store",
                isLocked: storeLocked,
                onTap: () {
                  if (!storeLocked) {
                    storeItemAndroidSheet();
                  } else {
                    showToast(
                        message:
                            'You need to upgrade to a business account to use this feature.');
                  }
                },
                iconColor: HexColor("#46CE7C"),
              )),
              const SizedBox(width: 12),
              Expanded(
                  key: tutorialOrderKey,
                  child: UserDashboardItemTile(
                    icon: SlydoAppIcon.cart,
                    title: "Orders",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.ORDERS_LIST);
                    },
                    iconColor: HexColor("#FFAB00"),
                  )),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialInboxKey,
                child: UserDashboardItemTile(
                  iconWidget: const MessageNavBtn(),
                  title: "Inbox",
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
                  },
                  iconColor: HexColor("#374677"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialBlogsKey,
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.news_moreapps,
                  title: AppLocalization.of(context)!.blogs,
                  onTap: () {
                    if (appConfigurationModel?.enableSuperBlog == true) {
                      hideBalance();
                      NavigationUtil.push(
                        context,
                        screen: const SuperBlog(),
                      );
                    } else {
                      showToast(message: 'Feature not available at the moment');
                    }
                  },
                  iconColor: HexColor("#F35B46"),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          // second row
          Row(
            children: [
              Expanded(
                child: UserDashboardItemTile(
                  icon: Icons.business_center_rounded,
                  title: AppLocalization.of(context)!.business,
                  isLocked: storeLocked,
                  onTap: () {
                    if (!storeLocked) {
                      // Navigator.of(context).pushNamed(Routes.CONTRACTS);
                      businessAndroidSheet();
                    } else {
                      showToast(
                          message:
                              'You need to upgrade to a business account to use this feature.');
                    }
                  },
                  iconColor: HexColor("#5218E9"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIconNew.vector_1,
                  title: AppLocalization.of(context)!.services,
                  onTap: () {
                    // if (appConfigurationModel?.enableUtility == true) {
                    //   Navigator.pushNamed(context, Routes.SUPER_HUB);
                    // } else {
                    //   showToast(message: 'Coming soon.');
                    // }
                    hideBalance();
                    Navigator.pushNamed(context, Routes.SUPER_HUB);
                  },
                  iconColor: HexColor("#9B51E0"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.utility,
                  title: "Utility",
                  onTap: () {
                    if (appConfigurationModel?.enableUtility == true) {
                      hideBalance();
                      Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
                    } else {
                      showToast(message: 'Coming soon.');
                    }
                  },
                  iconColor: HexColor("#FFAB00"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
            ],
          ),
        ],
      );
    }
  }

  void storeItemAndroidSheet() {
    hideBalance();
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Add product",
                      iconData: SlydoAppIcon.product,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_PRODUCT);
                      },
                    ),
                    bottomSheetItem(
                      title: "Add service",
                      iconData: SlydoAppIcon.note_2,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_SERVICE);
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  void businessAndroidSheet() {
    hideBalance();
    androidBottomSheet(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            bottomSheetItem(
                title: 'Contract',
                iconData: Icons.description_rounded,
                onTap: () {
                  if (appConfigurationModel?.enableContract == true) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
            bottomSheetItem(
                title: "Invoice",
                iconData: Icons.receipt_outlined,
                onTap: () {
                  if (appConfigurationModel?.enableInvoice == true) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
          ],
        ));
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

  void profileAndroidSheet() {
    hideBalance();
    androidBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          bottomSheetItem(
            title: AppLocalization.of(context)!.myProfile,
            iconData: SlydoAppIcon.user,
            onTap: () async {
              await UserAuth()
                  .fetchCustomerProfile(userBloc.user.userName)
                  .then((user) {
                if (mounted) {
                  Navigator.pop(myGlobals.navigationKey.currentContext!);
                  Navigator.pushNamed(myGlobals.navigationKey.currentContext!,
                      Routes.USER_PROFILE,
                      arguments: {"searchedUserName": user.userName});
                }
              });
            },
          ),
          bottomSheetItem(
            title: AppLocalization.of(context)!.updateMyAvatar,
            iconData: SlydoAppIcon.image,
            onTap: () {
              Navigator.pop(context);
              pickImage();
            },
          ),
          bottomSheetItem(
            title: "Billing address",
            iconData: SlydoAppIcon.location,
            isLast: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.USER_ADDRESS,
              );
            },
          ),
        ],
      ),
    );
  }

  void pickImage() async {
    String? croppedImage = await getCroppedImage(context);

    if (croppedImage != null) {
      try {
        isLoading = true;
        if (mounted) setState(() {});

        User? _user = await DatabaseHelper().getUser();

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String countryFromPref = sharedPreferences.getString('country') ?? "NG";

        Country country =
            CountryPickerUtils.getCountryByIsoCode(countryFromPref);

        SecureUser secureUser = await SecureStorage().getUser();
        String phoneNumber = secureUser.phoneNumber ?? "";
        String password = secureUser.password ?? "";

        if (phoneNumber != "") {
          phoneNumber = "+" + country.phoneCode! + phoneNumber;
        }

        if (phoneNumber == "" || password == "") {
          phoneNumber = _user?.phoneNumber ?? "";
          password = _user?.password ?? "";
        }

        if (phoneNumber == "" || password == "") {
          isLoading = false;
          if (mounted) setState(() {});
          return;
        }

        // Upload Image new image
        await UserAuth().updateUserAvatar(File(croppedImage));

        // Get new updated user data and set new user data to userBloc.
        await _auth.authenticate(phoneNumber, password).then((value) {
          userBloc.user = value;
          isLoading = false;
          if (mounted) setState(() {});
          dashboardBloc.index = 0;
        });
      } catch (err) {
        isLoading = false;
        if (mounted) setState(() {});
        // showToast(message: err.toString());
        debugPrint("Cannot Update Avatar : " + err.toString());
      }
    }
  }
}
