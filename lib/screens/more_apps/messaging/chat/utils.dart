import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

Color getMessageTickColor({Map<String, dynamic> message}) {
  return message['delivered']
      ? message['read_by_recipient'] ?? false
          ? navyBlue
          : darkGrey
      : darkGrey;
}

Widget getMessageTick({Map<String, dynamic> message}) {
  return Icon(
    message['delivered']
        ? Icons.check_circle_rounded
        : Icons.check_circle_outline_outlined,
    size: 12,
    color: getMessageTickColor(message: message),
  );
}

String getAuthorName(
    {Map<String, dynamic> message, @required User currentUser}) {
  bool isSend = currentUser.userName == message["author"];

  if (isSend) {
    return "You";
  } else {
    return message["author_full_name"] ?? message["author"];
  }
}
