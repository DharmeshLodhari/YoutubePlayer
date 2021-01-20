import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

Color getMessageTickColor({Map<String, dynamic> message}) {
  return message['delivered']
      ? message['read_by_recipient'] ?? false
          ? naturalGreen
          : Colors.white
      : darkGrey;
}
