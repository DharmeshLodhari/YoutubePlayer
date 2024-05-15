import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey tutorialUserProfileDetailKey = GlobalKey();
GlobalKey tutorialSendPaymentKey = GlobalKey();
GlobalKey tutorialRequestPaymentKey = GlobalKey();
GlobalKey tutorialQrCodeKey = GlobalKey();
GlobalKey paymentLinkKey = GlobalKey();
GlobalKey creditCardKey = GlobalKey();
GlobalKey tutorialSearchItemsKey = GlobalKey();
GlobalKey tutorialShoppingCartKey = GlobalKey();
GlobalKey tutorialProfileCartKey = GlobalKey();
GlobalKey tutorialScanQrCodeKey = GlobalKey();
GlobalKey tutorialChatMessageKey = GlobalKey();
GlobalKey tutorialSuperStoreKey = GlobalKey();
GlobalKey tutorialYarnKey = GlobalKey();
GlobalKey tutorialMomentKey = GlobalKey();
GlobalKey tutorialTransactionKey = GlobalKey();
GlobalKey tutorialWalletKey = GlobalKey();
GlobalKey tutorialOrderKey = GlobalKey();
GlobalKey tutorialInboxKey = GlobalKey();
GlobalKey tutorialBlogsKey = GlobalKey();
GlobalKey tutorialServicesKey = GlobalKey();
GlobalKey tutorialSettingsKey = GlobalKey();

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

    tutorial = TutorialCoachMark(
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
      },
      onClickTarget: (target) {
        print(target);
      },
      onSkip: () {
        print("skip");
        return true;
      },
    )..show(context: context);

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

  TargetFocus _getTransactionTutorial() {
    return TargetFocus(
        identify: "Target 5",
        keyTarget: tutorialTransactionKey,
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
                      "Transactions",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Access all your completed and pending transactions.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

  TargetFocus _getWalletTutorial() {
    return TargetFocus(
        identify: "Target 6",
        keyTarget: tutorialWalletKey,
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
                      "Wallet",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Fund your Slydo account with direct transfers or debit card.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    nextButton()
                  ],
                ),
              ))
        ]);
  }

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
            align: ContentAlign.bottom,
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
      ],
    );
  }

  TargetFocus _getYarnTutorial() {
    return TargetFocus(
      identify: "Target 9",
      keyTarget: tutorialYarnKey,
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
                  "Yarn",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Connect with others and stay up to date on worldwide trends.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
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
          ),
        )
      ],
    );
  }

  TargetFocus _getChatMessagesTutorial() {
    return TargetFocus(
      identify: "Target 11",
      keyTarget: tutorialChatMessageKey,
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
                  "Chat",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "View and exchange messages with buyers, sellers and friends.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getSettingsTutorial() {
    return TargetFocus(
      identify: "Target 12",
      keyTarget: tutorialSettingsKey,
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
                  "Settings",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Control and manage every account function.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getSuperStoreTutorial() {
    return TargetFocus(
      identify: "Target 13",
      keyTarget: tutorialSuperStoreKey,
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
                  "Super Store",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Check out an unlimited variety of goods available for sale.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getMomentTutorial() {
    return TargetFocus(
      identify: "Target 14",
      keyTarget: tutorialMomentKey,
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
                  "Moment",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Share and view unforgettable memories.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getOrderTutorial() {
    return TargetFocus(
      identify: "Target 15",
      keyTarget: tutorialOrderKey,
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
                  "Orders",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "View all open and closed orders.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getInboxTutorial() {
    return TargetFocus(
      identify: "Target 16",
      keyTarget: tutorialInboxKey,
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
                  "Inbox",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Check all sent and received messages.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getBlogsTutorial() {
    return TargetFocus(
      identify: "Target 17",
      keyTarget: tutorialBlogsKey,
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
                  "Blogs",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Discover insightful write upd on your preferred topics and many more.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  TargetFocus _getServicesTutorial() {
    return TargetFocus(
      identify: "Target 18",
      keyTarget: tutorialServicesKey,
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
                  "Services",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Take a look at all services offered by Slydo users at the best prices.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
            ),
          ),
        )
      ],
    );
  }

  void _fillTargets() {
    _targets.add(_getUserProfileTutorial());
    // _targets.add(_getSendPaymentTutorial());
    // _targets.add(_getRequestPaymentTutorial());
    // _targets.add(_getQrCodeTutorial());
    _targets.add(_getScanQrCodeTutorial());

    // _targets.add(_getSearchItemTutorial());
    _targets.add(_getShoppingCartTutorial());
    // _targets.add(_getSettingsTutorial());
    // _targets.add(_getYarnTutorial());
    // _targets.add(_getSuperStoreTutorial());
    // _targets.add(_getMomentTutorial());
    // _targets.add(_getChatMessagesTutorial());

    // _targets.add(_getOrderTutorial());
    // _targets.add(_getServicesTutorial());
    // _targets.add(_getTransactionTutorial());
    // _targets.add(_getInboxTutorial());
    // _targets.add(_getWalletTutorial());
    // _targets.add(_getBlogsTutorial());
  }
}
