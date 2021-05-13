import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/services/local_notification_helper.dart';
import 'package:Slydo/services/local_notification_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// for implementing flutter local notification
/// https://github.com/FirebaseExtended/flutterfire/issues/1590

Future<dynamic> fcmBackgroundMessageHandler(message) async {
// await Firebase.initializeApp();
  debugPrint("onBackgroundMessage: $message");

  try {
// creating notification from server payload
// var notification = Platform.isAndroid
//     ? getAndroidNotification(message)
//     : getIosNotification(message);
// debugPrint("Notification From OnResume:  $notification");
//
    await LocalNotificationService().init();

    showOngoingNotification(
        LocalNotificationService().flutterLocalNotificationsPlugin,
        title: "Hello",
        body: "Slydo");
  } catch (error) {
    debugPrint("ERROR IN BACKGROUND HANDLER : - $error");
  }
}

class PushNotificationService {
  static FirebaseMessaging _fcm = FirebaseMessaging();
  static AuthService _auth = AuthService();
  static DatabaseHelper _db = DatabaseHelper();

  FirebaseMessaging get fcm => _fcm;

  Future login() async {
    //to stop automatically recreates the token when we deregister user in logout
    _fcm.setAutoInitEnabled(false);

    var data = await getDeviceInfo();
    _fcm.getToken().then((String token) async {
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
      // request permissions if we're on android
      _fcm.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));

      _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        // debugPrint("Settings registered: $settings");
      });
      _fcm.getToken().then((String token) {
        // debugPrint("firebase IOS token : $token");
      });
    }

    _fcm.configure(
        // Called when the app is in the foreground and we receive a push notification
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          // creating notification from server payload
          var notification = Platform.isAndroid
              ? getAndroidNotification(message)
              : getIosNotification(message);

          print("Notification From onMessage:  $notification");

          ///{body: Slydo Nudge Message,
          /// title: Slydo Notification,
          /// vibrate: [200,100,200,100,200,100,400],
          /// icon: null,
          /// badge: null,
          /// sound: null, link: null,
          /// tag: null, dir: auto,
          /// actions: /chat-screen/brijesh.sakariya,
          /// image: null, data: {"type":"nudge_user"}}

          if (notification["data"] != null) {
            print("notification data = ${notification["data"]}");
            print("notification data type = ${notification["data"] is String}");
            MainSocketMessageHandler(message: notification["data"]);
          }

          showAlertMessage(
              notification: notification,
              context: myGlobals.scaffoldKey.currentContext);
        },

        // Called when the app has been closed completely and it's opened
        // from the push notification.
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");

          // // creating notification from server payload
          // var notification = Platform.isAndroid
          //     ? getAndroidNotification(message)
          //     : getIosNotification(message);
          //
          // print("Notification From onLaunch:  $notification");
          //
          // //navigate to the particular screen
          // _navigateToItemDetail(
          //     notification, myGlobals.scaffoldKey.currentContext);
        },
        // Called when the app is in the background and it's opened
        // from the push notification.
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");

          // // creating notification from server payload
          // var notification = Platform.isAndroid
          //     ? getAndroidNotification(message)
          //     : getIosNotification(message);
          //
          // print("Notification From OnResume:  $notification");
          //
          // //navigate to the particular screen
          // _navigateToItemDetail(
          //     notification, myGlobals.scaffoldKey.currentContext);
        },
        onBackgroundMessage: fcmBackgroundMessageHandler);
  }

  // ignore: missing_return
  void onSelectNotification(String payload, BuildContext context) async {
    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}
    try {
      debugPrint("payload : $payload");
      if (payload == "/request-payment") {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        DashboardBloc _dashboardBloc =
            Provider.of<DashboardBloc>(context, listen: false);
        _dashboardBloc.index = 1;
      } else if (payload == "/transaction") {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed('/transactions');
      } else if (payload == "/connection-request") {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context)
            .pushNamed('/friends-dashboard', arguments: {"index": 1});
      } else if (payload == "/friends-dashboard") {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context)
            .pushNamed('/friends-dashboard', arguments: {"index": 0});
      } else if (payload.length > 15 &&
          payload.substring(0, 16) == "/detail_message/") {
        //this variable will fetch the id of message from the response
        String idOfMessage = payload.replaceAll("/detail_message/", "");
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed('/detail_message', arguments: {
          'id': idOfMessage,
        });
      } else if (payload.length > 13 &&
          payload.substring(0, 13) == "/chat-screen/") {
        //this variable will fetch the username of the recipient
        String recipientUsername = payload.replaceAll("/chat-screen/", "");
        print("Recipient user name = $recipientUsername");

        if (recipientUsername != null) {
          showDialog(
              context: context,
              builder: (context) => Center(child: CircularLoadingIndicator()));

          ChatConversation chatConversation =
              await UserAuth().fetchContactProfile(recipientUsername);

          if (chatConversation == null) {
            Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
            return;
          }
          Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
          Navigator.pushNamed(context, '/chat-screen',
              arguments: {"searchedUser": chatConversation});
        }
      }
    } catch (error) {
      print("new error:- $error");
    }
  }

  void _navigateToItemDetail(
      Map<String, dynamic> notification, BuildContext context) async {
    print("navigate function is called");
    onSelectNotification(notification['actions'], context);
  }

  Future<bool> logout() async {
    debugPrint("logout called!");
    bool result;
    try {
      result = await _fcm.deleteInstanceID();
    } catch (e) {
      debugPrint("logout error:- $e");
    }

    debugPrint("LOGOUT=====> $result");
    return result;
  }

  void showAlertMessage(
      {Map<String, dynamic> notification, BuildContext context}) async {
    print("Notification From onMessage:  $notification");
    // show the notification in the dialog
    bool result = await showDialogBoxWithImage(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: false,
      title: notification['title'],
      description: notification['body'],
      image: notification['image'],
      actionOne: AppLocalization.of(context).cancel,
      actionTwo: "View",
    );
    if (result) {
      _navigateToItemDetail(notification, context);
    }
  }
}

Map<String, dynamic> getAndroidNotification(Map<String, dynamic> message) {
  Map<String, dynamic> notification = {};
  notification["body"] = message['notification']['body'] ?? "Hello";
  notification["title"] = message['notification']['title'];
  notification["vibrate"] = message['data']['vibrate'];
  notification["icon"] = message['data']['icon'];
  notification["badge"] = message['data']['badge'];
  notification["sound"] = message['data']['sound'];
  notification["link"] = message['data']['link'];
  notification["tag"] = message['data']['tag'];
  notification["dir"] = message['data']['dir'];
  notification["actions"] = message['data']['actions'];
  notification['image'] = message['data']['image'];

  notification["data"] = message['data']['data'];

  print("notification from android $notification");
  return notification;
}

Map<String, dynamic> getIosNotification(Map<String, dynamic> message) {
  Map<String, dynamic> notification = {};
  notification["body"] = message['notification']['body'];
  notification["title"] = message['notification']['title'];
  notification["vibrate"] = message['vibrate'];
  notification["icon"] = message['notification']['icon'];
  notification["tag"] = message['notification']['tag'];
  notification["dir"] = message['dir'];
  notification["actions"] = message['actions'];
  notification['image'] = message['image'];
  debugPrint("notification from IOS $notification");
  return notification;
}
