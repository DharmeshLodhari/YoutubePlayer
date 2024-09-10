import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class StartupScreen extends StatefulWidget {
  final dynamic arguments;

  const StartupScreen({super.key, this.arguments});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool? isIntroDone = false;
  bool? isUserLoggedIn = false;
  int introScreenCount = 4;

  // final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isIntroDone = widget.arguments != null
              ? widget.arguments['isIntroDone']
              : false;
          isUserLoggedIn = widget.arguments != null
              ? widget.arguments['isUserLoggedIn']
              : false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool? result = await showDialogBox(
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: lightGrey,
          resizeToAvoidBottomInset: true,
          body: onboardingScreen(),
        ),
      ),
      // body: !isIntroDone! ? introScreen() : homeScreen()),
    );
  }

  Widget onboardingScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSliderIndicator(),
          const SizedBox(height: 5),
          Expanded(child: _buildIntro()),
          _buildButtons(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      children: [
        buildOnboardingPage(
          context,
          imagePath:
              'assets/images/onboarding/intro_image1.png', // Your image path for the first screen
          title: 'Your \nAll-in-One \nSuper App',
          description:
              'Simplify your lifestyle with Slydo. Manage your business, shop, and stay connected all in one place.',
        ),
        buildOnboardingPage(
          context,
          imagePath:
              'assets/images/onboarding/intro_image2.png', // Your image path for the second screen
          title: 'Fast and \nSecure \nPayments',
          description:
              'Accept payments, transfer funds, and manage your finances with ease, all securely on Slydo.',
        ),
        buildOnboardingPage(
          context,
          imagePath:
              'assets/images/onboarding/intro_image3.png', // Your image path for the third screen
          title: 'Set Up \nYour Store',
          description:
              'Open your online store, manage inventory, and reach more customers effortlessly.',
        ),
        buildOnboardingPage(
          context,
          imagePath:
              'assets/images/onboarding/intro_image4.png', // Your image path for the fourth screen
          title: 'Start \nConnecting',
          description:
              'Stay connected, build relationships, and grow your network all in one app.',
        ),
      ],
    );
  }

  Widget buildOnboardingPage(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Calistoga",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.SCAN_PRODUCT_QR);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    color: lightGrey.withOpacity(0.1),
                    border: Border.all(
                      color: navyBlue,
                      width: 1.0,
                    ),
                  ), //
                  child: Row(
                    children: [
                      Icon(
                        SlydoAppIcon.qr_code,
                        size: 16,
                        color: navyBlue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'QR',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: navyBlue,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.end,
                //     children: [
                //       SvgPicture.asset(
                //         'assets/images/home/qr_code.svg',
                //         height: 25,
                //         width: 25,
                //         color: navyBlue,
                //       ),
                //       const SizedBox(height: 5),
                //       Text(
                //         'Scan QR',
                //         style: TextStyle(
                //           color: fontLightGrey,
                //           fontSize: 14,
                //           fontWeight: FontWeight.w500,
                //           fontFamily: "Inter",
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                ),
                const SizedBox(height: 25),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightBlackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: LinearProgressIndicator(
        value: (_currentIndex + 1) / 4, // Number of pages (4)
        borderRadius: BorderRadius.circular(5.0),
        minHeight: 5,
        backgroundColor: indicatorLightBlue,
        color: navyBlue,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlineCurvedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.LOGIN);
            },
            text: "Login",
            textColor: navyBlue,
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: CurvedButton(
            backgroundColor: navyBlue,
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.REGISTRATION);
            },
            text: "Signup",
            textColor: Colors.white,
          ),
        ),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        flex: 10,
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      appIcon(),
                      const Expanded(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      const Text("Welcome to Slydo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const Expanded(
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
                      const SizedBox(
                        height: 10,
                      ),
                      CurvedButton(
                        backgroundColor:
                            const Color.fromARGB(38, 255, 255, 255),
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.REGISTRATION);
                          // Navigator.of(context).popAndPushNamed(Routes.SIGN_UP, arguments: {
                          //   'phoneNumber': '07035235209',
                          //   'otpCode': '2341',
                          //   'accountType': 'Personal'
                          // });
                        },
                        text: "Register",
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      // resetDeviceField(),
                    ],
                  ),
                ),
                const Expanded(
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
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed("/verify-reset-device-otp");
        Navigator.of(context).pushNamed(Routes.RESET_DEVICE);
      },
      child: Text(
        "Reset device?",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: mateRed),
      ),
    );
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

  Widget appIcon() {
    return Image.asset(
      'assets/images/app_logo.png',
      height: MediaQuery.of(context).size.height / 10,
      frameBuilder: imageFrameBuilder,
    );
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
      backgroundColor: lightGrey,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  const Text(
                    "SCAN QR CODE",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
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
                  const Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget secondScreen() {
    return Scaffold(
      backgroundColor: lightGrey,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  const Text(
                    "SEND PAYMENT",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
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
                  const Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget thirdScreen() {
    return Scaffold(
      backgroundColor: lightGrey,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  const Text(
                    "RECEIVE PAYMENT",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
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
                  const Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget fourthScreen() {
    return Scaffold(
      backgroundColor: lightGrey,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  const Text(
                    "VIEW TRANSACTIONS",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
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
                  const Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
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
