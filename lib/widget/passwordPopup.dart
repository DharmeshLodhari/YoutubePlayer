import 'package:Slydo/data/state_notifier.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../screens/colors.dart';
import '../services/auth.dart';

class PasswordPopup extends StatefulWidget {
  var arguments;

  PasswordPopup({@required this.arguments});

  @override
  _PasswordPopupState createState() =>
      _PasswordPopupState(arguments: arguments);
}

class _PasswordPopupState extends State<PasswordPopup> {
  UserBloc userBloc;
  http.Response response;
  Map arguments;
  String errorMessage = "";
  String _password = "";
  AuthService _auth;
  Map data;
  bool isRequest = false;
  TextEditingController _passwordController;

  //for if we are checking password for showing account balance
  bool isForShowingBalance = false;

  _PasswordPopupState({@required this.arguments});

  @override
  void initState() {
    if (arguments.containsKey("isForShowingBalance")) {
      isForShowingBalance = arguments['isForShowingBalance'];
    } else {
      _auth = arguments['_auth'];
      data = arguments['data'];
      isRequest = arguments != null
          ? arguments['isRequest'] != null ? arguments['isRequest'] : false
          : false;
    }

    _passwordController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          backgroundColor: lightBlue(),
          appBar: AppBar(
            backgroundColor: lightBlue(),
            elevation: 0,
            leading: cancelPasswordPromptButton(),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Container(
                color: lightBlue(),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 80),
                    Text("Enter Your Password",
                        style: TextStyle(color: darkBlue(), fontSize: 18)),
                    SizedBox(height: 20),
                    passwordInput(),
                    SizedBox(height: 100.0),
                    passwordPromptButton(),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget passwordInput() {
    return TextFormField(
      maxLength: 4,
      maxLengthEnforced: true,
      onFieldSubmitted: verifyData,
      autovalidate: true,
      autofocus: false,
      obscureText: true,
      validator: (value) {
        if (value.length < 4) {
          return "Please enter 4 digit password !!";
        }
        return null;
      },
      controller: _passwordController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.send,
      decoration: InputDecoration(
          errorStyle: TextStyle(
              fontSize: 16, color: darkBlue(), fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green, width: 2)),
          contentPadding: EdgeInsets.all(20),
          isDense: true,
          hintText: "Password",
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }

  Widget cancelPasswordPromptButton() {
    return MaterialButton(
      child: Icon(Icons.cancel, color: Colors.red),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget passwordPromptButton() {
    return ButtonTheme(
      //elevation: 4,
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        onPressed: () {
          verifyData(_password);
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Submit"), // change this to make payment request button to
      ),
    );
  }

  void verifyData(var password) {
    if (_passwordController.text != "" &&
        _passwordController.text.length == 4) {
      _password = _passwordController.text;

      //for hiding keyboard
      FocusScope.of(context).unfocus();

      if (_password == userBloc.user.password) {
        Connectivity().checkConnectivity().then((value) {
          var connectionResult = value;
          if (connectionResult == ConnectivityResult.wifi ||
              connectionResult == ConnectivityResult.mobile) {
            //if checking Password For showing account Balance
            if (isForShowingBalance) {
              Navigator.of(context).pushNamed('/dashboard',
                  arguments: {'dashboardIndex': 4, 'isLocked': false});
            } else {
              //if checking Password For requesting Payment
              if (isRequest) {
                var result = false;
                _auth.createPaymentRequests(data).then((value) {
                  result = value;
                  if (result) {
                    Navigator.of(context).pushNamed('/dashboard',
                        arguments: {'dashboardIndex': 1});
                  } else if (!result) {
                    Toast.show("Request Not Send ", context,
                        gravity: Toast.TOP,
                        backgroundColor: darkBlue(),
                        textColor: Colors.white);
                  } else {
                    setState(() {
                      errorMessage = "Wrong Password !!";
                      Toast.show(errorMessage, context,
                          gravity: Toast.TOP,
                          backgroundColor: darkBlue(),
                          textColor: Colors.white);
                    });
                  }
                });
              }

              //if checking Password For sending Payment
              else if (!isRequest) {
                _auth.makePayment(data).then((value) {
                  response = value;
                  if (response.statusCode == 200) {
                    Navigator.of(context).pushNamed('/dashboard',
                        arguments: {'dashboardIndex': 2});
                  } else if (response.statusCode == 500) {
                    setState(() {
                      errorMessage = "Server Error";
                      Toast.show(errorMessage, context,
                          gravity: Toast.TOP,
                          backgroundColor: darkBlue(),
                          textColor: Colors.white);
                    });
                  } else {
                    setState(() {
                      errorMessage = "Wrong Password !!";
                      Toast.show(errorMessage, context,
                          gravity: Toast.TOP,
                          backgroundColor: darkBlue(),
                          textColor: Colors.white);
                    });
                  }
                });
              }
            }
          } else {
            Toast.show("Internet Connection is not available", context,
                gravity: Toast.BOTTOM, backgroundColor: darkBlue());
          }
        });
      } else {
        errorMessage = "Incorrect Password !!";
        Toast.show(errorMessage, context,
            gravity: Toast.TOP,
            backgroundColor: darkBlue(),
            textColor: Colors.white);
      }
    } else {
      errorMessage = "Please enter 4 digit password !!";
      Toast.show(errorMessage, context,
          gravity: Toast.TOP,
          backgroundColor: darkBlue(),
          textColor: Colors.white);
    }
  }
}
