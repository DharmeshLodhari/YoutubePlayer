import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'colors.dart';

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
          AppLocalization.of(context).scanQrCode,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              AppLocalization.of(context).introMsg1,
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
          AppLocalization.of(context).sendPayment,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              AppLocalization.of(context).introMsg2,
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
          AppLocalization.of(context).viewTransactions,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              AppLocalization.of(context).introMsg2,
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
          AppLocalization.of(context).viewTransactions,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Text(
              AppLocalization.of(context).introMsg2,
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
        bool result = await showDialogBox(
          context: context,
          title: AppLocalization.of(context).exit,
          description: AppLocalization.of(context).areYouSureWantToExit,
          actionOne: AppLocalization.of(context).yes,
          actionTwo: AppLocalization.of(context).no,
          type: AlertType.none,
        );
        if (result) {
          SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
        }
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
              Text(
                  AppLocalization.of(context)
                      .anEasyWayToAcceptAndReceivePayment,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Expanded(child: SizedBox(height: 20)),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(flex: 3, child: loginButton()),
                    Expanded(flex: 1, child: SizedBox(height: 10)),
                    Expanded(flex: 3, child: registerButton()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: 300,
        onPressed: () {
          Navigator.of(context).pushNamed('/login');
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).login),
      ),
    );
  }

  Widget registerButton() {
    return ButtonTheme(
      child: MaterialButton(
        minWidth: 300,
        onPressed: () {
          Navigator.of(context).pushNamed('/new-registration');
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).register),
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
      skip: Text(AppLocalization.of(context).skip,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      done: Text(AppLocalization.of(context).done,
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
