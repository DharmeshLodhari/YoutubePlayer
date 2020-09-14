import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/customized_alert.dart';
import 'package:Slydo/widget/cutomized_alert/dialog_button.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
//
// Future<bool> showDialogBox(
//     {BuildContext context,
//     String title,
//     String description,
//     String actionOne,
//     String image,
//     String actionTwo,
//     AlertType type}) {
//   return Alert(
//     context: context,
//     title: title,
//     type: type,
//     desc: description,
//     style: AlertStyle(
//       isOverlayTapDismiss: false,
//       isCloseButton: false,
//     ),
//     buttons: [
//       DialogButton(
//         radius: BorderRadius.circular(2),
//         child: Text(
//           actionOne,
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         onPressed: () => Navigator.pop(context, true),
//         color: Color.fromRGBO(13, 27, 70, 1.0),
//       ),
//       DialogButton(
//         radius: BorderRadius.circular(2),
//         child: Text(
//           actionTwo,
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         onPressed: () => Navigator.pop(context, false),
//         color: Color.fromRGBO(13, 27, 70, 1.0),
//       )
//     ],
//   ).show();
// }
//
Future<bool> showDialogBoxWithImage({
  BuildContext context,
  String title,
  String description,
  String actionOne,
  bool firstActionPrimary = true,
  String image,
  Color actionOneBgColor,
  Color actionOneTextColor,
  Color actionTwoBgColor,
  Color actionTwoTextColor,
  String actionTwo,
}) {
  return CustomizedAlert(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: AlertStyle(
      isOverlayTapDismiss: false,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        onPressed: () =>
            Navigator.pop(context, firstActionPrimary ? true : false),
        textColor: actionOneTextColor,
        text: actionOne,
        backgroundColor: actionOneBgColor,
      ),
      DialogButton(
        onPressed: () =>
            Navigator.pop(context, firstActionPrimary ? false : true),
        textColor: actionTwoTextColor,
        text: actionTwo,
        backgroundColor: actionTwoBgColor,
      )
    ],
  ).show();
}

Future<bool> showDialogBox({
  BuildContext context,
  String title,
  String description,
  String actionOne,
  bool firstActionPrimary = true,
  String image,
  RoundedBackgroundIcon roundedBackgroundIcon,
  Color actionOneBgColor,
  Color actionOneTextColor,
  Color actionTwoBgColor,
  Color actionTwoTextColor,
  String actionTwo,
}) {
  return CustomizedAlert(
    context: context,
    title: title,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: false,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        onPressed: () =>
            Navigator.pop(context, firstActionPrimary ? true : false),
        textColor: actionOneTextColor,
        text: actionOne,
        backgroundColor: actionOneBgColor,
      ),
      DialogButton(
        onPressed: () =>
            Navigator.pop(context, firstActionPrimary ? false : true),
        textColor: actionTwoTextColor,
        text: actionTwo,
        backgroundColor: actionTwoBgColor,
      )
    ],
  ).show();
}
