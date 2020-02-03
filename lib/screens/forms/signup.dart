import 'package:Slydo/models/bank.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  String phoneNumber = '';

  String bankName = 'first-bank-nigeria-limited';
  String accountName = '';
  String accountNumber = '';

  String password1 = '';
  String password2 = '';
  List<Bank> banks = getBanks();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Sign up'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  getPhoneNumberField(),
                  SizedBox(height: 10),
                  getBankNameDropDownMenu(),
                  SizedBox(height: 10),
                  getAccountNameField(),
                  SizedBox(height: 10),
                  getAccountNumberField(),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                        'Use 8 or more characters with a mix of letters, numbers & symbols'),
                  ),
                  SizedBox(height: 10),
                  getPassword1Field(),
                  SizedBox(height: 10),
                  getPassword2Field(),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                        'By clicking Register you are agreeing to the Terms and Conditions.'),
                  ),
                  SizedBox(height: 10),
                  getSubmitButton(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget getPhoneNumberField() {
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
          phoneNumber = val;
        });
      },
    );
  }

  Widget getBankNameDropDownMenu() {
    return Container(
        color: Colors.white,
        child: DropdownButtonFormField(
      value: bankName,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      onChanged: (String val) {
        setState(() {
          bankName = val;
        });
      },
      items: banks.map((bank) {
        return DropdownMenuItem(
          value: bank.slug,
          child: Text(bank.name, style: TextStyle(color: darkBlue(), fontSize: 16),
          ),
        );
      }).toList(),
    )
    );
  }

  Widget getAccountNameField() {
    return TextFormField(
      autofocus: true,
      obscureText: false,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Name",
          labelStyle: TextStyle(
            color: darkBlue(),
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

  Widget getAccountNumberField() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Account Number",
          labelStyle: TextStyle(
            color: darkBlue(),
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

  Widget getPassword1Field() {
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
          password1 = val;
        });
      },
    );
  }

  Widget getPassword2Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Confirm Password",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) => (val.length < 6 && val != password1)
          ? "Enter a valid Password."
          : null,
      onChanged: (val) {
        setState(() {
          password2 = val;
        });
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      //elevation: 4,
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            Map data = {
              "phoneNumber": phoneNumber,
              "bankName": bankName,
              "accountName": accountName,
              "accountNumber": accountNumber,
              "password1": password1,
              "password2": password2,
            };
            bool isRegistered = await _auth.userRegistration(data);
            if (isRegistered) {
              Navigator.of(context).pushNamed('/login');
            }
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Register"),
      ),
    );
  }
}
