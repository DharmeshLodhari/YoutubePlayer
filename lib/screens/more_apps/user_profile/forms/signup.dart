import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  var arguments;

  SignUp({@required this.arguments});

  @override
  _SignUpState createState() => _SignUpState(arguments: arguments);
}

class _SignUpState extends State<SignUp> {
  var arguments;

  _SignUpState({@required this.arguments});

  final _registrationFormKey = GlobalKey<FormState>();

  String phoneNumber = '';
  String password = '';

  TextEditingController _fullNameController;
  TextEditingController _phoneNumberController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;

  UserBloc userBloc;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];

    _phoneNumberController = TextEditingController();
    _phoneNumberController.text = phoneNumber;
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _registrationFormKey,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appIcon(),
                          flexibleSpace(
                            flex: 1,
                          ),
                          registerTitle(),
                          flexibleSpace(
                            flex: 5,
                          ),
                          phoneNumberField(),
                          flexibleSpace(
                            flex: 2,
                          ),
                          fullNameField(),
                          flexibleSpace(
                            flex: 1,
                          ),
                          nameInstructionNote(),
                          flexibleSpace(
                            flex: 2,
                          ),
                          passwordField(),
                          flexibleSpace(
                            flex: 1,
                          ),
                          passwordInstruction(),
                          flexibleSpace(
                            flex: 2,
                          ),
                          confirmPasswordField(),
                          flexibleSpace(
                            flex: 2,
                          ),
                          registrationTermsAndCondition(),
                          flexibleSpace(
                            flex: 4,
                          ),
                          registerBtn(),
                          flexibleSpace(
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon() {
    return Container(
      child: Image.asset(
        "assets/images/app_logo_navyBlue.png",
        height: MediaQuery.of(context).size.height / 16,
        frameBuilder: imageFrameBuilder,
      ),
    );
  }

  Widget registerTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Register to ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
          ),
          Text(
            "Slydo",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
        ],
      ),
    );
  }

  Widget phoneNumberField() {
    return CustomizedTextFormField(
      controller: _phoneNumberController,
      labelColor: darkGrey,
      labelText: "Phone number",
      keyboardType: TextInputType.phone,
      isReadOnly: true,
    );
  }

  Widget nameInstructionNote() {
    return Container(
      child: Text(
        "Use names registered on a government issued ID",
        style: TextStyle(
            fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget fullNameField() {
    return CustomizedTextFormField(
      controller: _fullNameController,
      labelColor: darkGrey,
      labelText: "Full name",
      keyboardType: TextInputType.text,
      validator: fullNameValidator,
    );
  }

  String fullNameValidator(String enteredName) {
    List<String> nameList = enteredName.split(" ");

    /// For not allowing user to put any profession title
    List<String> notValidProfessionTitles = [
      "mr",
      "mrs",
      "miss",
      "ms",
      "chief",
      "dr",
      "prof",
      "engr",
      "evang",
    ];

    RegExp regExp = RegExp(r"^[A-Za-z\s]{1,}[A-Za-z\s]{0,}$");

    if (!regExp.hasMatch(enteredName)) {
      return "Please enter valid name";
    }
    if (nameList.length < 2) {
      return "Please enter full name";
    }
    if (notValidProfessionTitles.contains(nameList[0].toLowerCase())) {
      return "Please remove ${nameList[0]} from name";
    }
    if (nameList[0].length < 2 || nameList[1].length < 2) {
      return "Please enter valid name";
    }

    return null;
  }

  Widget passwordInstruction() {
    return Container(
      child: Text(
        "Use 6 digit number",
        style: TextStyle(
            fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget passwordField() {
    return CustomizedTextFormField(
      controller: _passwordController,
      labelColor: darkGrey,
      labelText: "New Password",
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 6,
      isPassword: true,
      validator: validateEnteredPassword,
    );
  }

  Widget confirmPasswordField() {
    return CustomizedTextFormField(
      controller: _confirmPasswordController,
      labelColor: darkGrey,
      labelText: "Confirm password",
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 6,
      isPassword: true,
      validator: validateEnteredConfirmPassword,
    );
  }

  Widget registrationTermsAndCondition() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "By clicking Register, you are agreeing to our",
            style: TextStyle(fontSize: 14, color: blackFont),
          ),
          InkWell(
            child: Text(
              "Terms and Conditions",
              style: TextStyle(
                  fontSize: 14, color: navyBlue, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              launch('http://slydo.co/terms');
            },
          ),
        ],
      ),
    );
  }

  Widget registerBtn() {
    return CurvedButton(
      onPressed: registerUser,
      text: "Register",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  // validate password
  String validateEnteredPassword(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context).invalidPassword;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  // validate confirm password
  String validateEnteredConfirmPassword(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context).invalidPassword;
    } else if (val != _passwordController.text) {
      return AppLocalization.of(context).passwordMismatch;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  // validate the all field in the form then authenticate user and navigate him to dashboard screen
  void registerUser() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (_registrationFormKey.currentState.validate()) {
      phoneNumber = _phoneNumberController.text.trim();
      password = _passwordController.text.trim();

      Map data = {
        "phoneNumber": _phoneNumberController.text.trim(),
        "fullName": _fullNameController.text.trim(),
        "password1": _passwordController.text.trim(),
        "password2": _confirmPasswordController.text.trim(),
      };

      showDialog(context: context, builder: (context) => LoadingIndicator());

      bool isRegistered;
      UserAuth().userRegistration(data).then((value) {
        isRegistered = value;
        if (isRegistered) {
          Navigator.pop(context);
          Navigator.of(context).popAndPushNamed("/login");
        }
      }).catchError((error) {
        Toast.show(error, context,
            textColor: Colors.white, backgroundColor: blackFont);
      });
    } else {
      var msg = AppLocalization.of(context).invalidDetails;
      Toast.show(
        msg,
        context,
        gravity: Toast.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }
}
