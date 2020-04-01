import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../widget/exit_alert_dialog.dart';
import 'colors.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  var arguments;
  Home({this.arguments});
  @override
  _HomeState createState() => _HomeState(arguments: arguments);
}

class _HomeState extends State<Home> {
  var arguments;
  _HomeState({this.arguments});

  // for Checking if User  start App first time or come back from logout button
  bool isIntroDone = false;
  //intro screen page index
  int currentIndex = 0;
  List<PageViewModel> pageModel;
  @override
  void initState() {
    isIntroDone = arguments != null ? arguments['isIntroDone'] : false;
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

  @override
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
          body: !isIntroDone ? introScreen() : homeScreen()),
    );
  }

  Widget homeScreen() {
    return Center(
      child: Container(
        color: lightBlue(),
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              showHomeBackground(),
              SizedBox(height: 20),
              Text('An easy way to accept \n and receive payments.',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              SizedBox(height: 20),
              loginButton(),
              SizedBox(height: 10),
              Text(
                'or',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 10),
              registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: double.infinity,
        onPressed: () {
          Navigator.of(context).pushNamed('/login');
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Log In"),
      ),
    );
  }

  Widget registerButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: double.infinity,
        onPressed: () {
          Navigator.of(context).pushNamed('/register');
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Register"),
      ),
    );
  }

  Widget showHomeBackground() {
    return Container(
      child: Image.asset(
        'assets/images/index.png',
        fit: BoxFit.cover,
      ),
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
          isIntroDone = true;
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
