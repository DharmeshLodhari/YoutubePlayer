import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../widget/exit_alert_dialog.dart';
import 'colors.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isChecked = false;
  bool isLoggedOut = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  SharedPreferences _sharedPreferences;

  @override
  void initState() {
    getLoggedInUser();
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
        appBar: AppBar(
          title: Text('Slydo'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 100),
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
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: darkBlue(), width: 2.0)),
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
      ),
    );
  }

  Future<void> getLoggedInUser() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final _auth = AuthService();

    if (_sharedPreferences != null) {
      setState(() {
        isChecked = _sharedPreferences.getBool('isChecked') ?? false;
        isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
      });
      if (isLoggedOut) {
        return;
      } else {
        phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
        passwordFromPref = _sharedPreferences.getString('password') ?? "";

        await _sharedPreferences.setBool('isLoggedOut', isLoggedOut);
        await _sharedPreferences.setBool('isChecked', isChecked);
        await _sharedPreferences.setString('username', phoneNumberFromPref);
        await _sharedPreferences.setString('password', passwordFromPref);
        await _sharedPreferences.commit();

        var phoneNumber = phoneNumberFromPref;
        var password = passwordFromPref;

        if (phoneNumberFromPref != "" && passwordFromPref != "") {
          showDialog(
              context: context, builder: (context) => LoadingIndicator());

          var _user;
          _auth.authenticate(phoneNumber, password).then((value) {
            _user = value;

            if (_user.fullName != null) {
              userBloc.user = _user;
              Navigator.of(context)
                  .pushNamed('/dashboard', arguments: {'dashboardIndex': 0});
            } else {
              Navigator.pop(context);
              Toast.show("User is Not Registerd !!", context,
                  gravity: Toast.CENTER,
                  backgroundColor: darkBlue(),
                  textColor: Colors.white);
            }
          });
        }
      }
    }
  }
}
