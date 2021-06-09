import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/nudge_notification/NudgeNotification.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AwesomeNotificationService {
  static final AwesomeNotificationService _notificationService =
      AwesomeNotificationService._internal();

  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

  factory AwesomeNotificationService() {
    return _notificationService;
  }

  AwesomeNotificationService._internal();

  static StreamController<ReceivedAction> _streamController;

  Stream get notificationActionStream => _streamController?.stream;

  void init() {
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

    if (_streamController == null) {
      _streamController = StreamController<ReceivedAction>.broadcast();

      _streamController.addStream(awesomeNotifications.actionStream);

      _streamController.stream.listen((receivedNotification) async {
        debugPrint("action:-  ${receivedNotification.buttonKeyPressed}");
        debugPrint("data:-  ${receivedNotification.payload}");

        Map<String, dynamic> payload = receivedNotification.payload;

        if (receivedNotification.buttonKeyPressed == "reject_nudge") {
          Map<String, dynamic> data = {
            "check_id": Uuid().v4(),
            "conversation_id": payload['conversation_id'],
            "author": payload['recipient'],
            "recipient": payload['author'],
            "created_at": DateTime.now().toUtc().toString(),
            "acknowledgement_type": "Canceled",
            "type": "stop_nudging",
          };
          try {
            MessageAuth().sendStopNudge(dataToSend: data);
          } catch (error) {
            debugPrint("ERROR:- $error");
          }
        } else if (receivedNotification.buttonKeyPressed == "accept_nudge") {
          saveNudgeNotification(receivedNotification.payload);
        } else {
          debugPrint("===> ${receivedNotification.toMap()}");
          saveNotification(payload);
        }
      });
    }
  }

  Future<void> saveNudgeNotification(Map<String, dynamic> payload) async {
    NudgeNotification nudgeNotification = NudgeNotification.fromJson(payload);
    nudgeNotification.recipientUsername = payload['author'];
    try {
      await DatabaseHelper().saveNudgeNotification(nudgeNotification);
    } catch (error) {
      debugPrint("DATA ${nudgeNotification.toJson()}");
      debugPrint("ERROR WHILE INSERTING $error");
    }
    return;
  }

  void showNudgeNotification({Map<String, dynamic> message}) async {
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
            createdSource: NotificationSource.Local,
          ),
          actionButtons: [
            NotificationActionButton(
                label: "Accept",
                enabled: true,
                key: "accept_nudge",
                autoCancel: true),
            NotificationActionButton(
                label: "Reject",
                enabled: true,
                key: "reject_nudge",
                autoCancel: true,
                buttonType: ActionButtonType.KeepOnTop)
          ]);
    } catch (e) {
      debugPrint("EERROR:- $e");
    }
  }

  void showNotification({Map<String, dynamic> message}) async {
    int id = Random().nextInt(50000);

    Map<String, String> notification =
        Map<String, String>.from(message['notification']);

    notification['type'] = message['data']['type'];
    notification['notification_id'] = id.toString();

    await awesomeNotifications.cancelAll();

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
          createdSource: NotificationSource.Local,
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
          createdSource: NotificationSource.Local,
        ),
      );
    }
  }

  void saveNotification(Map<String, dynamic> payload) async {
    try {
      await DatabaseHelper().saveNotification(jsonEncode(payload));
    } catch (error) {
      debugPrint("DATA $payload");
      debugPrint("ERROR WHILE INSERTING $error");
    }
    return;
  }
}
