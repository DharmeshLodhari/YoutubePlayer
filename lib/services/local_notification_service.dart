import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

const String applicationName = "Slydo";

class LocalNotificationService {
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory LocalNotificationService() {
    return _notificationService;
  }

  LocalNotificationService._internal();

  static const List<Map<String, String>> channelList = [
    {
      "channel_id": "slydo_notification",
      "channel_name": "simple_notification",
      "channel_description": "notification for simple messages",
      "sound": "notification"
    },
    {
      "channel_id": "slydo_nudge",
      "channel_name": "nudge_notification",
      "channel_description": "notification for nudge messages",
      "sound": "ping"
    },
  ];

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    tz.initializeTimeZones();

    channelList.forEach((element) {
      _createNotificationChannel(
          element['channel_id']!,
          element['channel_name']!,
          element['channel_description']!,
          element['sound']);
    });
  }

  Future selectNotification(String? payload) async {
    print("Select notification $payload");
  }

  // void showNotification(Map<String, dynamic> message,
  //     String notificationMessage, String notificationChannel) async {
  //   await flutterLocalNotificationsPlugin.show(
  //     message['id'],
  //     applicationName,
  //     notificationMessage,
  //     NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           notificationChannel,
  //           applicationName,
  //           'This is Local Notification',
  //           priority: Priority.max,
  //         ),
  //         iOS: IOSNotificationDetails()),
  //     payload: message['payload'],
  //   );
  // }

  Future<void> _createNotificationChannel(
      String id, String name, String description, String? sound) async {
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      // description,
      sound: RawResourceAndroidNotificationSound(sound),
      showBadge: true,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  void cancelNotification(Map<String, dynamic> message) async {
    await flutterLocalNotificationsPlugin.cancel(message['id']);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    return;
  }
}
