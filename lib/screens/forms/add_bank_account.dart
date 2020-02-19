import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/bank.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  String bankName = 'first-bank-nigeria-limited';
  String accountName = "";
  String accountNumber = "";
  bool isDefault = false;
  List<Bank> banks = getBanks();

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
                    getBankNameDropDownMenu(),
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

  Widget getBankNameDropDownMenu() {
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
              width: 1, color: Colors.white, style: BorderStyle.solid),
        ),
      ),
      value: bankName,
      icon: Flexible(
        child: Icon(
          Icons.keyboard_arrow_down,
        ),
        fit: FlexFit.loose,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      onChanged: (String val) {
        setState(() {
          bankName = val.trim();
        });
      },
      items: banks.map((bank) {
        return DropdownMenuItem(
          value: bank.slug.trim(),
          child: Text(
            bank.name,
            style: TextStyle(color: darkBlue(), fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  Widget getAccountName() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Name",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length < 5 ? "Enter a valid name matching account number." : null,
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
          prefixIcon: Icon(Icons.format_list_numbered),
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Number",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length < 10 ? "Enter a valid account number." : null,
      onChanged: (val) {
        setState(() {
          accountNumber = val;
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
              Navigator.of(context)
                  .pushNamed('/dashboard', arguments: {'dashboardIndex': 4});
            } else {
              setState(() {
                errorMessage = "An error has occured please try again";
              });
            }
          } else {
            var msg = "Invalid Bank Details !!";
            Toast.show(msg, context,
                gravity: Toast.BOTTOM,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
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
