import 'package:flutter/material.dart';

class NavigationUtil {
  static Future push(BuildContext context, {required Widget screen}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
    return result;
  }

  static Future pushReplacement(BuildContext context,
      {required Widget screen}) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  static Future pushNamed(BuildContext context, {required String routeName}) {
    return Navigator.of(context).pushNamed(routeName);
  }

  static void pop(BuildContext context) {
    return Navigator.of(context).pop();
  }
}
