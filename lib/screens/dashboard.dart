import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/messagelist.dart';
import 'package:Slydo/screens/search_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/colors.dart';
import 'home.dart';
import 'request_payments_list.dart';
import 'settings.dart';
import 'transactions_list.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  var arguments;

  Dashboard({this.arguments});

  @override
  _DashboardState createState() => _DashboardState(arguments: arguments);
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  var arguments;
  static var isLocked = true;
  List<Widget> screens;

  _DashboardState({this.arguments});

  @override
  void initState() {
    setState(() {
      if (arguments != null) {
        int indexFromRoute = arguments['dashboardIndex'];
        isLocked = arguments['isLocked'] != null ? arguments['isLocked'] : true;
        if (indexFromRoute != null) {
          setState(() {
            _currentIndex = indexFromRoute;
          });
        }
      }
      screens = [
        Home(),
        PaymentRequestList(),
        TransactionList(),
        SearchModule(),
        MessageList(),
        SettingsList(
          arguments: {'isLocked': isLocked},
        ),
      ];
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: lightBlue(),
        fixedColor: lightBlue(),
        elevation: 0.0,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            title: Text(AppLocalization.of(context).home,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.notifications, color: Colors.white),
            title: Text(AppLocalization.of(context).requests,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.account_balance_wallet, color: Colors.white),
            title: Text(AppLocalization.of(context).transactions,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.search, color: Colors.white),
            title: Text(AppLocalization.of(context).search,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.email, color: Colors.white),
            title: Text(AppLocalization.of(context).messages,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.settings, color: Colors.white),
            title: Text(AppLocalization.of(context).settings,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  changeIndex(index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
