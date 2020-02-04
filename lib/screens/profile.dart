import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: darkBlue(),
                  title: Text(
                    "Are you Sure Want To Exit ?",
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: <Widget>[
                    MaterialButton(
                      color: Colors.white,
                      child: Text("Yes", style: TextStyle(color: darkBlue())),
                      onPressed: () => exit(0),
                    ),
                    MaterialButton(
                      color: Colors.white,
                      child:
                          Text("Cancel", style: TextStyle(color: darkBlue())),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ));

        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Center(child: Text("Home")),
          actions: <Widget>[
            displayQRCodeButton(),
          ],
        ),
        body: Center(
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  displayUserInfo(),
                  SizedBox(height: 30),
                  displayPaymentButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayUserInfo() {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Center(
      child: Card(
        semanticContainer: true,
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(40),
              child: Image.network(
                userBloc.user.qrCode,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
              ),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {},
                    child: Text(userBloc.user.fullName,
                        style: TextStyle(color: Colors.black, fontSize: 14))),
                FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.settings, color: Colors.black),
                    label: Text('Copy Url',
                        style: TextStyle(color: Colors.black, fontSize: 14))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayPaymentButton() {
    return ButtonTheme(
      //elevation: 4,
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        onPressed: () {
          Navigator.of(context).pushNamed('/send-payment');
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Make a Payment"),
      ),
    );
  }

  Widget displayQRCodeButton() {
    return IconButton(
      icon: Icon(Icons.camera),
      onPressed: () {
        Navigator.of(context).pushNamed('/scan-qr');
      },
    );
  }
}
