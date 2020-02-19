import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    getLoggedInUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightBlue(),
      child: SpinKitChasingDots(
        color: Colors.white,
        size: 100.0,
        duration: Duration(milliseconds: 4000),
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
        Navigator.of(context).pushNamed("/home");
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
                      Navigator.of(context).pushNamed('/dashboard',
                          arguments: {'dashboardIndex': 0});
                    }
                  } catch (e) {}
                });
              }
            } else {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/home");
            }
          });
        } else {
          Navigator.pop(context);
          Navigator.of(context).pushNamed("/home");
        }
      }
    } else {
      Navigator.pop(context);
      Navigator.of(context).pushNamed("/home");
    }
  }
}
