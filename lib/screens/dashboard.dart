import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/messagelist.dart';
import 'package:Slydo/screens/search_auto_complete.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final _auth = AuthService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _DashboardState({this.arguments});

  // creating a instance of the databaseHelper
  DatabaseHelper _db = DatabaseHelper();

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
        SearchAutoComplete(),
        MessageList(),
        SettingsList(
          arguments: {'isLocked': isLocked},
        ),
      ];
    });

    setupNotification();
    super.initState();
  }

  // ignore: missing_return
  void onSelectNotification(String payload) {
    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}

    debugPrint("payload : $payload");
    if (payload == "/request-payment") {
      Navigator.of(context).pushNamed('/dashboard', arguments: {
        'dashboardIndex': 1,
      });
    } else if (payload == "/transaction") {
      Navigator.of(context).pushNamed('/dashboard', arguments: {
        'dashboardIndex': 2,
      });
    } else {
      //this variable will fetch the id of message from the response
      String idOfMessage = payload.replaceAll("/detail_message/", "");
      Navigator.of(context).pushNamed('/detail_message', arguments: {
        'id': idOfMessage,
      });
    }
  }

  void _navigateToItemDetail(Map<String, dynamic> notification) async {
    debugPrint("naviagate function is callled");
    onSelectNotification(notification['actions']);
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
            icon: Icon(Icons.search, color: Colors.white),
            title: Text('Search',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.email, color: Colors.white),
            title: Text('Messages',
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

  changeIndex(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void setupNotification() async {
    var data = await getDeviceInfo();
    _firebaseMessaging.getToken().then((String token) async {
      data["token"] = token;

      // this piece of code convert Map<dynamic,dynamic> data to Map<String,String> tempData
      // so we can store that data into database
      Map<String, dynamic> tempData = new Map<String, dynamic>();
      tempData['firebaseToken'] = data['token'];
      tempData['type'] = data['type'];
      tempData['mode'] = data['mode'];
      tempData['deviceId'] = data['device_id'];
      tempData['deviceName'] = data['device_name'];

      // delete device info to database
      await _db.deleteDevice();

      // save device info to database
      await _db.saveDevice(tempData);

      // register device with the backend
      await _auth.registerDevice(data);
    });

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    }

    _firebaseMessaging.configure(
      // onMessage will be called when App is running and also app is in foreground
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("onMessage: $message");
        // creating notification from server payload
        var notification = getAndroidNotification(message);

        debugPrint("Notification From onMessage:  $notification");

        // show the notification in the dialog
        showCuperDialog<String>(
          context: context,
          notification: notification,
          child: CupertinoDessertDialog(
            title: Text(notification['title'].toString()),
            content: Text(notification['body'].toString()),
          ),
        );
      },

      // onLaunch will be called when App is not running
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("onLaunch: $message");
        // creating notification from server payload
        var notification = getAndroidNotification(message);

        debugPrint("Notification From onLaunch:  $notification");

        //navigate to the particular screen
        _navigateToItemDetail(notification);
      },
      // onResume will be called when App is running and it is in background
      onResume: (Map<String, dynamic> message) async {
        debugPrint("onResume: $message");
        // creating notification from server payload
        var notification = getAndroidNotification(message);

        debugPrint("Notification From OnResume:  $notification");

        //navigate to the particular screen
        _navigateToItemDetail(notification);
      },
    );
  }

  void showCuperDialog<T>(
      {BuildContext context, Map<String, dynamic> notification, Widget child}) {
    showCupertinoDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((T value) {
      if (value != null) {
        if (value == "Navigate") {
          _navigateToItemDetail(notification);
        }
      }
    });
  }

  Map<String, dynamic> getAndroidNotification(Map<String, dynamic> message) {
    Map<String, dynamic> notification = {};
    notification["body"] = message['notification']['body'];
    notification["title"] = message['notification']['title'];
    notification["vibrate"] = message['data']['vibrate'];
    notification["icon"] = message['data']['icon'];
    notification["badge"] = message['data']['badge'];
    notification["sound"] = message['data']['sound'];
    notification["link"] = message['data']['link'];
    notification["tag"] = message['data']['tag'];
    notification["dir"] = message['data']['dir'];
    notification["actions"] = message['data']['actions'];
    debugPrint("notification from android getnotification $notification");
    return notification;
  }

  var note = '''
  {
    notification: 
    {
      title: Payment Received,
      body: NGN1: Received from pankaj.sakariya
    },
    data:
    {
      click_action: FLUTTER_NOTIFICATION_CLICK,
      actions: /transaction,
      dir: auto,
      vibrate: [200,100,200,100,200,100,400],
      icon : xyz,
      badge : xyz,
      sound : xyz,
      link : xyz,
      tag : xyz, 
     }
  }
  ''';
}

class CupertinoDessertDialog extends StatelessWidget {
  const CupertinoDessertDialog({Key key, this.title, this.content})
      : super(key: key);

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('Navigate to the page'),
          onPressed: () {
            Navigator.pop(context, 'Navigate');
          },
        ),
        CupertinoDialogAction(
          child: const Text('Cancel'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ],
    );
  }
}
