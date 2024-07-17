import 'package:Slydo/screens/more_apps/user_profile/models/states_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/border_dialog_button.dart';
import 'package:Slydo/widget/cutomized_alert/customized_alert.dart';
import 'package:Slydo/widget/cutomized_alert/customized_alert_column_button.dart';
import 'package:Slydo/widget/cutomized_alert/dailog_button_stateful.dart';
import 'package:Slydo/widget/cutomized_alert/dialog_button.dart';
import 'package:Slydo/widget/cutomized_alert/modified_customized_alert.dart';
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
Future<bool?> showDialogBoxWithTitle(
    {Widget? content,
    required BuildContext context,
    String? title,
    String? description,
    bool firstActionPrimary = true,
    Color? actionBgColor,
    Color? actionTextColor,
    Function()? ButtonOnPressed,
    required String actionText, // DialogButton's text
    bool isOverlayTapDismiss = true,
    RoundedBackgroundIcon? roundedBackgroundIcon}) {
  return CustomizedAlert(
    title: title,
    content: content,
    context: context,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: isOverlayTapDismiss,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        onPressed: () {
          Navigator.pop(context, firstActionPrimary ? false : true);
          if (ButtonOnPressed != null) {
            ButtonOnPressed();
          }
        },
        textColor: actionTextColor,
        text: actionText,
        backgroundColor: actionBgColor,
      )
    ],
  ).show();
}

Future<bool?> showDialogBoxWithColumnButton(
    {Widget? content,
    required BuildContext context,
    String? title,
    String? description,
    String? actionOne,
    bool firstActionPrimary = true,
    String? image,
    Color? actionOneBgColor,
    Color? actionOneTextColor,
    Color? actionTwoBgColor,
    Color? actionTwoTextColor,
    String? actionTwo,
    Function()? ButtonOneOnPressed,
    Function()? ButtonTwoOnPressed,
    bool isOverlayTapDismiss = true,
    RoundedBackgroundIcon? roundedBackgroundIcon}) {
  return CustomizedAlertColumnButton(
    title: title,
    content: content,
    context: context,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: isOverlayTapDismiss,
      isCloseButton: false,
    ),
    buttons: [
      BorderDialogButton(
        outlineBorder: true,
        onPressed: () {
          Navigator.pop(context, firstActionPrimary ? false : true);
          if (ButtonOneOnPressed != null) {
            ButtonOneOnPressed();
          }
        },
        textColor: actionOneTextColor,
        text: actionOne,
        backgroundColor: actionOneBgColor,
      ),
      BorderDialogButton(
        outlineBorder: false,
        onPressed: () {
          Navigator.pop(context, firstActionPrimary ? false : true);
          if (ButtonTwoOnPressed != null) {
            ButtonTwoOnPressed();
          }
        },
        textColor: actionTwoTextColor,
        text: actionTwo,
        backgroundColor: actionTwoBgColor,
      )
    ],
  ).show();
}

