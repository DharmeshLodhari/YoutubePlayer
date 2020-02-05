import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/colors.dart';

class ExitAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: darkBlue(),
      title: Text(
        "Are you Sure Want To Exit ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        MaterialButton(
          color: Colors.white,
          child: Text("Yes", style: TextStyle(color: darkBlue())),
          onPressed: () => SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'),
        ),
        MaterialButton(
          color: Colors.white,
          child: Text("Cancel", style: TextStyle(color: darkBlue())),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
