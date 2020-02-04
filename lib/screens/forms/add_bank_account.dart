import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  int _currentIndex = 1;
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  String bankName;
  String accountName;
  int accountNumber;
  bool isDefault = false;

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text('Add A Bank Account'),
          elevation: 0.0,
        ),
        body: Container(
          color: lightBlue(),
          child: Form(
            key: _formKey,
            child: Container(
//            color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                    ),
                    TextFormField(
                      autofocus: false,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Bank Name",
                          hintText: "Bank Name",
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.green,
                                  style: BorderStyle.solid))),
                      validator: (val) =>
                          val.isEmpty ? "Enter a valid bank name." : null,
                      onChanged: (val) {
                        setState(() {
                          bankName = val;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autofocus: false,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Account Name",
                          hintText: "Account Name",
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.green,
                                  style: BorderStyle.solid))),
                      validator: (val) => val.length < 5
                          ? "Enter a valid name matching account number."
                          : null,
                      onChanged: (val) {
                        setState(() {
                          accountName = val;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autofocus: false,
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Account Number",
                          hintText: "Account Number",
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.green,
                                  style: BorderStyle.solid))),
                      validator: (val) => val.length < 10
                          ? "Enter a valid account number."
                          : null,
                      onChanged: (val) {
                        setState(() {
                          accountNumber = int.parse(val);
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Set as default account"),
                    Switch(
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value;
                        });
                      },
                      activeTrackColor: darkBlue(),
                      activeColor: darkBlue(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    ButtonTheme(
                      //elevation: 4,
                      //color: Colors.green,
                      minWidth: double.infinity,
                      child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            Map data = {
                              "customer_username": userBloc.user.userName,
                              "bank": bankName,
                              "account_name": accountName,
                              "account_number": accountNumber,
                              "is_default": isDefault,
                            };
                            bool wasSuccessful =
                                await _auth.addBankAccount(data);
                            if (wasSuccessful) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/accounts", (r) => false);
                            } else {
                              setState(() {
                                errorMessage =
                                    "An error has occured please try again";
                              });
                            }
                          }
                        },
                        textColor: Colors.white,
                        color: darkBlue(),
                        height: 50,
                        child: Text("Submit"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
