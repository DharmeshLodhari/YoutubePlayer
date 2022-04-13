import 'package:flutter/material.dart';

class NavigationUtil {
  static push(BuildContext context, {required Widget screen}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}
