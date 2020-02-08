import 'dart:io';

import 'package:Slydo/models/bank.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import '../../widget/LoadingIndicator.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  File _image;

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Sign up'),
          backgroundColor: darkBlue(),
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  displayImage(),
                  SizedBox(height: 10),
                  getImageField(),
                  SizedBox(height: 10),
                  getPhoneNumberField(),
                  SizedBox(height: 10),
                  getBankNameDropDownMenu(),
                  SizedBox(height: 10),
                  getAccountNameField(),
                  SizedBox(height: 10),
                  getAccountNumberField(),
                  SizedBox(height: 10),
                  Container(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Use 4 Digit Number')),
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
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ));
  }

  Widget displayImage() {
    return Center(
      child: _image == null
          ? Text('No image selected.')
          : Image.file(
              _image,
              height: 150.0,
              width: 150.0,
            ),
    );
  }

  Widget getImageField() {
    return FloatingActionButton(
      onPressed: getImage,
      tooltip: 'Pick Image',
      child: Icon(Icons.add_a_photo),
    );
  }

  void getImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Camera"),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery"),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final image = await ImagePicker.pickImage(source: imageSource);
      if (image != null) {
        setState(() => _image = image);
      }
    }
  }

  Widget getPhoneNumberField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon:
            Icon(Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone),
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
              width: 1, color: Colors.white, style: BorderStyle.solid),
        ),
      ),
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

  Widget getAccountNameField() {
    return TextFormField(
      autofocus: true,
      obscureText: false,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
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
          accountName = val.trim();
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
          prefixIcon: Icon(Icons.format_list_numbered),
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
          accountNumber = val.trim();
        });
      },
    );
  }

  Widget getPassword1Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      maxLengthEnforced: true,
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
      validator: (val) => val.length != 4 ? "Enter a valid Password." : null,
      onChanged: (val) {
        setState(() {
          password1 = val.trim();
        });
      },
    );
  }

  Widget getPassword2Field() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      maxLength: 4,
      maxLengthEnforced: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
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
      validator: (val) {
        if (val.length != 4) {
          return "Enter a valid Password.";
        } else if (val != password1) {
          return "Password MissMatch";
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          password2 = val.trim();
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
              "avatar": _image,
            };

            showDialog(
                context: context, builder: (context) => LoadingIndicator());

            bool isRegistered;
            _auth.userRegistration(data).then((value) {
              isRegistered = value;
              if (isRegistered) {
                Navigator.of(context).pushNamed('/login');
              }
            });
          } else {
            var msg = "Invalid Details !!";
            Toast.show(msg, context,
                gravity: Toast.BOTTOM,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
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
