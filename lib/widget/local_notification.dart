import 'package:Slydo/widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<NotificationDetails> _icon(BuildContext context, Image icon) async {
  final iconPath = await saveImage(context, icon);
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'big text channel id',
    'big text channel name',
    'big text channel description',
    largeIcon: iconPath,
    largeIconBitmapSource: BitmapSource.FilePath,
  );
  return NotificationDetails(androidPlatformChannelSpecifics, null);
}

NotificationDetails get _ongoing {
  final androidChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      icon: "app_icon");
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showOngoingNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _ongoing);

Future _showNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  @required NotificationDetails type,
  int id = 0,
}) =>
    notifications.show(id, title, body, type);