Future<bool?> showDialogBoxWithImage({
  required BuildContext context,
  String? title,
  String? description,
  String? actionOne,
  bool firstActionPrimary = true,
  String? image,
  Color? actionOneBgColor,
  Color? actionOneTextColor,
  Color? actionTwoBgColor,
  Color? actionTwoTextColor,
  String? actionTwo,
}) {
  return CustomizedAlert(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: const AlertStyle(
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

Future<bool?> showDialogBoxWithImageWithOneAction({
  required BuildContext context,
  String? title,
  String? description,
  String? actionOne,
  String? image,
  Color? actionOneBgColor,
  Color? actionOneTextColor,
}) {
  return CustomizedAlert(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: const AlertStyle(
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

Future<bool?> showDialogBoxWithImageForNudge({
  BuildContext? context,
  String? title,
  String? description,
  IconData? actionOneIcon,
  bool firstActionPrimary = true,
  String? image,
  required Color iconBgColor,
  Color? iconColor,
  required Color iconTwoBgColor,
  Color? iconTwoColor,
  IconData? actionTwoIcon,
}) {
  return CustomizedAlertForNudge(
    context: context,
    title: title,
    desc: description,
    image: image,
    style: const AlertStyle(
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
        onTap: () => Navigator.pop(context!, firstActionPrimary ? true : false),
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
        onTap: () => Navigator.pop(context!, firstActionPrimary ? false : true),
      ),
    ],
  ).show();
}

Future<bool?> showDialogBox(
    {Widget? content,
    required BuildContext context,
    String? title,
    String? description,
    required String actionOneText,
    bool firstActionPrimary = true,
    String? image,
    Color? actionOneBgColor,
    Color? actionOneTextColor,
    Color? actionTwoBgColor,
    Color? actionTwoTextColor,
    double? fontSize,
    Function()? leftButtonOnPressed,
    Function()? rightButtonOnPressed,
    required String actionTwoText, // DialogButton's text
    bool isOverlayTapDismiss = true,
    RoundedBackgroundIcon? roundedBackgroundIcon}) {
  return CustomizedAlert(
    title: title,
    content: content,
    context: context,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: isOverlayTapDismiss,
      isCloseButton: false,
    ),
    buttons: [
      DialogButton(
        onPressed: () {
          Navigator.pop(context, firstActionPrimary ? true : false);
          if (leftButtonOnPressed != null) {
            leftButtonOnPressed();
          }
        },
        textColor: actionOneTextColor,
        text: actionOneText,
        fontSize: fontSize,
        backgroundColor: actionOneBgColor,
      ),
      DialogButton(
        onPressed: () {
          Navigator.pop(context, firstActionPrimary ? false : true);
          if (rightButtonOnPressed != null) {
            rightButtonOnPressed();
          }
        },
        textColor: actionTwoTextColor,
        text: actionTwoText,
        fontSize: fontSize,
        backgroundColor: actionTwoBgColor,
      )
    ],
  ).show();
}

Future<bool?> showDialogBoxWithInput(
    {Widget? content,
    required BuildContext context,
    String? title,
    String? description,
    required String actionOneText,
    bool firstActionPrimary = true,
    String? image,
    Color? actionOneBgColor,
    Color? actionOneTextColor,
    Color? actionTwoBgColor,
    bool? isLoading,
    Color? actionTwoTextColor,
    Function()? leftButtonOnPressed,
    Function()? rightButtonOnPressed,
    String? actionTwoText, // DialogButton's text
    bool isOverlayTapDismiss = true,
    RoundedBackgroundIcon? roundedBackgroundIcon}) {
  return ModifiedCustomizedAlert(
    title: title,
    content: content,
    context: context,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: isOverlayTapDismiss,
      isCloseButton: false,
    ),
    buttons: [
      if (leftButtonOnPressed != null)
        DialogButtonStateFul(
          onPressed: () async {
            await leftButtonOnPressed();
            return;
          },
          textColor: actionOneTextColor,
          text: actionOneText,
          backgroundColor: actionOneBgColor,
        ),
      if (rightButtonOnPressed != null)
        DialogButtonStateFul(
          onPressed: () async {
            await rightButtonOnPressed();
            return;
          },
          textColor: actionTwoTextColor,
          text: actionTwoText ?? "",
          backgroundColor: actionTwoBgColor,
        )
    ],
  ).show();
}

Future<bool?> showDialogBoxSuccess(
    {Widget? content,
    required BuildContext context,
    String? title,
    String? description,
    bool firstActionPrimary = true,
    String? image, // DialogButton's text
    bool isOverlayTapDismiss = true,
    RoundedBackgroundIcon? roundedBackgroundIcon}) {
  return CustomizedAlert(
    title: title,
    content: content,
    context: context,
    desc: description,
    roundedBackgroundIcon: roundedBackgroundIcon,
    style: AlertStyle(
      isOverlayTapDismiss: isOverlayTapDismiss,
      isCloseButton: false,
    ),
  ).show();
}

Widget dropDownPickItemWidget(
    {required String? selectedItem, required Function onTap, String? label}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label ?? '',
        style: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
      const SizedBox(height: 5),
      Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: greyBorderColor)),
        margin: const EdgeInsets.all(0),
        borderOnForeground: true,
        child: ListTile(
          dense: true,
          title: Text(
            selectedItem ?? "",
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
          ),
          onTap: () {
            onTap();
          },
        ),
      ),
    ],
  );
}

Future<T?> showPickItemDialog<T>({
  required BuildContext context,
  required List items,
  required T? selectedItem,
  Widget? unSelectedItemWidget,
  Widget? selectedItemWidget,
  Function(T)? onTapItem,
}) async {
  return await showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SingleChildScrollView(
              child: Column(
                children: items.map((item) {
                  if (selectedItem == item) {
                    return unSelectedItemWidget ??
                        Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              item,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 16,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              SlydoAppIcon.checked,
                              color: navyBlue,
                              size: 12,
                            ),
                            onTap: () {
                              onTapItem != null
                                  ? onTapItem(item)
                                  : Navigator.pop(context, item);
                            },
                          ),
                        );
                  }
                  return selectedItemWidget ??
                      ListTile(
                        title: Text(
                          item,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: 16,
                              color: blackFont,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          onTapItem != null
                              ? onTapItem(item)
                              : Navigator.pop(context, item);
                        },
                      );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void showSwipeHintCard({required BuildContext context}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          "assets/images/card_swipe_hint.png",
        ),
      ),
    ),
  );
}

void showHoldHintCard({required BuildContext context}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          "assets/images/card_hold_hint.png",
        ),
      ),
    ),
  );
}

void showUserLogoutCard({required BuildContext context}) {
  debugPrint("WorkManager cancel");
  // Workmanager().cancelAll();
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
            padding: const EdgeInsets.all(20),
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
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "You have logged in on another device.",
                  style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(
                  height: 20,
                ),
                CurvedButton(
                  backgroundColor: navyBlue,
                  text: "Ok",
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.pop(myGlobals.navigationKey.currentContext!);
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
    {required BuildContext context, bool isForChat = true}) async {
  final bool? result = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context, false);
                      }),
                ),
                Expanded(
                    child: Container(
                  height: 10,
                )),
                const Icon(
                  SlydoAppIcon.location,
                  size: 35,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Use your location",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: blackFont,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Slydo collects location data to enable you to share your location with your friends.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset("assets/images/location-disclosure.png"),
                const SizedBox(
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
                const SizedBox(
                  height: 10,
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
