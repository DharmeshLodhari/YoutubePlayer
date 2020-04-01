import 'package:Slydo/widget/exit_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'screens/colors.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  List<PageViewModel> pageModel;
  //intro screen page index
  int currentIndex = 0;

  @override
  void initState() {
    //TODO: first page select the country
    //TODO: Second page Enter the PhoneNumber and registration data
    //TODO: third page user can Upload with onfido
    //TODO: fourth page Registration Button
    //TODO: fifth page enter verification code

    //TODO: LOGGED the user in after registration

    pageModel = [
      PageViewModel(
        decoration: PageDecoration(
            pageColor: lightBlue(),
            imagePadding: EdgeInsets.fromLTRB(0.0, 70, 0, 0),
            titlePadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            contentPadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            descriptionPadding: EdgeInsets.fromLTRB(20, 30, 20, 0)),
        titleWidget: Text(
          "Scan QR Code",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              "Slydo allows you to send and receive\npayments instantly in Africa",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        image: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Image.asset(
            'assets/images/Group16@2x.png',
            scale: 1,
          ),
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
            pageColor: lightBlue(),
            imagePadding: EdgeInsets.fromLTRB(0.0, 70, 0, 0),
            titlePadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            contentPadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            descriptionPadding: EdgeInsets.fromLTRB(20, 30, 20, 0)),
        titleWidget: Text(
          "Send Payment",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              "Slydo allows you to send and receive\npayments instantly in Africa",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        image: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Image.asset(
            'assets/images/Group15@2x.png',
            scale: 1,
          ),
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
            pageColor: lightBlue(),
            imagePadding: EdgeInsets.fromLTRB(0.0, 70, 0, 0),
            titlePadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            contentPadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            descriptionPadding: EdgeInsets.fromLTRB(20, 30, 20, 0)),
        titleWidget: Text(
          "View transactions",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              "Slydo allows you to send and receive\npayments instantly in Africa",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        image: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Image.asset(
            'assets/images/Group14@2x.png',
            scale: 1,
          ),
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
            pageColor: lightBlue(),
            imagePadding: EdgeInsets.fromLTRB(0.0, 70, 0, 0),
            titlePadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            contentPadding: EdgeInsets.fromLTRB(0.0, 30, 0, 0),
            descriptionPadding: EdgeInsets.fromLTRB(20, 30, 20, 0)),
        titleWidget: Text(
          "View transactions",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              "Slydo allows you to send and receive\npayments instantly in Africa",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        image: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Image.asset(
            'assets/images/Group13@2x.png',
            scale: 1,
          ),
        ),
      ),
    ];
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => ExitAlertDialog(),
        );

        return false;
      },
      child: Scaffold(
          backgroundColor: lightBlue(),
          resizeToAvoidBottomInset: true,
          body: introScreen()),
    );
  }

  introScreen() {
    return IntroductionScreen(
      initialPage: currentIndex,
      showSkipButton: true,
      skip: const Text("Skip",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      done: const Text("Done",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: darkBlue(),
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
      onDone: () {
        setState(() {
//          isIntroDone = true;
        });
      },
      onChange: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      pages: pageModel,
    );
  }
}
