import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool> showDialogBox(
    {BuildContext context,
    String title,
    String description,
    String actionOne,
    String actionTwo,
    AlertType type}) {
  return Alert(
    context: context,
    title: title,
    type: type,
    desc: description,
    style: AlertStyle(
      isOverlayTapDismiss: false,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        radius: BorderRadius.circular(2),
        child: Text(
          actionOne,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context, true),
        color: Color.fromRGBO(13, 27, 70, 1.0),
      ),
      DialogButton(
        radius: BorderRadius.circular(2),
        child: Text(
          actionTwo,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context, false),
        color: Color.fromRGBO(13, 27, 70, 1.0),
      )
    ],
  ).show();
}
