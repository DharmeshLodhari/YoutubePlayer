import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/colors.dart';

class BvnVerificationPage extends StatefulWidget {
  @override
  _BvnVerificationPageState createState() => _BvnVerificationPageState();
}

class _BvnVerificationPageState extends State<BvnVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String bvnNumber = "";
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: lightBlue(),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                title: Center(
                    child: Text(AppLocalization.of(context).bvnVerification)),
                backgroundColor: darkBlue()),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    getBVNNumber(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                          AppLocalization.of(context).bvnTermsAndCondition),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    submitButton()
                  ],
                ),
              ),
            )));
  }

  getBVNNumber() {
    return TextFormField(
      cursorColor: darkBlue(),
      enabled: true,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_balance),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).enterYourBVNNUmber,
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
        return AppLocalization.of(context).invalidBVNNumber;
      },
      onChanged: (val) {
        bvnNumber = val;
      },
    );
  }

  Widget submitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: verifyBVN,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).verify),
      ),
    );
  }

  void verifyBVN() {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    debugPrint("$bvnNumber");

    if (_formKey.currentState.validate()) {
      //TODO:CALL API FOR VERIFICATION with bvnNumber
//      _auth.verifyBVN(bvnNumber).then((value) {
//        //IF BVN NUMBER IS RIGHT
//        if (value == true) {
//          _auth
//              .authenticate(userBloc.user.phoneNumber, userBloc.user.password)
//              .then((user) {
//            if (user.isVerified) {
//              userBloc.user = user;
//              Navigator.of(context).popAndPushNamed('/dashboard');
//            }
//          });
//        }
//        debugPrint("verify bav : $value");
//      });
    }
  }
}
