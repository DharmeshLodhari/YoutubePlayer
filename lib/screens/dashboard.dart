import 'package:Slydo/screens/explore.dart';
import 'package:flutter/material.dart';

import '../screens/colors.dart';
import 'profile.dart';
import 'request_payments_list.dart';
import 'settings.dart';
import 'transactions.dart';

class Dashboard extends StatefulWidget {
  var arguments;

  Dashboard({this.arguments});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    if (widget.arguments != null) {
      int indexFromRoute = widget.arguments['dashboardIndex'];
      if (indexFromRoute != null) {
        setState(() {
          _currentIndex = indexFromRoute;
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page(),
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
            title: Text('Home',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.notifications, color: Colors.white),
            title: Text('Requests',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.account_balance_wallet, color: Colors.white),
            title: Text('Transactions',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.explore, color: Colors.white),
            title: Text('Explore',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.settings, color: Colors.white),
            title: Text('Settings',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget page() {
    switch (_currentIndex) {
      case 0:
        return Profile();
        break;
      case 1:
        return PaymentRequestList();
        break;
      case 2:
        return TransactionList();
        break;
      case 3:
        return ExploreList();
        break;
      case 4:
        return SettingsList();
        break;
      default:
        return Profile();
    }
  }

  changeIndex(index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
