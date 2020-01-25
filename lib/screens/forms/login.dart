import 'package:Slydo/data/state_notifier.dart';
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
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 60,
                  ),
//                  Center(
//                    child: SizedBox(
//                      width: 100,
//                      height: 100,
//                      child: Image.asset(
//                          'assets/images/android-chrome-192x192.png'),
//                    ),
//                  ),
                  SizedBox(
                    height: 80,
                  ),
                  TextFormField(
                    autofocus: false,
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Phone Number",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.green,
                                style: BorderStyle.solid))),
                    validator: (val) {
                      if (val.isNotEmpty && val.length == 13) {
                        return null;
                      }
                      return "Invalid phone number";
                    },
                    onChanged: (val) {
                      setState(() {
                        phoneNumber = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    autofocus: false,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.green,
                                style: BorderStyle.solid))),
                    validator: (val) =>
                        val.length < 6 ? "Enter a valid Password." : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ButtonTheme(
                    //elevation: 4,
                    //color: Colors.green,
                    minWidth: double.infinity,
                    child: MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          var _user =
                              await _auth.authenticate(phoneNumber, password);
                          if (_user.fullName.isNotEmpty) {
                            userBloc.user = _user;
                            Navigator.of(context).pushNamed('/profile');
                          }
                        }
                      },
                      textColor: Colors.white,
                      color: Colors.green,
                      height: 50,
                      child: Text("LOGIN"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
