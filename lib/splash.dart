import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'data/state_notifier.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isChecked = false;
  bool isLoggedOut = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  SharedPreferences _sharedPreferences;

  // bool for to check if internet connection is available or not
  var hasConnection = false;

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  void checkConnection() {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        setState(() {
          hasConnection = true;
        });
        getLoggedInUser();
      } else {
        Toast.show("Internet Connection is not available", context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        setState(() {
          hasConnection = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightBlue(),
      child: hasConnection
          ? SpinKitChasingDots(
              color: Colors.white,
              size: 100.0,
              duration: Duration(milliseconds: 4000),
            )
          : Scaffold(
              backgroundColor: lightBlue(),
              appBar: AppBar(
                title: Text('Slydo'),
                backgroundColor: darkBlue(),
                elevation: 0.0,
                automaticallyImplyLeading: false,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  NoItemInList(
                    msg: "No Internet Connection !!",
                  ),
                  MaterialButton(
                    color: darkBlue(),
                    child: Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: checkConnection,
                  )
                ],
              ),
            ),
    );
  }

  Future<void> getLoggedInUser() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    if (_sharedPreferences != null) {
      isChecked = _sharedPreferences.getBool('isChecked') ?? false;
      isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
      if (isLoggedOut) {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/index");
      } else {
        phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
        passwordFromPref = _sharedPreferences.getString('password') ?? "";

        await _sharedPreferences.setBool('isLoggedOut', isLoggedOut);
        await _sharedPreferences.setBool('isChecked', isChecked);
        await _sharedPreferences.setString('username', phoneNumberFromPref);
        await _sharedPreferences.setString('password', passwordFromPref);

        var phoneNumber = phoneNumberFromPref;
        var password = passwordFromPref;

        if (phoneNumberFromPref != "" && passwordFromPref != "") {
          var _user;
          var _bankAccount;
          _auth.authenticate(phoneNumber, password).then((value) {
            _user = value;

            if (_user.fullName != null) {
              userBloc.user = _user;

              if (_user != null) {
                _auth.getBankAccounts().then((accounts) {
                  try {
                    _bankAccount = accounts[0];
                    if (_bankAccount != null) {
                      bankAccountBloc.bankAccount = _bankAccount;
                      if (_user.isVerified == true) {
                        Navigator.of(context).pushNamed('/dashboard',
                            arguments: {'dashboardIndex': 0});
                      } else {
                        Navigator.of(context).popAndPushNamed('/add-document');
                      }
                    }
                  } catch (e) {
                    Navigator.of(context).pushNamed('/dashboard',
                        arguments: {'dashboardIndex': 0});
                  }
                });
              }
            } else {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/index");
            }
          });
        } else {
          Navigator.pop(context);
          Navigator.of(context).pushNamed("/index");
        }
      }
    } else {
      Navigator.pop(context);
      Navigator.of(context).pushNamed("/index");
    }
  }
}
