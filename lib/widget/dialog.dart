import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/customized_alert.dart';
import 'package:Slydo/widget/cutomized_alert/dialog_button.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import 'curved_btn.dart';
import 'cutomized_alert/customized_alert_for_nudge.dart';

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
      isOverlayTapDismiss: true,
      isCloseButton: true,
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

Future<bool> showDialogBoxWithImageWithOneAction({
  BuildContext context,
  String title,
  String description,
  String actionOne,
  String image,
  Color actionOneBgColor,
  Color actionOneTextColor,
}) {
  return CustomizedAlert(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: AlertStyle(
      isOverlayTapDismiss: true,
      isCloseButton: true,
    ),
    buttons: [
      DialogButton(
        onPressed: () => Navigator.pop(context, true),
        textColor: actionOneTextColor,
        text: actionOne,
        backgroundColor: actionOneBgColor,
      ),
    ],
  ).show();
}

Future<bool> showDialogBoxWithImageForNudge({
  BuildContext context,
  String title,
  String description,
  IconData actionOneIcon,
  bool firstActionPrimary = true,
  String image,
  Color iconBgColor,
  Color iconColor,
  Color iconTwoBgColor,
  Color iconTwoColor,
  IconData actionTwoIcon,
}) {
  return CustomizedAlertForNudge(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: AlertStyle(
      isOverlayTapDismiss: true,
      isCloseButton: true,
    ),
    buttons: [
      RoundedBackgroundIcon(
        backgroundColor: iconBgColor.withOpacity(0.1),
        height: 50,
        width: 50,
        borderRadius: 50,
        icon: Icon(
          actionOneIcon,
          color: iconBgColor,
          size: 18,
        ),
        onTap: () => Navigator.pop(context, firstActionPrimary ? true : false),
      ),
      RoundedBackgroundIcon(
        backgroundColor: iconTwoBgColor.withOpacity(0.1),
        borderRadius: 50,
        height: 50,
        width: 50,
        icon: Icon(
          actionTwoIcon,
          color: iconTwoBgColor,
          size: 18,
        ),
        onTap: () => Navigator.pop(context, firstActionPrimary ? false : true),
      ),
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

void showSwipeHintCard({BuildContext context}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => Dialog(
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          "assets/images/card_swipe_hint.png",
        ),
      ),
    ),
  );
}

void showHoldHintCard({BuildContext context}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => Dialog(
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          "assets/images/card_hold_hint.png",
        ),
      ),
    ),
  );
}

void showUserLogoutCard({BuildContext context}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () {
        //  logoutUser(context);
        return Future.value(true);
      },
      child: Dialog(
        elevation: 0,
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Login Alert!",
                  style: TextStyle(
                      color: mateRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "You have logged in other device.",
                  style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                SizedBox(
                  height: 20,
                ),
                CurvedButton(
                  backgroundColor: navyBlue,
                  text: "Ok",
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.pop(myGlobals.navigationKey.currentContext);
                    //  logoutUser(context);
                  },
                ),
              ],
            )),
      ),
    ),
  );
}

Future<bool> showInAppLocationAlertPopUp(
    {BuildContext context, bool isForChat = true}) async {
  bool result = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context, false);
                      }),
                ),
                Expanded(
                    child: Container(
                  height: 10,
                )),
                Icon(
                  SlydoAppIcon.location,
                  size: 35,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Use your location",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: blackFont),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Slydo collects location data to enable you to share your location with your friends.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Image.asset("assets/images/location-disclosure.png"),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: Container(
                  height: 10,
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        "No thanks",
                        style: TextStyle(
                            color: navyBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        "Turn on",
                        style: TextStyle(
                            color: navyBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  if (result != null) {
    if (result) {
      return true;
    }
    return false;
  }
  return false;
}
