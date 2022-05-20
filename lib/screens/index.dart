import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class Index extends StatefulWidget {
  var arguments;

  Index({this.arguments});

  @override
  _IndexState createState() => _IndexState(arguments: arguments);
}

class _IndexState extends State<Index> {
  var arguments;

  _IndexState(
      {this.arguments}); // for Checking if User  start App first time or come back from logout button

  bool? isIntroDone = false;
  int introScreenCount = 4;

  var _pageController = PageController();
  var _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isIntroDone = arguments != null ? arguments['isIntroDone'] : false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? result = await showDialogBox(
          context: context,
          actionOneBgColor: mateRed,
          actionOneTextColor: Colors.white,
          actionTwoBgColor: greyBorderColor,
          actionTwoTextColor: blackFont,
          title: "Exit app",
          description: "Are you sure want to exit app?",
          actionOneText: AppLocalization.of(context)!.exit,
          actionTwoText: AppLocalization.of(context)!.cancel,
        );
        if (result != null && result) {
          SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
        }
        return false;
      },
      child: Scaffold(
          backgroundColor: navyBlue,
          resizeToAvoidBottomInset: true,
          body: !isIntroDone! ? introScreen() : homeScreen()),
    );
  }

  Widget homeScreen() {
    return Scaffold(
      backgroundColor: navyBlue,
      body: Stack(
        children: <Widget>[
          Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset(
                  "assets/images/index_screen.png",
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      appIcon(),
                      Expanded(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      Text("Welcome to Slydo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      CurvedButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.LOGIN);
                        },
                        text: "Log in",
                        textColor: HexColor("#3F61DB"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CurvedButton(
                        backgroundColor: Color.fromARGB(38, 255, 255, 255),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(Routes.NEW_REGISTRATION);
                        },
                        text: "Register",
                        textColor: Colors.white,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // resetDeviceField(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget resetDeviceField() {
    return Container(
        child: GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed("/verify-reset-device-otp");
        Navigator.of(context).pushNamed(Routes.RESET_DEVICE);
      },
      child: Text(
        "Reset device?",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: mateRed),
      ),
    ));
  }

  Widget loginButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: 300,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.LOGIN);
        },
        textColor: Colors.white,
        color: blackFont,
        height: 50,
        child: Text(AppLocalization.of(context)!.login),
      ),
    );
  }

  Widget registerButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: 300,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.NEW_REGISTRATION);
        },
        textColor: Colors.white,
        color: blackFont,
        height: 50,
        child: Text(AppLocalization.of(context)!.register),
      ),
    );
  }

  Widget appIcon() {
    return Container(
        child: Image.asset(
      'assets/images/app_logo.png',
      height: MediaQuery.of(context).size.height / 10,
      frameBuilder: imageFrameBuilder,
    ));
  }

  Widget introScreen() {
    return Stack(
      children: <Widget>[
        _buildPageView(),
        _buildCircleIndicator(),
        _buildSkipButton()
      ],
    );
  }

  Widget _buildPageView() {
    return Container(
      color: Colors.black87,
      child: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          _currentPageNotifier.value = index;
          setState(() {});
        },
        children: <Widget>[
          firstScreen(),
          secondScreen(),
          thirdScreen(),
          fourthScreen()
        ],
      ),
    );
  }

  Widget _buildCircleIndicator() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 2.0.h,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CirclePageIndicator(
          size: 1.5.w,
          selectedSize: 1.6.w,
          dotColor: HexColor('#BEC2F4'),
          selectedDotColor: navyBlue,
          itemCount: introScreenCount,
          currentPageNotifier: _currentPageNotifier,
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      right: 20.0,
      top: MediaQuery.of(context).padding.top + 20,
      child: skipButton(),
    );
  }

  Widget firstScreen() {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: Image.asset(
              "assets/images/intro_images/screen_one.png",
              frameBuilder: imageFrameBuilder,
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Text(
                      "SCAN QR CODE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      child: Text(
                        "Scan QR Code to make payment. Easy and secure.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0, color: darkGrey, height: 1.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget secondScreen() {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: Image.asset(
              "assets/images/intro_images/screen_two.png",
              frameBuilder: imageFrameBuilder,
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Text(
                      "SEND PAYMENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      child: Text(
                        "Send money fast to anyone, anywhere in Africa.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0, color: darkGrey, height: 1.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget thirdScreen() {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: Image.asset(
              "assets/images/intro_images/screen_four.png",
              frameBuilder: imageFrameBuilder,
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Text(
                      "RECEIVE PAYMENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      child: Text(
                        "Receive instant payment from your customers.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0, color: darkGrey, height: 1.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget fourthScreen() {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: Image.asset(
              "assets/images/intro_images/screen_three.png",
              frameBuilder: imageFrameBuilder,
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Text(
                      "VIEW TRANSACTIONS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      child: Text(
                        "See how much you receive and spend daily, weekly and monthly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0, color: darkGrey, height: 1.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // put this when you don't want to go direct in home page on skip btn
  ///() {
  ///         if (_currentPageNotifier.value != 3) {
  ///           _pageController.animateToPage(3,
  ///               duration: Duration(seconds: 1), curve: Curves.easeIn);
  ///         } else {
  ///           isIntroDone = true;
  ///           if (mounted) setState(() {});
  ///         }
  ///       },

  Widget skipButton() {
    return GestureDetector(
      child: Text(
        _currentPageNotifier.value == 3 ? "Done" : "Skip",
        style: TextStyle(fontSize: 14.0, color: darkGrey),
      ),
      onTap: () {
        isIntroDone = true;
        if (mounted) setState(() {});
      },
    );
  }
}
