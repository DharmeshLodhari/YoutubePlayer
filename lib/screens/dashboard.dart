import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/models/notification.dart';
import 'package:Slydo/screens/messagelist.dart';
import 'package:Slydo/screens/search.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/widget/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final List<PushNotification> notifications = [];
  final localNotifications = FlutterLocalNotificationsPlugin();
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
        SearchAll(),
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

  // ignore: missing_return
  Future onSelectNotification(String payload) {
    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}

    print("payload : $payload");
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
    _firebaseMessaging.getToken().then((String token) {
      data["token"] = token;

      // this piece of code convert Map<dynamic,dynamic> data to Map<String,String> tempData
      // so we can store that data into database
      Map<String, dynamic> tempData = new Map<String, dynamic>();
      tempData['firebaseToken'] = data['token'];
      tempData['type'] = data['type'];
      tempData['mode'] = data['mode'];
      tempData['deviceId'] = data['device_id'];
      tempData['deviceName'] = data['device_name'];

      // save device info to database
      _db.saveDevice(tempData);

      // register device with the backend
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
        // creating notification from server payload
        var notification = getAndroidNotification(message);
        // it will show notification
        showOngoingNotification(localNotifications,
            title: notification['title'],
            body: notification['body'],
            payload: notification['actions']);
      },

      // onLaunch will be called when App is not running
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // creating notification from server payload
        var notification = getAndroidNotification(message);
        // it will show notification
        showOngoingNotification(localNotifications,
            title: notification['title'],
            body: notification['body'],
            payload: notification['actions']);
      },
      // onResume will be called when App is running and it is in background
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // creating notification from server payload
        var notification = getAndroidNotification(message);
        // it will show notification
        showOngoingNotification(localNotifications,
            title: notification['title'],
            body: notification['body'],
            payload: notification['actions']);
      },
    );
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
  }
}
