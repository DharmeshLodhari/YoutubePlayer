import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool> showDialogBox(
    {BuildContext context,
    String title,
    String description,
    String actionOne,
    String image,
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

Future<bool> showDialogBoxWithImage(
    {BuildContext context,
    String title,
    String description,
    String actionOne,
    String image,
    String actionTwo}) {
  return Alert(
    context: context,
    title: title,
    desc: description,
    image: Image.network(
      image,
      height: 200,
      width: MediaQuery.of(context).size.width - 200,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    ),
    style: AlertStyle(
      isOverlayTapDismiss: false,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        radius: BorderRadius.circular(2),
        child: Text(
          actionOne,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
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
