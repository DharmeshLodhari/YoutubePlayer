import 'package:flutter/material.dart';

Future<String> captureVideo(BuildContext context, Duration duration) async {
  String result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container());

  return Future.value("");
}
