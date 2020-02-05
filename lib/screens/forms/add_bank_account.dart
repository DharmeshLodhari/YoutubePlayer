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
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text('Add A Bank Account'),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 80),
                    getBankName(),
                    SizedBox(height: 10),
                    getAccountName(),
                    SizedBox(height: 10),
                    getAccountNumber(),
                    SizedBox(height: 20),
                    Text("Set as default account"),
                    checkButton(),
                    SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    getSubmitButton(userBloc.user.userName),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBankName() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Bank Name",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) => val.isEmpty ? "Enter a valid bank name." : null,
      onChanged: (val) {
        setState(() {
          bankName = val;
        });
      },
    );
  }

  Widget getAccountName() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Name",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) => val.length < 5 ? "Enter a valid name matching account number." : null,
      onChanged: (val) {
        setState(() {
          accountName = val;
        });
      },
    );
  }

  Widget getAccountNumber() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Number",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) => val.length < 10 ? "Enter a valid account number." : null,
      onChanged: (val) {
        setState(() {
          accountNumber = int.parse(val);
        });
      },
    );
  }

  Widget checkButton() {
    return Switch(
      value: isDefault,
      onChanged: (value) {
        setState(() {
          isDefault = value;
        });
      },
      activeTrackColor: darkBlue(),
      activeColor: darkBlue(),
    );
  }

  Widget getSubmitButton(String userName) {
    return ButtonTheme(
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            Map data = {
              "customer_username": userName,
              "bank": bankName,
              "account_name": accountName,
              "account_number": accountNumber,
              "is_default": isDefault,
            };
            bool wasSuccessful = await _auth.addBankAccount(data);
            if (wasSuccessful) {
              Navigator.pushNamedAndRemoveUntil(context, "/accounts", (r) => false);
            } else {
              setState(() {
                errorMessage = "An error has occured please try again";
              });
            }
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Submit"),
      ),
    );
  }
}
