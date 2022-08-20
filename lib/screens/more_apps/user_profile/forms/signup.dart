import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/secure_storage.dart';
import '../../../../utils/cache_manager.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  var arguments;

  SignUp({required this.arguments});

  @override
  _SignUpState createState() => _SignUpState(arguments: arguments);
}

class _SignUpState extends State<SignUp> {
  var arguments;

  _SignUpState({required this.arguments});

  final _registrationFormKey = GlobalKey<FormState>();
  final _officialDetailFormKey = GlobalKey<FormState>();

  String? phoneNumber = '';
  String password = '';

  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _nickNameController;
  TextEditingController? _userNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;

  DateTime dob = DateTime.now();
  String? gender;

  UserBloc? userBloc;

  List<String> genders = ["Male", "Female"];

  bool isOfficialInfoSet = false;

  bool? isValidAge;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];

    _phoneNumberController = TextEditingController();
    _phoneNumberController!.text = phoneNumber!;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _nickNameController = TextEditingController();
    _userNameController = TextEditingController();
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

        if (isOfficialInfoSet == false) {
          Navigator.pop(context);
        } else {
          isOfficialInfoSet = false;
          if (mounted) setState(() {});
        }

        return Future.value(false);
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
              if (isOfficialInfoSet == false) {
                Navigator.pop(context);
              } else {
                isOfficialInfoSet = false;
                if (mounted) setState(() {});
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appIcon(),
                  SizedBox(
                    height: 10,
                  ),
                  registerTitle(),
                  SizedBox(
                    height: 40,
                  ),
                  // phoneNumberField(),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  !isOfficialInfoSet
                      ? Form(
                          key: _officialDetailFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nameInstructionNote(),
                              SizedBox(height: 20),
                              firstNameField(),
                              SizedBox(height: 10),
                              lastNameField(),
                              SizedBox(height: 10),
                              getDOBField(),
                              if (isValidAge != null && !isValidAge!)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      "You are not eligible to use Slydo",
                                      style: TextStyle(
                                          color: mateRed, fontSize: 13),
                                    ),
                                  ],
                                )
                              else
                                Container(),
                              SizedBox(
                                height: 20,
                              ),
                              getGenderField(),
                              SizedBox(
                                height: 40,
                              ),
                              nextBtn(),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: _registrationFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userNameField(),
                              SizedBox(
                                height: 20,
                              ),
                              nickNameField(),
                              SizedBox(
                                height: 20,
                              ),
                              passwordField(),
                              SizedBox(
                                height: 10,
                              ),
                              passwordInstruction(),
                              SizedBox(
                                height: 20,
                              ),
                              confirmPasswordField(),
                              SizedBox(
                                height: 20,
                              ),
                              registrationTermsAndCondition(),
                              SizedBox(
                                height: 40,
                              ),
                              registerBtn(),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
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
      hintText: "08023000000",
      keyboardType: TextInputType.phone,
      isReadOnly: true,
    );
  }

  Widget nameInstructionNote() {
    return Container(
      child: Text(
        "Please ensure the information below matches that which is on your government issued ID",
        style: TextStyle(
            fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget firstNameField() {
    return CustomizedTextFormField(
      controller: _firstNameController,
      labelColor: darkGrey,
      labelText: "First name",
      keyboardType: TextInputType.name,
      validator: fullNameValidator,
    );
  }

  Widget lastNameField() {
    return CustomizedTextFormField(
      controller: _lastNameController,
      labelColor: darkGrey,
      labelText: "Surname",
      keyboardType: TextInputType.name,
      validator: fullNameValidator,
    );
  }

  String? fullNameValidator(String enteredName) {
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
    if (nameList.length >= 2) {
      if (notValidProfessionTitles.contains(nameList[0].toLowerCase())) {
        return "Please remove ${nameList[0]} from name";
      }
      if (nameList[0].length < 2 || nameList[1].length < 2) {
        return "Please enter valid name";
      }
    }

    for (int i = 0; i < nameList.length; i++) {
      return checkSlydoName(nameList[i]);
    }

    return null;
  }

  Widget userNameField() {
    return CustomizedTextFormField(
      controller: _userNameController,
      labelColor: darkGrey,
      labelText: "Username",
      keyboardType: TextInputType.text,
      validator: userNameValidator,
    );
  }

  String? userNameValidator(String username) {
    // alphanumeric and -_.
    RegExp validCharacters = RegExp(r'^[a-zA-Z 0-9\.\+\-\_]*$');

    // RegExp(r'^[a-z0-9]([._-](?![._-])|[a-z0-9]){3,18}[a-z0-9]$');

    if (!validCharacters.hasMatch(username)) {
      return "Username is not valid";
    }

    return checkSlydoName(username);
  }

  Widget nickNameField() {
    return CustomizedTextFormField(
      controller: _nickNameController,
      labelColor: darkGrey,
      labelText: "Nick name",
      keyboardType: TextInputType.name,
      validator: nickNameValidator,
    );
  }

  String? nickNameValidator(String nickName) {
    if (_nickNameController?.text.trim() == _userNameController?.text.trim()) {
      return "Nickname and Username should not be same";
    }
    return checkSlydoName(nickName);
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
      labelText: "Password",
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      obscureText: true,
      maxLength: 6,
      isPassword: true,
      validator: validateEnteredConfirmPassword,
    );
  }

  Widget getDOBField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(dob.year, dob.month, dob.day),
          firstDate: DateTime(1920, 0, 1),
          lastDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ).then((value) {
          dob = DateTime(value!.year, value.month, value.day);
          setState(() {});
          validateDOB();
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Birthdate",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(dob),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              SlydoAppIcon.date,
              size: 16,
              color: darkGrey,
            ),
          ),
        ),
      ),
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

  Widget nextBtn() {
    return CurvedButton(
      onPressed: triggerInfoChange,
      text: "Next",
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  void triggerInfoChange() {
    if (_officialDetailFormKey.currentState!.validate() && validateDOB()) {
      if (gender != null) {
        isOfficialInfoSet = !isOfficialInfoSet;
        if (mounted) setState(() {});
      } else {
        showToast(message: 'Pick a gender');
      }
    }
  }

  bool validateDOB() {
    DateTime dateTime = DateTime.now();

    if (dob.add(Duration(days: 4745)).isBefore(dateTime)) {
      isValidAge = true;
      return true;
    } else {
      isValidAge = false;
      setState(() {});
      return false;
    }
  }

  // validate password
  String? validateEnteredPassword(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
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
  String? validateEnteredConfirmPassword(String val) {
    var matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    } else if (val != _passwordController!.text) {
      return AppLocalization.of(context)!.passwordMismatch;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  Widget getGenderField() {
    return CustomizedDropDownField(
      title: "Gender",
      child: ListTile(
        dense: true,
        title: Text(
          gender != null ? gender! : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectGenderField();
        },
      ),
    );
  }

  void selectGenderField() async {
    final pressedGender = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: genders.map<Widget>((data) {
                          if (gender == data) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  data,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, data);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              data,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, data);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedGender != null) {
      gender = pressedGender;
      setState(() {});
    }
  }

  // validate the all field in the form then authenticate user and navigate him to dashboard screen
  void registerUser() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (_registrationFormKey.currentState!.validate()) {
      phoneNumber = _phoneNumberController!.text.trim();
      password = _passwordController!.text.trim();

      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      debugPrint("DOB:- ${dateFormat.format(dob)}");

      String selectedGender = "";
      if (gender == "Male") {
        selectedGender = "M";
      } else if (gender == "Female") {
        selectedGender = "F";
      }

      String firstName = _firstNameController!.text.trim();
      String lastName = _lastNameController!.text.trim();

      Map<String, dynamic> data = {
        "phone_number": _phoneNumberController!.text.trim(),
        "firstname": firstName,
        "lastname": lastName,
        "full_name": "$firstName $lastName",
        "dob": dateFormat.format(dob),
        "gender": selectedGender,
        "username": _userNameController!.text.trim(),
        "nickname": _nickNameController!.text.trim(),
        "password1": _passwordController!.text.trim(),
        "password2": _confirmPasswordController!.text.trim(),
      };
      debugPrint("DATA SENT:- $data");

      showDialog(context: context, builder: (context) => LoadingIndicator());

      bool isRegistered;
      await UserAuth().userRegistration(data).then((value) async {
        isRegistered = value;
        if (isRegistered) {
          // Clear cache and other datas. We do this in case the user registers
          // with a phone that another user was previously logged in with.
          // We clear the previous user's data.
          CacheManager().deleteCache();
          await SecureStorage().clear();

          Navigator.pop(context);
          Navigator.of(context).popAndPushNamed(Routes.LOGIN);
          showToast(message: 'Successfully registered');
        }
      }).catchError((error) {
        Navigator.pop(context);
        showToast(message: error.toString());
      });
    } else {
      var msg = AppLocalization.of(context)!.invalidDetails;
      showToast(message: msg);
    }
  }
}
