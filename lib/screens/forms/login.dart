import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  String phoneNumber = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    //final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20.0),
                    padding: EdgeInsets.all(10.0),
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
                  ),
                  phoneNumberField(),
                  SizedBox(
                    height: 30.0,
                  ),
                  passwordField(),
                  SizedBox(
                    height: 30.0,
                  ),
                  submitButton(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget phoneNumberField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
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
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
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
      validator: (val) => val.length < 6 ? "Enter a valid Password." : null,
      onChanged: (val) {
        setState(() {
          password = val.trim();
        });
      },
    );
  }

  Widget submitButton(context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return ButtonTheme(
      //elevation: 4,
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            var _user = await _auth.authenticate(phoneNumber, password);
            if (_user.fullName.isNotEmpty) {
              userBloc.user = _user;
              Navigator.of(context).pushNamed('/dashboard');
            }
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("LOGIN"),
      ),
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
}
