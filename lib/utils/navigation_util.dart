import 'package:flutter/material.dart';

class NavigationUtil {
  static Future push(BuildContext context, {required Widget screen}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  static Future pushNamed(BuildContext context, {required String routeName}) {
    return Navigator.of(context).pushNamed(routeName);
  }
}
