import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey tutorialUserProfileDetailKey = GlobalKey();
GlobalKey tutorialSendPaymentKey = GlobalKey();
GlobalKey tutorialRequestPaymentKey = GlobalKey();
GlobalKey tutorialQrCodeKey = GlobalKey();
GlobalKey tutorialRequestPaymentListKey = GlobalKey();
GlobalKey tutorialSearchItemsKey = GlobalKey();
GlobalKey tutorialShoppingCartKey = GlobalKey();
GlobalKey tutorialProfileKey = GlobalKey();
GlobalKey tutorialScanQrCodeKey = GlobalKey();
GlobalKey tutorialChatMessageKey = GlobalKey();
GlobalKey tutorialMessageKey = GlobalKey();

GlobalKey keyButton3 = GlobalKey();
GlobalKey keyButton4 = GlobalKey();
GlobalKey keyButton5 = GlobalKey();

class AppTutorialController {
  static final AppTutorialController _instance =
      new AppTutorialController.internal();

  factory AppTutorialController() => _instance;

  AppTutorialController.internal();

  List<TargetFocus> _targets = [];

  TutorialCoachMark? tutorial;

  void triggerNextTutorial() {
    if (tutorial != null) {
      tutorial?.next();
    }
  }

  void showTutorial(BuildContext context) {
    _fillTargets();

    tutorial = TutorialCoachMark(context,
        targets: _targets, // List<TargetFocus>
        colorShadow: Colors.black12, // DEFAULT Colors.black
        // alignSkip: Alignment.bottomRight,
        // textSkip: "SKIP",
        // paddingFocus: 10,
        // focusAnimationDuration: Duration(milliseconds: 500),
        // pulseAnimationDuration: Duration(milliseconds: 500),
        // pulseVariation: Tween(begin: 1.0, end: 0.99),
        onFinish: () {
      print("finish");
    }, onClickTarget: (target) {
      print(target);
    }, onSkip: () {
      print("skip");
    })
      ..show();

    // tutorial.skip();
    // tutorial.finish();
    // tutorial.next(); // call next target programmatically
    // tutorial.previous(); // call previous target programmatically
  }

  Widget nextButton() {
    return Container(
      padding: EdgeInsets.only(top: 16),
      width:
          MediaQuery.of(MyGlobals().navigationKey.currentContext!).size.width /
              2,
      child: CurvedButton(
        onPressed: () {
          triggerNextTutorial();
        },
        text: "Next",
        backgroundColor: navyBlue,
        textColor: Colors.white,
      ),
    );
  }

  TargetFocus _getUserProfileTutorial() {
    return TargetFocus(
        identify: "Target 1",
        keyTarget: tutorialUserProfileDetailKey,
        shape: ShapeLightFocus.RRect,
        // color: starYellow.withOpacity(0.2),
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "User Profile",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to navigate to user profile.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getSendPaymentTutorial() {
    return TargetFocus(
        identify: "Target 2",
        keyTarget: tutorialSendPaymentKey,
        shape: ShapeLightFocus.RRect,
        // color: naturalGreen,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Make Payment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to initiate payment.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              )),
        ]);
  }

  TargetFocus _getRequestPaymentTutorial() {
    return TargetFocus(
        identify: "Target 3",
        keyTarget: tutorialRequestPaymentKey,
        shape: ShapeLightFocus.RRect,
        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment Request",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to initiate payment request.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getQrCodeTutorial() {
    return TargetFocus(
        identify: "Target 4",
        keyTarget: tutorialQrCodeKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "User QR Code",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "The current user's QR code.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  // TargetFocus _getPaymentRequestListTutorial() {
  //   return TargetFocus(
  //       identify: "Target 6",
  //       keyTarget: tutorialRequestPaymentListKey,
  //       shape: ShapeLightFocus.RRect,
  //
  //       // color: navyBlue,
  //       contents: [
  //         TargetContent(
  //             align: ContentAlign.top,
  //             child: Container(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   Text(
  //                     "Payment Request List",
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                         fontSize: 20.0),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 10.0),
  //                     child: Text(
  //                       "Click here to see the list of all your payment request.",
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                   nextButton()
  //                 ],
  //               ),
  //             ))
  //       ]);
  // }

  TargetFocus _getSearchItemTutorial() {
    return TargetFocus(
        identify: "Target 7",
        keyTarget: tutorialSearchItemsKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Search",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to search for users, products and services.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getShoppingCartTutorial() {
    return TargetFocus(
        identify: "Target 8",
        keyTarget: tutorialShoppingCartKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Shopping Cart",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to view your shopping cart.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getProfileTutorial() {
    return TargetFocus(
        identify: "Target 9",
        keyTarget: tutorialProfileKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Explore",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to explore more functionalities in the app.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getScanQrCodeTutorial() {
    return TargetFocus(
        identify: "Target 10",
        keyTarget: tutorialScanQrCodeKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "QR Code Scanner",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to scan slydo QR codes.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getChatMessagesTutorial() {
    return TargetFocus(
        identify: "Target 11",
        keyTarget: tutorialChatMessageKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Chat",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to chat with friends and family.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getMessagesTutorial() {
    return TargetFocus(
        identify: "Target 12",
        keyTarget: tutorialMessageKey,
        shape: ShapeLightFocus.RRect,

        // color: navyBlue,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Inbox",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Click here to send and read direct messages.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  void _fillTargets() {
    _targets.add(_getUserProfileTutorial());
    _targets.add(_getSendPaymentTutorial());
    _targets.add(_getRequestPaymentTutorial());
    _targets.add(_getQrCodeTutorial());
    // _targets.add(_getPaymentRequestListTutorial());
    _targets.add(_getSearchItemTutorial());
    _targets.add(_getShoppingCartTutorial());
    _targets.add(_getProfileTutorial());
    _targets.add(_getScanQrCodeTutorial());
    _targets.add(_getChatMessagesTutorial());
    _targets.add(_getMessagesTutorial());
  }
}
