import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/notification.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<PushNotification> notifications = [];
  bool isRemember = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  String phoneNumber = '';
  String password = '';

  //for remember user
  bool isChecked = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  TextEditingController phoneNumberController;
  TextEditingController passwordController;
  SharedPreferences _sharedPreferences;

  Future<Null> _navigateToItemDetail(Map<String, dynamic> message) async {
    // When user clicks on the notification we can inspect message
    // then redirect user to right screen but for now we have just transactions
    //so we redirect to transactions
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    Navigator.of(context).pushNamed('/transactions');
  }

  void setupNotification() async {
    var data = await getDeviceInfo();
    _firebaseMessaging.getToken().then((String token) {
      data["token"] = token;
      _auth.registerDevice(data);
    });

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];

        setState(() {
          notifications.add(PushNotification(
              title: notification['title'],
              body: notification['body'],
              image: notification['image']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        final notification = message['notification'];
        setState(() {
          notifications.add(PushNotification(
            title: '${notification['title']}',
            body: '${notification['body']}',
            image: '${notification['image']}',
          ));
        });
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _navigateToItemDetail(message);
      },
    );
  }

  @override
  void initState() {
    getSharedPreference();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();

    // TODO: implement initState
    super.initState();
  }

  Future<void> getSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (_sharedPreferences != null) {
      setState(() {
        isChecked = _sharedPreferences.getBool('isChecked') ?? false;
      });

      if (isChecked) {
        phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
        passwordFromPref = _sharedPreferences.getString('password') ?? "";

        //setting fetched userdata into screen
        phoneNumberController.text = phoneNumberFromPref;
        passwordController.text = passwordFromPref;
        phoneNumber = phoneNumberFromPref;
        password = passwordFromPref;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                displayImage(),
                phoneNumberField(),
                SizedBox(height: 20.0),
                passwordField(),
                SizedBox(height: 20.0),
                rememberLogin(),
                SizedBox(height: 20),
                submitButton(context),
              ],
            ),
          ),
        ));
  }

  Widget displayImage() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10, 0),
      alignment: Alignment.topCenter,
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Image.asset(
        'assets/images/slydo.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget phoneNumberField() {
    return TextFormField(
      controller: phoneNumberController,
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(
              Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone),
          fillColor: Colors.white,
          filled: true,
          hintText: "Phone Number",
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return "Invalid phone number";
      },
      onChanged: (val) {
        setState(() {
          phoneNumber = val.trim();
        });
      },
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          fillColor: Colors.white,
          filled: true,
          hintText: "Password",
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) => val.length < 4 ? "Enter a valid Password." : null,
      onChanged: (val) {
        setState(() {
          password = val.trim();
        });
      },
    );
  }

  Widget submitButton(context) {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: login,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("LOGIN"),
      ),
    );
  }

  Widget rememberLogin() {
    return Row(
      children: <Widget>[
        Checkbox(
          onChanged: (value) {
            setState(() {
              if (value == true) {
                isChecked = true;
                isRemember = true;
              } else {
                isChecked = false;
                isRemember = false;
              }
            });
          },
          activeColor: Colors.white,
          value: isChecked,
          checkColor: darkBlue(),
        ),
        Expanded(
          child: Text(
            "Remember Me",
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget logo() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset('assets/images/android-chrome-192x192.png'),
      ),
    );
  }

  void isRememberChecked() async {
    bool isLoggedOut = await _sharedPreferences.setBool('isLoggedOut', false);
    if (isRemember) {
      bool isCheckedSet =
          await _sharedPreferences.setBool('isChecked', isChecked);
      bool usernameSet =
          await _sharedPreferences.setString('username', phoneNumber);
      bool passwordSet =
          await _sharedPreferences.setString('password', password);
      if (!isCheckedSet && !isLoggedOut && !usernameSet && !passwordSet) {
        Toast.show("User Not Saved !!!", context);
      }
    } else {
      _sharedPreferences.setBool('isChecked', isChecked);

      bool isSuccessFullyStored = await _sharedPreferences.commit();
      if (!isSuccessFullyStored) {
        Toast.show("User Not Saved !!!", context);
      }
    }
  }

  void login() async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    if (_formKey.currentState.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      var _user;
      BankAccount _bankAccount;

      _auth.authenticate(phoneNumber, password).then((value) {
        _user = value;

        if (_user.fullName != null) {
          //method call for storing user info in shared preference
          isRememberChecked();
          userBloc.user = _user;

          // Get user's bank account if user is logged in
          if (_user != null) {
            _auth.getBankAccounts().then((accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                }
              } catch (e) {}
            });
            setupNotification();
          }

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
