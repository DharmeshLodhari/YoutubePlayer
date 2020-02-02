import 'package:flutter/material.dart';

@immutable
class PushNotification {
  final String title;
  final String body;
  final String image;

  const PushNotification({
    @required this.title,
    @required this.body,
    this.image,
  });
}
