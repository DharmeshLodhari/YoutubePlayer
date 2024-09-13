import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class StartupScreen extends StatefulWidget {
  final dynamic arguments;

  const StartupScreen({super.key, this.arguments});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  int introScreenCount = 4;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    _checkFirstTime();
    super.initState();
  }

  Future<void> _checkFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exitAppDialog(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: lightGrey,
          resizeToAvoidBottomInset: true,
          body: onboardingScreen(),
        ),
      ),
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
}
