import 'dart:io';

import 'package:Slydo/models/notification.dart';
import 'package:Slydo/screens/messagelist.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/widget/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/colors.dart';
import 'profile.dart';
import 'request_payments_list.dart';
import 'settings.dart';
import 'transactions.dart';

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
  final List<PushNotification> notifications = [];
  final localNotifications = FlutterLocalNotificationsPlugin();
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
        Profile(),
        PaymentRequestList(),
        TransactionList(),
        MessageList(),
        SettingsList(
          arguments: {'isLocked': isLocked},
        ),
      ];
    });

    final settingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    localNotifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);

    setupNotification();
    super.initState();
  }

  Future onSelectNotification(String payload) async =>
      await Navigator.of(context).pushNamed('/dashboard', arguments: {
        'dashboardIndex': payload == '/transaction' ? 1 : 2,
      });

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

  Future<Null> _navigateToItemDetail(Map<String, dynamic> message) async {
    // When user clicks on the notification we can inspect message
    // then redirect user to right screen but for now we have just transactions
    //so we redirect to transactions
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    Navigator.of(context).pushNamed('/transactions');
  }

  void setupNotification() async {
    var data = await getDeviceInfo();
    _firebaseMessaging.getToken().then((String token) {
      data["token"] = token;
      _auth.registerDevice(data);
    });

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    }

    _firebaseMessaging.configure(
        // onMessage will be called when App is running and also app is in foreground
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");

//      creating notification from server payload
      var notification = !Platform.isIOS
          ? getAndroidNotification(message)
          : getIOSNotification(message);

      // it will show notification
      showOngoingNotification(
        localNotifications,
        title: notification['title'],
        body: notification['body'],
      );
    },

        // onLaunch will be called when App is not running
        onLaunch: (Map<String, dynamic> message) async {
      var notification = !Platform.isIOS
          ? getAndroidNotification(message)
          : getIOSNotification(message);

      showOngoingNotification(localNotifications,
          title: notification['title'], body: notification['body']);
    },
        // onResume will be called when App is running and it is in background
        onResume: (Map<String, dynamic> message) async {
      var notification = !Platform.isIOS
          ? getAndroidNotification(message)
          : getIOSNotification(message);

      showOngoingNotification(localNotifications,
          title: notification['title'], body: notification['body']);
    });
  }

  getIOSNotification(Map<String, dynamic> message) {
    var notification = message['aps'];
    print("notification from ios getnotification $notification");
    return notification;
    //"{aps: {"badge":"","alert":{"body":"Requesting #300","title":"Payment Request"},"sound":"default","icon":"https:\/\/image.com\/image.png","link":null,"vibrate":[200,100,200,100,200,100,400],"tag":"Slydo Notification","dir":"auto","actions":[]}, from: 580706438195}";
  }

  getAndroidNotification(Map<String, dynamic> message) {
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
    print("notification from android getnotification $notification");
    return notification;
    // {notification: {title: null, body: null}, data: {data: {"badge":"","sound":"","icon":"https:\/\/image.com\/image.png","link":null,"vibrate":[200,100,200,100,200,100,400],"tag":"Slydo Notification","body":"Requesting #300","dir":"auto","title":"Payment Request","actions":[]}}}
  }
}
