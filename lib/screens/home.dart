import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

import '../widget/exit_alert_dialog.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Slydo'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: Center(
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    child: Image.asset(
                      'assets/images/index.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'An easy way to accept \n and receive payments.',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  ButtonTheme(
                    minWidth: double.infinity,
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      textColor: Colors.white,
                      color: darkBlue(),
                      height: 50,
                      child: Text("Log In"),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'or',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  ButtonTheme(
                    minWidth: double.infinity,
                    child: MaterialButton(
                      shape:
                          RoundedRectangleBorder(side: BorderSide(color: darkBlue(), width: 2.0)),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      textColor: Colors.white,
                      color: darkBlue(),
                      height: 50,
                      child: Text("Register"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
