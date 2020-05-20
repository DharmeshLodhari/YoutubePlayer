import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ResultReturningPasswordPopup extends StatefulWidget {
  @override
  _ResultReturningPasswordPopupState createState() =>
      _ResultReturningPasswordPopupState();
}

class _ResultReturningPasswordPopupState
    extends State<ResultReturningPasswordPopup> {
  UserBloc userBloc;
  String errorMessage = "";
  String _password = "";
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
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
        Navigator.pop(context, "false");
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
            Navigator.pop(context, "true");
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
