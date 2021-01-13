import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_shopping_cart.dart';
import 'package:Slydo/screens/search_module.dart';
import 'package:Slydo/screens/user_dashboard.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import 'home.dart';
import 'more_apps/payment_and_banking/screens/payment/request_payments_list.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  var arguments;

  Dashboard({this.arguments});

  @override
  _DashboardState createState() => _DashboardState(arguments: arguments);
}

class _DashboardState extends State<Dashboard> {
  //newUI Variables
  DashboardBloc _dashboardBloc;

  int _currentIndex = 0;
  var arguments;
  List<Widget> screens;
  BasketBloc basketBloc;

  _DashboardState({this.arguments});

  @override
  void initState() {
    if (mounted) {
      setState(() {
        if (arguments != null) {
          int indexFromRoute = arguments['dashboardIndex'];

          if (indexFromRoute != null) {
            setState(() {
              _currentIndex = indexFromRoute;
            });
          }
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MainSocketProvider mainSocketProvider =
          Provider.of<MainSocketProvider>(context, listen: false);

      mainSocketProvider.listen((event) {
        Map<String, dynamic> decodeMessage = jsonDecode(event);
        if (mainSocketProvider.currentConversationId !=
            decodeMessage["conversation"]) {
          MainSocketMessageHandler(message: event);
          if (mounted) setState(() {});
        } else {
          debugPrint(
              "Got Message current conversation:-${mainSocketProvider.currentConversationId} message conversation:- ${decodeMessage["conversation"]}");
        }
      });
    });

    super.initState();
  }

  Widget goToBasket() {
    return Badge(
      badgeColor: Colors.green,
      animationType: BadgeAnimationType.slide,
      badgeContent: getBadgeContent(),
      padding:
          basketBloc.items.length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(end: 6, top: 6),
      // ignore: required onPressed
      child: Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
    );
  }

  Widget getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'];
    });
    return totalItem;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    if (_currentIndex != 0) {
      _dashboardBloc.index = _currentIndex;
      _currentIndex = 0;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_dashboardBloc.index == 0) {
          bool result = await showDialogBox(
            context: context,
            actionOneBgColor: mateRed,
            actionOneTextColor: Colors.white,
            actionTwoBgColor: greyBorderColor,
            actionTwoTextColor: blackFont,
            title: "Exit app",
            description: "Are you sure want to exit app?",
            actionOne: AppLocalization.of(context).exit,
            actionTwo: AppLocalization.of(context).cancel,
          );
          if (result) {
            SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
          }
        }

        if (_dashboardBloc.index != 0) {
          if (mounted) {
            setState(() {
              _dashboardBloc.index = 0;
            });
          }
        }
        return false;
      },
      child: Scaffold(
        key: myGlobals.scaffoldKey,
        backgroundColor: whiteBackground,
        body: PageView(
          controller: _dashboardBloc.pageController,
          onPageChanged: (index) {
            _dashboardBloc.index = index;
          },
          children: <Widget>[
            Home(),
            PaymentRequestList(),
            SearchModule(),
            ShoppingCart(),
            UserDashboard(),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        iconSize: 0,
        unselectedFontSize: 10,
        showSelectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 10,
        currentIndex: _dashboardBloc.index,
        onTap: (index) {
          _dashboardBloc.index = index;
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.home,
            title: AppLocalization.of(context).home,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.receive,
            title: AppLocalization.of(context).requests,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context).search,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.cart,
            title: AppLocalization.of(context).basket,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: AppLocalization.of(context).explore,
          ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {IconData icon, String title}) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 50,
        width: 60,
        child: Icon(
          icon,
          color: blackFont,
          size: 16,
        ),
      ),
      label: "",
      activeIcon: activeIcon(icon: icon, title: title),
    );
  }

  // How BottomNavigationBarItem will look when active
  Widget activeIcon({IconData icon, String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        width: 60,
        color: navyBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 4,
            ),
            Expanded(
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
