import 'dart:io';

import 'package:Slydo/models/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationWidget extends StatefulWidget {
  @override
  _PushNotificationWidgetState createState() => _PushNotificationWidgetState();
}

class _PushNotificationWidgetState extends State<PushNotificationWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<PushNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];

        setState(() {
          notifications.add(PushNotification(
              title: notification['title'],
              body: notification['body'],
              image: notification['image']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        final notification = message['notification'];
        setState(() {
          notifications.add(PushNotification(
            title: '${notification['title']}',
            body: '${notification['body']}',
            image: '${notification['image']}',
          ));
        });
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _navigateToItemDetail(message);
      },
    );
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    }
  }

//  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//    if (message.containsKey('data')) {
//      // Handle data message
//      final dynamic data = message['data'];
//    }
//
//    if (message.containsKey('notification')) {
//      // Handle notification message
//      final dynamic notification = message['notification'];
//      setState(() {
//        notifications.add(PushNotification(
//          title: '${notification['title']}',
//          body: '${notification['body']}',
//          image: '${notification['image']}',
//        ));
//      });
//    }

  // Or do other work.
//  }

  Future<Null> _navigateToItemDetail(Map<String, dynamic> message) async {
    // When user clicks on the notification we can inspect message
    // then redirect user to right screen but for now we have just transactions
    //so we redirect to transactions
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    Navigator.of(context).pushNamed('/transactions');
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: notifications.map(buildMessage).toList(),
      );

  Widget buildMessage(PushNotification notification) => ListTile(
        leading: Image.network(notification.image),
        title: Text(notification.title),
        subtitle: Text(notification.body),
      );
}
