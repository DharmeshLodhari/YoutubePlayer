import 'dart:io';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/button/message_nav_btn.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../utils/navigation_util.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/rounded_background_icon.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
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

  // Stack(
  // children: <Widget>[
  // _backgroundScreen(),
  // Column(
  // children: [
  // Expanded(child: _foregroundScreen()),
  // ],
  // ),
  // ],
  // ),

  Widget _backgroundScreen() {
    if (userBloc.user.type!.toLowerCase() == 'user') {
      if (userBloc.user.wallpaper == null || userBloc.user.wallpaper == "") {
        return Container(
          child: Image.asset(
            "assets/images/home_screen_background.png",
            frameBuilder: imageFrameBuilder,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      if (userBloc.user.userAbout == null ||
          userBloc.user.userAbout!.wallpaper == "") {
        return Container(
          child: Image.asset(
            "assets/images/home_screen_background.png",
            frameBuilder: imageFrameBuilder,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: new BorderRadius.vertical(
          bottom: new Radius.elliptical(100.0.w, 50.0)),
      child: Container(
        color: navyBlue,
        width: 100.0.w,
        height: 33.0.h,
        child: CachedNetworkImage(
          imageUrl: userBloc.user.type == 'User'
              ? userBloc.user.wallpaper!
              : userBloc.user.userAbout!.wallpaper,
          fit: BoxFit.cover,
          color: blackFont.withOpacity(0.4),
          colorBlendMode: BlendMode.darken,
          filterQuality: FilterQuality.high,
          errorWidget: wallpaperErrorWidget,
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
            flex: MediaQuery.of(context).size.height > 600 ? 9 : 50,
            child: Column(
              children: <Widget>[
                Container(height: 10),
                _appBar(),
                flexibleSpace(),
                _displayUserInfo(),
                flexibleSpace(),
                _displayPaymentButtons(),
              ],
            ),
          ),
          flexibleSpace()
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
      leading: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: userBloc.user.avatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            getGreetingMessage(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HexColor("#151515")),
          ),
          userNameWithVerifiedIcon(
            name: userBloc.user.displayName()!,
            isVerified: userBloc.user.isVerified,
            textStyle: TextStyle(fontSize: 16, color: HexColor("#151515")),
          ),
        ],
      ),
      actions: <Widget>[
        _searchBtn(),
        SizedBox(width: 8.0),
        _cartBtn(),
        SizedBox(width: 4.0),
        _messageBtn(),
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
                  child: Icon(SlydoAppIcon.search, size: 16, color: HexColor("#151515"),),
                  onTap: () async {
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

  Widget _messageBtn() {
    return Container(
      key: tutorialMessageKey,
      child: MessageNavBtn(
        key: UniqueKey(),
      ),
    );
  }

  Widget _cartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      key: tutorialShoppingCartKey,
      icon: Badge(
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: getBadgeContent(),
        padding: basketBloc.items.length == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.only(
                left: getBadgeCount().length == 1 ? 6 : 8,
                right: 6,
                top: 4,
                bottom: 4),
        position:
            BadgePosition(end: getBadgeCount().length == 1 ? -5 : -10, top: 0),
        child: Icon(
          Icons.shopping_cart_rounded,
          size: 16,
          color: HexColor("#151515"),
        ),
      ),
      onTap: () {
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

  Widget _displayUserInfo() {
    Color borderColor = getUserTypeColorByType(type: userBloc.user.type!);

    // return Container(
    //   key: tutorialQrCodeKey,
    //   alignment: Alignment.center,
    //   decoration: decorateBox(),
    //   child: CachedNetworkImage(
    //     height: MediaQuery.of(context).size.width / 1.7,
    //     width: MediaQuery.of(context).size.width / 1.7,
    //     imageUrl: userBloc.user.qrCode!,
    //     colorBlendMode: BlendMode.darken,
    //     fit: BoxFit.fill,
    //     errorWidget: imageErrorWidget,
    //     filterQuality: FilterQuality.high,
    //     placeholder: (context, url) => Center(
    //       child: CircularLoadingIndicator(),
    //     ),
    //   ),
    // );

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      elevation: 0.0,
      child: Container(
        decoration: decorateBox(),
        child: Container(
          margin: EdgeInsets.all(10),
          key: tutorialQrCodeKey,
          child: CachedNetworkImage(
            height: MediaQuery.of(context).size.width / 1.7,
            width: MediaQuery.of(context).size.width / 1.7,
            imageUrl: userBloc.user.qrCode!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            errorWidget: imageErrorWidget,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => Center(
              child: CircularLoadingIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayPaymentButtons() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: MediaQuery.of(context).size.height > 600 ? 16 : 8,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            key: tutorialRequestPaymentKey,
            child: Container(
              child: _requestPaymentButton(),
            ),
          ),
          Expanded(
            key: tutorialSendPaymentKey,
            child: Container(
              child: _sendPaymentButton(),
            ),
          ),
          Expanded(
            child: Container(
              child: _scanButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: InkWell(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  SlydoAppIcon.receive,
                  size: 20,
                  color: navyBlue,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                appLocalization.request,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            if (getIt<AppConfigurationBloc>()
                    .appConfigurationModel
                    ?.enablePayment ==
                true) {
              Navigator.of(context)
                  .pushNamed(Routes.REQUEST_PAYMENT, arguments: <String, bool>{
                'isFromProfile': true,
              });
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          }),
    );
  }

  Widget _sendPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  SlydoAppIcon.send,
                  size: 20,
                  color: naturalGreen,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                appLocalization.send,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            if (getIt<AppConfigurationBloc>()
                    .appConfigurationModel
                    ?.enablePayment ==
                true) {
              Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
                  arguments: <String, bool>{'isFromProfile': true});
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          }),
    );
  }

  Widget _scanButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  SlydoAppIconNew.scan,
                  size: 20,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                "Scan",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            NavigationUtil.push(context,
                screen: QRCodeView(arguments: {'isRequest': false}));
          }),
    );
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
