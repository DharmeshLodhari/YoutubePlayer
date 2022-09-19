import 'dart:async';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AwesomeNotificationService {
  static final AwesomeNotificationService _notificationService =
      AwesomeNotificationService._internal();

  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

  factory AwesomeNotificationService() {
    return _notificationService;
  }

  static StreamController<ReceivedAction>? _streamController;

  Stream? get notificationActionStream => _streamController?.stream;

  AwesomeNotificationService._internal();

  void init() {
    debugPrint("INITIALIZING AWESOME NOTIFICATION !!!");
    try {
      awesomeNotifications.initialize(
        'resource://drawable/app_icon',
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF3F61DB),
            ledColor: Colors.white,
          ),
          // NotificationChannel(
          //     channelKey: 'badge_channel',
          //     channelName: 'Badge indicator notifications',
          //     channelDescription:
          //         'Notification channel to activate badge indicator',
          //     channelShowBadge: true,
          //     defaultColor: Color(0xFF9D50DD),
          //     ledColor: Colors.yellow),

          NotificationChannel(
              channelKey: 'ringtone_channel',
              channelName: 'Ringtone Channel',
              channelDescription: 'Channel with default ringtone',
              defaultColor: Color(0xFF3F61DB),
              ledColor: Colors.white,
              soundSource: "resource://raw/ping",
              playSound: true,
              importance: NotificationImportance.Max,
              enableVibration: true,
              enableLights: true),

          // NotificationChannel(
          //     channelKey: 'updated_channel',
          //     channelName: 'Channel to update',
          //     channelDescription: 'Notifications with not updated channel',
          //     defaultColor: Color(0xFF9D50DD),
          //     ledColor: Colors.white),
          // NotificationChannel(
          //     channelKey: 'low_intensity',
          //     channelName: 'Low intensity notifications',
          //     channelDescription:
          //         'Notification channel for notifications with low intensity',
          //     defaultColor: Colors.green,
          //     ledColor: Colors.green,
          //     vibrationPattern: lowVibrationPattern),
          // NotificationChannel(
          //     channelKey: 'medium_intensity',
          //     channelName: 'Medium intensity notifications',
          //     channelDescription:
          //         'Notification channel for notifications with medium intensity',
          //     defaultColor: Colors.yellow,
          //     ledColor: Colors.yellow,
          //     vibrationPattern: mediumVibrationPattern),
          // NotificationChannel(
          //     channelKey: 'high_intensity',
          //     channelName: 'High intensity notifications',
          //     channelDescription:
          //         'Notification channel for notifications with high intensity',
          //     defaultColor: Colors.red,
          //     ledColor: Colors.red,
          //     vibrationPattern: highVibrationPattern),
          // NotificationChannel(
          //     channelKey: "private_channel",
          //     channelName: "Privates notification channel",
          //     channelDescription: "Privates notification from lock screen",
          //     playSound: true,
          //     defaultColor: Colors.red,
          //     ledColor: Colors.red,
          //     vibrationPattern: lowVibrationPattern,
          //     defaultPrivacy: NotificationPrivacy.Private),
          // NotificationChannel(
          //     icon: 'resource://drawable/res_power_ranger_thunder',
          //     channelKey: "custom_sound",
          //     channelName: "Custom sound notifications",
          //     channelDescription: "Notifications with custom sound",
          //     playSound: true,
          //     soundSource: 'resource://raw/res_morph_power_rangers',
          //     defaultColor: Colors.red,
          //     ledColor: Colors.red,
          //     vibrationPattern: lowVibrationPattern),
          // NotificationChannel(
          //     channelKey: "silenced",
          //     channelName: "Silenced notifications",
          //     channelDescription: "The most quiet notifications",
          //     playSound: false,
          //     enableVibration: false,
          //     enableLights: false),
          // NotificationChannel(
          //     icon: 'resource://drawable/res_media_icon',
          //     channelKey: 'media_player',
          //     channelName: 'Media player controller',
          //     channelDescription: 'Media player controller',
          //     defaultPrivacy: NotificationPrivacy.Public,
          //     enableVibration: false,
          //     enableLights: false,
          //     playSound: false,
          //     locked: true),
          // NotificationChannel(
          //     channelKey: 'big_picture',
          //     channelName: 'Big pictures',
          //     channelDescription: 'Notifications with big and beautiful images',
          //     defaultColor: Color(0xFF9D50DD),
          //     ledColor: Color(0xFF9D50DD),
          //     vibrationPattern: lowVibrationPattern),
          // NotificationChannel(
          //     channelKey: 'big_text',
          //     channelName: 'Big text notifications',
          //     channelDescription: 'Notifications with a expandable body text',
          //     defaultColor: Colors.blueGrey,
          //     ledColor: Colors.blueGrey,
          //     vibrationPattern: lowVibrationPattern),
          // NotificationChannel(
          //     channelKey: 'inbox',
          //     channelName: 'Inbox notifications',
          //     channelDescription: 'Notifications with inbox layout',
          //     defaultColor: Color(0xFF9D50DD),
          //     ledColor: Color(0xFF9D50DD),
          //     vibrationPattern: mediumVibrationPattern),
          // NotificationChannel(
          //   channelKey: 'scheduled',
          //   channelName: 'Scheduled notifications',
          //   channelDescription: 'Notifications with schedule functionality',
          //   defaultColor: Color(0xFF9D50DD),
          //   ledColor: Color(0xFF9D50DD),
          //   vibrationPattern: lowVibrationPattern,
          //   importance: NotificationImportance.High,
          // ),
          // NotificationChannel(
          //     icon: 'resource://drawable/res_download_icon',
          //     channelKey: 'progress_bar',
          //     channelName: 'Progress bar notifications',
          //     channelDescription: 'Notifications with a progress bar layout',
          //     defaultColor: Colors.deepPurple,
          //     ledColor: Colors.deepPurple,
          //     vibrationPattern: lowVibrationPattern,
          //     onlyAlertOnce: true),
          // NotificationChannel(
          //     channelKey: 'grouped',
          //     channelName: 'Grouped notifications',
          //     channelDescription: 'Notifications with group functionality',
          //     groupKey: 'grouped',
          //     groupAlertBehavior: GroupAlertBehavior.Children,
          //     defaultColor: Colors.lightGreen,
          //     ledColor: Colors.lightGreen,
          //     vibrationPattern: lowVibrationPattern,
          //     importance: NotificationImportance.High)
        ],
      );
    } catch (error) {
      debugPrint("ERROR while initializing notification $error");
    }

    if (_streamController == null) {
      _streamController = BehaviorSubject<ReceivedAction>();

      _streamController!.addStream(awesomeNotifications.actionStream);

      _streamController!.stream.listen((receivedNotification) async {});
    }
  }

  void showNudgeNotification({required Map<String, dynamic> message}) async {
    try {
      int id = Random().nextInt(5000);
      Map<String, String> messagePayload =
          Map<String, String>.from(message['data']);

      messagePayload['actions'] = message['actions'];
      messagePayload['notification_id'] = id.toString();

      await awesomeNotifications.createNotification(
          content: NotificationContent(
            channelKey: "ringtone_channel",
            id: id,
            body: message['body'],
            largeIcon: message['data']['author_avatar'],
            payload: messagePayload,
            title: message['title'],
            //createdSource: NotificationSource.Local,
          ),
          actionButtons: [
            NotificationActionButton(
                label: "Accept",
                enabled: true,
                key: "accept_nudge",
                autoDismissible: true),
            NotificationActionButton(
                label: "Reject",
                enabled: true,
                key: "reject_nudge",
                autoDismissible: true,
                buttonType: ActionButtonType.KeepOnTop)
          ]);
    } catch (e) {
      debugPrint("ERROR:- $e");
    }
  }

  void showNotification({required Map<String, dynamic> message}) async {
    int id = Random().nextInt(50000);


    Map<String, String> finalNotification = {};
    Map<String, dynamic> tempNotification =
        Map<String, dynamic>.from(message['notification']);

    //We are converting those values that are null to empty string,
    // because payload property of NotificationContent requires a Map<String, String>,
    // so we can't have null.
    tempNotification.forEach((key, value) {
      if (value == null) {
        finalNotification[key] = '';
      } else {
        finalNotification[key] = value;
      }
    });


    Map<String, String> notification =
        Map<String, String>.from(finalNotification);

    notification['type'] = message['data']['type'];
    notification['notification_id'] = id.toString();


    //  await awesomeNotifications.cancelAll();

    if (notification.containsKey("image") &&
        notification['image'] != "" &&
        notification['image'] != null) {
      await awesomeNotifications.createNotification(
        content: NotificationContent(
          channelKey: "basic_channel",
          id: id,
          body: notification['body'],
          payload: notification,
          largeIcon: notification['image'],
          title: notification['title'],
          //createdSource: NotificationSource.Local,
        ),
      );
    } else {

      await awesomeNotifications.createNotification(
        content: NotificationContent(
          channelKey: "basic_channel",
          id: id,
          body: notification['body'],
          payload: notification,
          title: notification['title'],
          //createdSource: NotificationSource.Local,
        ),
      );
    }
  }
}
