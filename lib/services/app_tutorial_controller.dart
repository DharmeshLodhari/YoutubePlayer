import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/scroll_up_arrow_animation.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey tutorialUserProfileDetailKey = GlobalKey();
GlobalKey tutorialChangeLocationKey = GlobalKey();
GlobalKey tutorialSearchUserKey = GlobalKey();
GlobalKey tutorialItemCartKey = GlobalKey();
GlobalKey tutorialHomeQrCodeKey = GlobalKey();
GlobalKey tutorialSlydoKey = GlobalKey();
GlobalKey tutorialHomeSuperStoreKey = GlobalKey();
GlobalKey tutorialChatKey = GlobalKey();
GlobalKey tutorialHomeSettingsKey = GlobalKey();
GlobalKey tutorialSocialKey = GlobalKey();
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
      AppTutorialController.internal();

  factory AppTutorialController() => _instance;

  AppTutorialController.internal();

  final List<TargetFocus> _targets = [];

  TutorialCoachMark? tutorial;
  double? deviceHeight;

  void triggerNextTutorial() {
    if (tutorial != null) {
      tutorial?.next();
    }
  }

  void showTutorial(BuildContext context) {
    deviceHeight = MediaQuery.sizeOf(context).height;
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
      // pulseEnable: false,

      onFinish: () {
        debugPrint("finish");
      },
      onClickTarget: (target) {
        debugPrint("target ===> $target");
      },
      onSkip: () {
        debugPrint("skip");
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
      padding: const EdgeInsets.only(top: 16),
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

  Widget doneButton() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      width:
          MediaQuery.of(MyGlobals().navigationKey.currentContext!).size.width /
              2,
      child: CurvedButton(
        onPressed: () {
          tutorial?.skip();
        },
        text: "Done",
        backgroundColor: navyBlue,
        textColor: Colors.white,
      ),
    );
  }

  TargetFocus _getUserProfileTutorial() {
    return _createTutorial(
      identify: "Target 1",
      keyTarget: tutorialUserProfileDetailKey,
      title: "User Profile",
      description: "Click here to navigate to user profile",
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      crossAxisAlignment: CrossAxisAlignment.start,
      textAlign: TextAlign.left,
      currentStep: 1,
      totalSteps: 10,
    );
  }

  TargetFocus _getChangeLocationTutorial() {
    return _createTutorial(
      identify: "Target 2",
      keyTarget: tutorialChangeLocationKey,
      title: "Location",
      description: "Click here to change your location",
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      crossAxisAlignment: CrossAxisAlignment.start,
      textAlign: TextAlign.left,
      currentStep: 2,
      totalSteps: 10,
    );
  }

  TargetFocus _getSearchUserTutorial() {
    return _createTutorial(
      identify: "Target 3",
      keyTarget: tutorialSearchUserKey,
      title: "Search",
      description: "Click here to search users & browse channels",
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      crossAxisAlignment: CrossAxisAlignment.end,
      textAlign: TextAlign.right,
      currentStep: 3,
      totalSteps: 10,
    );
  }

  TargetFocus _getItemCartTutorial() {
    return _createTutorial(
      identify: "Target 4",
      keyTarget: tutorialItemCartKey,
      title: "Basket",
      description: "Click here to view all the items added to cart",
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      crossAxisAlignment: CrossAxisAlignment.end,
      textAlign: TextAlign.right,
      currentStep: 4,
      totalSteps: 10,
    );
  }

  TargetFocus _getHomeQrCodeTutorial() {
    return _createTutorial(
      identify: "Target 5",
      keyTarget: tutorialHomeQrCodeKey,
      title: "QR Code",
      description:
          "Click here to view your qrcode to receive payment & scan qrcode to send payment",
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      crossAxisAlignment: CrossAxisAlignment.end,
      textAlign: TextAlign.right,
      currentStep: 5,
      totalSteps: 10,
    );
  }

  TargetFocus _getSlydoTutorial() {
    return _createTutorial(
      identify: "Target 6",
      keyTarget: tutorialSlydoKey,
      title: "Slydo",
      description: "Click here to create & Press down to logout",
      align: ContentAlign.top,
      alignSkip: Alignment.topLeft,
      crossAxisAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      currentStep: 6,
      totalSteps: 10,
    );
  }

  TargetFocus _getHomeSuperStoreTutorial() {
    return _createTutorial(
      identify: "Target 7",
      keyTarget: tutorialHomeSuperStoreKey,
      title: "Slydo",
      description:
          "Click here to navigate to Super store to buy and view exciting offers",
      align: ContentAlign.top,
      alignSkip: Alignment.topLeft,
      crossAxisAlignment: CrossAxisAlignment.start,
      textAlign: TextAlign.left,
      currentStep: 7,
      totalSteps: 10,
    );
  }

  TargetFocus _getChatTutorial() {
    return _createTutorial(
      identify: "Target 8",
      keyTarget: tutorialChatKey,
      title: "Chat",
      description: "Click here to start a conversation",
      align: ContentAlign.top,
      alignSkip: Alignment.topLeft,
      crossAxisAlignment: CrossAxisAlignment.end,
      textAlign: TextAlign.right,
      currentStep: 8,
      totalSteps: 10,
    );
  }

  TargetFocus _getHomeSettingsTutorial() {
    return _createTutorial(
      identify: "Target 9",
      keyTarget: tutorialHomeSettingsKey,
      title: "Settings",
      description: "Click here to view all applicable settings",
      align: ContentAlign.top,
      alignSkip: Alignment.topLeft,
      crossAxisAlignment: CrossAxisAlignment.end,
      textAlign: TextAlign.right,
      currentStep: 9,
      totalSteps: 10,
    );
  }

  TargetFocus _getSocialTutorial() {
    return _createTutorial(
      identify: "Target 10",
      keyTarget: tutorialSocialKey,
      title: "Socials",
      description: "Swipe up to view your social feed",
      align: ContentAlign.top,
      alignSkip: Alignment.topLeft,
      crossAxisAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      currentStep: 10,
      totalSteps: 10,
      type: "social",
    );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Make Payment",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click here to initiate payment.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Payment Request",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click here to initiate payment request.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "User QR Code",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "The current user's QR code.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Transactions",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Access all your completed and pending transactions.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Wallet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Fund your Slydo account with direct transfers or debit card.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Search",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click here to search for users, products and services.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  nextButton()
                ],
              ))
        ]);
  }

  TargetFocus _getShoppingCartTutorial() {
    return TargetFocus(
      identify: "Target 12",
      keyTarget: tutorialShoppingCartKey,
      shape: ShapeLightFocus.RRect,

      // color: navyBlue,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Shopping Cart",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Click here to view your shopping cart.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                nextButton()
              ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Yarn",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Connect with others and stay up to date on worldwide trends.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
          ),
        )
      ],
    );
  }

  TargetFocus _getScanQrCodeTutorial() {
    return TargetFocus(
      identify: "Target 11",
      keyTarget: tutorialScanQrCodeKey,
      shape: ShapeLightFocus.RRect,

      // color: navyBlue,
      contents: [
        TargetContent(
          align: ContentAlign.left,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "QR Code Scanner",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Click here to scan slydo QR codes.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Chat",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "View and exchange messages with buyers, sellers and friends.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Settings",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Control and manage every account function.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Super Store",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Check out an unlimited variety of goods available for sale.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Moment",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Share and view unforgettable memories.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Orders",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "View all open and closed orders.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Inbox",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Check all sent and received messages.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Blogs",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Discover insightful write upd on your preferred topics and many more.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Services",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Take a look at all services offered by Slydo users at the best prices.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              nextButton()
            ],
          ),
        )
      ],
    );
  }

  void _fillTargets() {
    _targets.add(_getUserProfileTutorial());
    _targets.add(_getChangeLocationTutorial());
    _targets.add(_getSearchUserTutorial());
    _targets.add(_getItemCartTutorial());
    _targets.add(_getHomeQrCodeTutorial());
    _targets.add(_getSlydoTutorial());
    _targets.add(_getHomeSuperStoreTutorial());
    _targets.add(_getChatTutorial());
    _targets.add(_getHomeSettingsTutorial());
    _targets.add(_getSocialTutorial());
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

  TargetFocus _createTutorial({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required ContentAlign align,
    required AlignmentGeometry alignSkip,
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
    required int currentStep,
    required int totalSteps,
    String? type,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: ShapeLightFocus.RRect,
      radius: 5,
      alignSkip: alignSkip,
      paddingFocus: type == "social" ? 0 : 3,
      contents: [
        TargetContent(
          align: align,
          child: Padding(
            padding: getPadding(type),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                if (type == "social") ...[
                  const ScrollArrowIndicator(),
                  const SizedBox(height: 30),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: textAlign,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                ),
                if (type == "social") doneButton() else nextButton(),
                const SizedBox(height: 10),
                Text(
                  "$currentStep/$totalSteps",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsetsGeometry getPadding(String? type) {
    if (type == "social") {
      if (deviceHeight != null && deviceHeight! > 700) {
        return const EdgeInsets.only(bottom: 180);
      }
      return const EdgeInsets.only(bottom: 370);
    }
    return EdgeInsets.zero;
  }
}
