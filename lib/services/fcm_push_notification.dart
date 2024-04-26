import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_detail_page.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/shipping_process/utils.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/more_apps/yarn/models/Topics/yarn_model.dart';
import '../screens/more_apps/yarn/yarn_detail_screen.dart';

bool isDialogueOpen = false;

Future<void> fcmBackgroundMessageHandler(RemoteMessage remoteMessage) async {
// await Firebase.initializeApp();

  try {
    /// {data:
    /// {priority: high,
    /// actions: /chat-screen/9ae68069-b342-4e04-b568-602bde6fe901,
    /// body: Slydo Nudge Message,
    /// data:
    /// {"conversation_id":"9ae68069-b342-4e04-b568-602bde6fe901",
    /// "author":"brijesh.sakariya",
    /// "recipient":"black",
    /// "check_id":"2b312f4e-86aa-42e3-9972-b33f2d3d2fbd",
    /// "created_at":"2021-05-19 11:01:02.661721+00:00local",
    /// "type":"nudge_user",
    /// "author_avatar":null},
    /// title: Slydo Notification}}

    final Map<String, dynamic> data = {};

    final Map<String, dynamic> notification =
        remoteMessage.data["notification"] != null
            ? jsonDecode(remoteMessage.data["notification"])
            : {};

    if (notification.isEmpty) {
      return;
    }

    AppConfig();

    AwesomeNotificationService().init();

    final Map<String, dynamic> dataOfNotification = Platform.isIOS
        ? decodeNotificationIOS(remoteMessage.data)
        : decodeNotification(remoteMessage.data);

    debugPrint("DATA:----- $dataOfNotification");
    //If {dataOfNotification['data'] != null} this is true, the app will send local notification else the app sends a push notification.

    if (dataOfNotification['data'] != null &&
        dataOfNotification["data"]["type"] != null &&
        (dataOfNotification["data"]['type'] == "chatroom_message" ||
            dataOfNotification["data"]['type'] == "nudge_user" ||
            dataOfNotification["data"]['type'] == "acknowledge_message")) {
      data['data'] = dataOfNotification['data'] is Map
          ? dataOfNotification['data']
          : jsonDecode(dataOfNotification['data']);

      if (data['data']['type'] == "nudge_user") {
        data['actions'] = notification['actions'];
        data['body'] = notification['body'];
        data['title'] = notification['title'];

        AwesomeNotificationService().showNudgeNotification(message: data);
      } else if (data['data']['type'] == "chatroom_message") {
        data['notification'] = notification;

        final ChatMessage textMessage = ChatMessage.fromJson(data['data']);

        final int result =
            await ChatMessageHandler().addChatMessage(chatMessage: textMessage);

        if (result == 1) {
          final int? time =
              convertStringToMillisecondsSinceEpoch(textMessage.createdAt);

          final String? conversationId = textMessage.conversationId;

          /// move user to top of the list in the connection list
          await ConnectionListManager().updateLastMessageTime(
              conversationId: conversationId, time: time);

          final String hashedMessage =
              generateHashedMessage(jsonEncode(data['data']));

          log("====> UPDATE CHAT USER MESSAGE COUNT FROM FCM");

          /// update the message count
          await ChatUserManager().updateChatUserMessageCount(
            conversationId: conversationId,
            hashedMessage: hashedMessage,
          );

          /// send acknowledgement to server
          MainSocketMessageHandler()
              .sendAcknowledgementOfMessageWithCheckingAuthor(
                  chatMessage: textMessage);

          AwesomeNotificationService().showNotification(message: data);
        }
      } else if (data['data']['type'] == "acknowledge_message") {
        final Map<String, dynamic> messageData =
            dataOfNotification['data'] is Map
                ? dataOfNotification['data']
                : jsonDecode(dataOfNotification['data']);

        /// set delivery status true for the message
        MainSocketMessageHandler()
            .handleAcknowledgementMessage(messageData: messageData);
      }

      AwesomeNotificationService().showNotification(message: data);
    } else if (notification["data"] != null &&
        notification["data"]["alert_type"] != null &&
        (notification["data"]["alert_type"] ==
                "payment_request_in_shared_cart" ||
            notification["data"]["alert_type"] == "added_to_new_shared_cart")) {
      data['data'] = dataOfNotification['data'] is Map
          ? dataOfNotification['data']
          : jsonDecode(dataOfNotification['data']);

      AwesomeNotificationService().showNotification(message: data);
    }
    // Here is the push notification.
    else {
      data['notification'] = notification;

      final String action = data['notification']['actions'] ??
          data['notification']['click_action'] ??
          "";

      debugPrint('ACTION NOTI -> $action');
      if (action == "/transaction") {
        data['data'] = {"type": "transaction"};
      } else if (action.contains('/moment')) {
        debugPrint('FRANK body !--> ${data['body']}');
        data['data'] = {"type": action};
      } else if (action == Routes.REQUEST_PAYMENT) {
        data['data'] = {"type": "request-payment"};
      } else if (action == "/connection-request") {
        data['data'] = {"type": "connection-request"};
      } else if (action == Routes.FRIENDS_DASHBOARD) {
        data['data'] = {"type": "friends-dashboard"};
      } else if (action.toString().contains("/detail_message/")) {
        data['data'] = {"type": "detail_message"};
      } else if (action.toString().contains("/orders-list")) {
        data['data'] = {"type": "orders-list"};
      } else if (action.toString().contains("/order-detail-page/")) {
        data['data'] = {"type": "order-detail-page"};
      } else if (action.toString().contains("/shared-cart/")) {
        data['data'] = {"type": "accounts"};
      } else if (action.toString().contains("/new-shared-cart/")) {
        data['data'] = {"type": "shopping-cart"};
      } else {
        debugPrint("UNKNOWN NOTIFICATION TYPE $remoteMessage");
        return;
      }
      AwesomeNotificationService().showNotification(message: data);
    }
  } catch (error) {
    debugPrint("Error $error");
  }

  return Future<void>.value();
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final AuthService _auth = AuthService();
  static final DatabaseHelper _db = DatabaseHelper();
  StreamSubscription? streamListen;

  static final PushNotificationService _singleton =
      PushNotificationService._internal();

  factory PushNotificationService() {
    return _singleton;
  }

  PushNotificationService._internal();

  FirebaseMessaging get fcm => _fcm;

  Future<void> initialize() async {
    //to stop automatically recreates the token when we deregister user in logout
    _fcm.setAutoInitEnabled(false);

    if (Platform.isIOS) {
      // request permissions if we're on android
      _fcm.requestPermission(sound: true, badge: true, alert: true);

      // _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      //   // debugPrint("Settings registered: $settings");
      // });
    }

    final data = await getDeviceInfo();
    await _fcm.getToken().then((String? token) async {
      data["token"] = token;

      // this piece of code convert Map<dynamic,dynamic> data to Map<String,String> tempData
      // so we can store that data into database
      final Map<String, dynamic> tempData = Map<String, dynamic>();
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

    /// onMessage:
    /// {notification: {"image":"https:\/\/slydo-assets.s3.amazonaws.com\/media\/customer\/avatar\/4f4470b6dbf44b62859ddf2b945d7472.jpg",
    /// "body":"User Updated Order Status","title":"Order Update",
    /// "priority":"normal","actions":"\/orders\/52"}}

    await streamListen?.cancel();

    streamListen =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // creating notification from server payload
      final Map<String, dynamic> notification = Platform.isIOS
          ? decodeNotificationIOS(message.data)
          : decodeNotification(message.data);

      debugPrint('FRANK NOTI DATA ---> ${notification["data"]}');

      if (notification["data"] != null &&
          notification["data"]["type"] != null &&
          (notification["data"]['type'] == "chatroom_message" ||
              notification["data"]['type'] == "nudge_user" ||
              notification["data"]['type'] == "acknowledge_message")) {
        Map<String, dynamic>? decodeMessage;
        try {
          decodeMessage = notification["data"] is Map
              ? notification["data"]
              : jsonDecode(notification["data"]);

          debugPrint('FRANK DECODED MESSAGE ---> $decodeMessage');
        } catch (error) {
          debugPrint("ERROR:- while adding data to db from FCM $notification");
        }
        if (decodeMessage != null) {
          if (decodeMessage.isNotEmpty) {
            MainSocketMessageHandler(
                message: jsonEncode(decodeMessage), isFCMMessage: true);
          }
        }
      } else if (notification["data"] != null &&
          notification["data"]["alert_type"] != null &&
          (notification["data"]["alert_type"] ==
                  "payment_request_in_shared_cart" ||
              notification["data"]["alert_type"] ==
                  "added_to_new_shared_cart")) {
        ///{notification: {"image":"http:\/\/cdn.slydo.co.global.prod.fastly.net\/media\/customer\/avatar\/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg","body":"Received \u20A61.00","title":"Payment Received","priority":"normal","actions":"\/transaction"}}
        ///notification from android {body: You have been added to shared cart, title: Cart Update, actions: /new-shared-cart/f581604c-dcfb-45e7-a2e4-82e91d25e133, image: http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg, data: {cart_id: f581604c-dcfb-45e7-a2e4-82e91d25e133, cart_name: new cart 1, alert_type: added_to_new_shared_cart}}
        ///notification from android {body: You have a payment request for your cart., title: Cart Update, actions: /shared-cart/3bb7ee85-b5f9-48d8-affa-cf193ed66361, image: http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg, data: {cart_id: 3bb7ee85-b5f9-48d8-affa-cf193ed66361, amount: 480.0, cart_name: Test Cart, currency: ₦, alert_type: payment_request_in_shared_cart}}
        ///{notification: {"image":"http:\/\/cdn.slydo.co.global.prod.fastly.net\/media\/customer\/avatar\/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg","body":"User Placed An Order.","title":"Order Created","priority":"normal","actions":"\/orders-list"}}
        switch (notification["data"]["alert_type"]) {
          case 'payment_request_in_shared_cart':
            if (isDialogueOpen) {
              Navigator.pop(myGlobals.scaffoldKey.currentContext!);
              isDialogueOpen = false;
            }
            if (!isDialogueOpen) {
              isDialogueOpen = true;
              // dialog for shared cart payment request
              final result = await buildCartPaymentRequestDialog(
                  context: myGlobals.scaffoldKey.currentContext!,
                  notification: notification);

              if (result != null && result && result == true) {
                isDialogueOpen = false;
              } else {
                isDialogueOpen = false;
              }
            }
            break;
          case 'added_to_new_shared_cart':
            if (isDialogueOpen) {
              Navigator.pop(myGlobals.scaffoldKey.currentContext!);
              isDialogueOpen = false;
            }
            if (!isDialogueOpen) {
              isDialogueOpen = true;
              // dialog for new shared cart created
              final result = await buildNewCartAlertDialog(
                  context: myGlobals.scaffoldKey.currentContext!,
                  notification: notification);

              if (result != null && result && result == true) {
                isDialogueOpen = false;
              } else {
                isDialogueOpen = false;
              }
            }
            break;
          default:
        }
      } else {
        debugPrint('FRANK ELSE BLOCK LINE 265 ---> $notification');

        if ((notification["body"].toString().toLowerCase() == "hello" ||
                    notification["body"].toString().toLowerCase() == "null") &&
                notification['title'] == "" ||
            notification["body"] == "" && notification['title'] == "") {
          return;
        }
        if (notification["actions"].toString().contains('/moment/')) return;

        if (isDialogueOpen) {
          debugPrint('FRANK DIALOG OPEN');

          Navigator.pop(myGlobals.scaffoldKey.currentContext!);
          isDialogueOpen = false;
        }
        if (!isDialogueOpen) {
          debugPrint('FRANK DIALOG NOT OPEN');

          log("BLACK LOG => $notification");

          Future.delayed(const Duration(seconds: 3), () {
            showAlertMessage(
                notification: notification,
                context: myGlobals.scaffoldKey.currentContext!);
          });
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // creating notification from server payload
      // var notification = Platform.isAndroid
      //     ? getAndroidNotification(message.data)
      //     : getIosNotification(message.data);
      final Map<String, dynamic> notification = Platform.isIOS
          ? decodeNotificationIOS(message.data)
          : decodeNotification(message.data);

      //navigate to the particular screen
      _navigateToItemDetail(notification, myGlobals.scaffoldKey.currentContext);
    });

    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
  }

  // ignore: missing_return
  // This is for the Firebase Push Notification
  void onSelectNotification(String? payload, BuildContext? context,
      Map<String, dynamic> notification) async {
    debugPrint("showing payload : $payload");

    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, `link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}

    try {
      debugPrint("payload : $payload");
      if (payload == Routes.REQUEST_PAYMENT) {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        NavigationUtil.pushNamed(context, routeName: Routes.ACCOUNTS);
      } else if (payload == Routes.INVOICE_SCREEN) {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed(Routes.INVOICE_SCREEN);
      } else if (payload == '/contracts') {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed(Routes.CONTRACT_SCREEN);
      } else if (payload == "/transaction") {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context)
            .pushNamed(Routes.TRANSACTIONS, arguments: {'page': 0});
      } else if (payload == "/connection-request") {
        final DashboardBloc dashboardBloc = Provider.of<DashboardBloc>(
            context ?? myGlobals.navigationKey.currentContext!,
            listen: false);
        dashboardBloc.index = 3;
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));

        // Navigator.of(context)
        //     .pushNamed('/friends-dashboard', arguments: {"index": 1});
      } else if (payload == "/friends-dashboard") {
        final DashboardBloc dashboardBloc = Provider.of<DashboardBloc>(
            context ?? myGlobals.navigationKey.currentContext!,
            listen: false);
        dashboardBloc.index = 3;
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        // Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        // Navigator.of(context)
        //     .pushNamed('/friends-dashboard', arguments: {"index": 0});
      } else if (payload!.length > 15 &&
          payload.substring(0, 16) == "/detail_message/") {
        //this variable will fetch the id of message from the response
        final String idOfMessage = payload.replaceAll("/detail_message/", "");
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed('/detail_message', arguments: {
          'id': idOfMessage,
        });
      } else if (payload.length > 13 &&
          payload.substring(0, 13) == "/chat-screen/") {
        //this variable will fetch the username of the recipient
        final String? recipientUsername =
            payload.replaceAll("/chat-screen/", "");

        if (recipientUsername != null) {
          showDialog(
              context: context!,
              builder: (context) => Center(child: CircularLoadingIndicator()));

          final ChatConversation? chatConversation =
              await UserAuth().fetchContactProfile(recipientUsername);

          if (chatConversation == null) {
            Navigator.of(context)
                .popUntil(ModalRoute.withName(Routes.DASHBOARD));
            return;
          } else {
            Navigator.of(context)
                .popUntil(ModalRoute.withName(Routes.DASHBOARD));
            Navigator.pushNamed(context, '/chat-screen',
                arguments: {"searchedUser": chatConversation});
          }
        }
      } else if (payload.toString().contains("orders-list")) {
        Navigator.of(context!).popUntil(ModalRoute.withName(Routes.DASHBOARD));
        Navigator.of(context).pushNamed('/orders-list');
      } else if (payload.toString().contains("order-detail-page")) {
        final Order order = Order.fromJson(notification["data"]);

        Navigator.of(context!).pushNamed(Routes.ORDER_DETAIL_PAGE, arguments: {
          'order': order,
        });
      } else if (payload.toString().contains('/moment/')) {
        debugPrint('FRANK MOMENT ---> ${notification["data"]}');
        final MomentsModel momentsModel =
            MomentsModel.fromJson(notification['data']);
        NavigationUtil.push(context!,
            screen: MomentsDetailsScreen(
              indexOfMoment: 0,
              momentsModelList: [
                [momentsModel]
              ],
            ));
      } else if (payload.toString().contains('/yarn/')) {
        final String yarnId = payload.toString().replaceAll("/yarn/", "");
        NavigationUtil.push(context!,
            screen: YarnDetailScreen(
              yarn: Yarn(),
              yarnId: yarnId,
            ));
      } else if (payload.toString().contains('/shared-cart/')) {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed(Routes.ACCOUNTS);
      } else if (payload.toString().contains('/new-shared-cart/')) {
        Navigator.of(context!).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed(Routes.SHOPPING_CART);
      }
    } catch (error) {
      debugPrint("Error $error");
    }
  }

  void _navigateToItemDetail(
      Map<String, dynamic> notification, BuildContext? context) async {
    onSelectNotification(notification['actions'], context, notification);
  }

  Future<void> logout() async {
    debugPrint("logout called!");

    try {
      await FirebaseMessaging.instance.deleteToken();
      await streamListen?.cancel();
    } catch (e) {
      debugPrint("logout error:- $e");
    }

    debugPrint("LOGOUT=====>");
  }

  void showAlertMessage(
      {required Map<String, dynamic> notification,
      required BuildContext context}) async {
    debugPrint("====> $notification");
    // show the notification in the dialog
    isDialogueOpen = true;
    final bool? result = await showDialogBoxWithImage(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: false,
      title: notification['title'],
      description: notification['body'],
      image: notification['image'],
      actionOne: AppLocalization.of(context)!.cancel,
      actionTwo: "View",
    );

    if (result != null) {
      if (result) {
        isDialogueOpen = false;
        _navigateToItemDetail(notification, context);
      } else {
        isDialogueOpen = false;
      }
    }
  }
}

Map<String, dynamic> decodeNotification(Map<String, dynamic> message) {
  debugPrint("DATA:- $message");
  final Map<String, dynamic> notification = {};
  final Map<String, dynamic> decodeNotification =
      jsonDecode(message["notification"]);
  notification["body"] = decodeNotification["body"] ?? "";
  notification["title"] = decodeNotification["title"] ?? "";
  notification["actions"] =
      decodeNotification["actions"] ?? decodeNotification["click_action"] ?? "";
  notification['image'] = decodeNotification['image'];

  if (message["data"] != null) {
    final Map<String, dynamic> decodedInnerData =
        message["data"] is Map ? message["data"] : jsonDecode(message["data"]);
    notification["data"] = decodedInnerData;
  }

  try {
    if (message["data"] != null &&
        message['data'] is Map &&
        (message['data'] as Map)['notification'] != null) {
      final Map<String, dynamic> notificationFromMessage =
          jsonDecode(message['data']['notification']);

      notification["body"] = notificationFromMessage['body'] ?? "";
      notification["title"] = notificationFromMessage['title'] ?? "";
      notification['image'] = notificationFromMessage['image'] ?? "";
      notification["actions"] = notificationFromMessage['actions'] ??
          notificationFromMessage["click_action"] ??
          "";
    }
  } catch (error) {
    debugPrint("ERROR11:- $error");
  }

  return notification;
}

Map<String, dynamic> decodeNotificationIOS(Map<String, dynamic> message) {
  debugPrint("DATA:- $message");
  final Map<String, dynamic> notification = {};

  notification["body"] = message["body"] ?? "";
  notification["title"] = message["title"] ?? "";
  notification["actions"] = message["actions"] ?? message["click_action"] ?? "";
  notification['image'] = message['image'];

  if (message["data"] != null) {
    final Map<String, dynamic> decodedInnerData =
        message["data"] is Map ? message["data"] : jsonDecode(message["data"]);
    notification["data"] = decodedInnerData;
  }

  try {
    if (message["data"] != null &&
        message['data'] is Map &&
        (message['data'] as Map)['notification'] != null) {
      final Map<String, dynamic> notificationFromMessage =
          jsonDecode(message['data']['notification']);

      notification["body"] = notificationFromMessage['body'] ?? "";
      notification["title"] = notificationFromMessage['title'] ?? "";
      notification['image'] = notificationFromMessage['image'] ?? "";
      notification["actions"] = notificationFromMessage["actions"] ??
          notificationFromMessage["click_action"] ??
          "";
    }
  } catch (error) {
    debugPrint("ERROR22:- $error");
  }

  return notification;
}

// Map<String, dynamic> getIosNotification(Map<String, dynamic> message) {
//   Map<String, dynamic> notification = {};
//   try {
//     Map<String, dynamic> notificationFromMessage =
//         jsonDecode(message['notification']);
//     notification["body"] = notificationFromMessage['body'] ?? "";
//     notification["title"] = notificationFromMessage['title'] ?? "";
//     notification["actions"] = notificationFromMessage['actions'];
//     notification['image'] = notificationFromMessage['image'];
//     debugPrint("notification from IOS $notification");
//   } catch (error) {
//     debugPrint("ERROR:- $error");
//   }
//   return notification;
// }
