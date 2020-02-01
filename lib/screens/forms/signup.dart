import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

var banks = {
  'Union Bank Of Nigeria Plc': 'union-bank-of-nigeria-plc',
  'Unity Bank Plc': 'unity-bank-plc',
  'Providus Bank': 'providus-bank',
  'Zenith Bank Plc': 'zenith-bank-plc',
  'Citibank Nigeria Limited': 'citibank-nigeria-limited',
  'Stanbic Ibtc Bank Ltd': 'stanbic-ibtc-bank-ltd',
  'Guaranty Trust Bank Plc': 'guaranty-trust-bank-plc',
  'Suntrust Bank Nigeria Limited': 'suntrust-bank-nigeria-limited',
  'Access Bank Plc': 'access-bank-plc',
  'Key Stone Bank': 'key-stone-bank',
  'First Bank Nigeria Limited': 'first-bank-nigeria-limited',
  'Sterling Bank Plc': 'sterling-bank-plc',
  'Ecobank Nigeria Plc': 'ecobank-nigeria-plc',
  'Standard Chartered Bank Nigeria Ltd': 'standard-chartered-bank-nigeria-ltd',
  'Heritage Banking Company Ltd': 'heritage-banking-company-ltd',
  'Globus Bank Limited': 'globus-bank-limited',
  'Titan Trust Bank Ltd': 'titan-trust-bank-ltd',
  'United Bank For Africa Plc': 'united-bank-for-africa-plc',
  'Diamond Bank Plc': 'diamond-bank-plc',
  'First City Monument Bank Plc': 'first-city-monument-bank-plc',
  'Polaris Bank': 'polaris-bank',
  'Fidelity Bank Plc': 'fidelity-bank-plc',
  'Wema Bank Plc': 'wema-bank-plc'
};

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  String phoneNumber = '';

  String bankName = 'First Bank Nigeria Limited';
  String accountName = '';
  String accountNumber = '';

  String password1 = '';
  String password2 = '';

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
                  getBankNameField(),
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

  Widget getBankNameDropDownMenu() {
    return DropdownButtonFormField<String>(
      value: bankName,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      onChanged: (String newValue) {
        setState(() {
          bankName = newValue;
        });
      },
      items: banks.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
    );
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
          labelText: "Phone Number",
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

  Widget getBankNameField() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: "Bank Name",
          hintText: "Bank Name",
          labelStyle: TextStyle(
            color: darkBlue(),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) => val.isEmpty ? "Enter a valid bank name." : null,
      onChanged: (val) {
        setState(() {
          bankName = val;
        });
      },
    );
  }

  Widget getAccountNameField() {
    return TextFormField(
      autofocus: true,
      obscureText: false,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: "Account Name",
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
          labelText: "Account Number",
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
          labelText: "Password",
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
          labelText: "Confirm Password",
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
