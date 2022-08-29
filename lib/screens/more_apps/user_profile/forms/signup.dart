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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/currency.dart';
import '../../../../services/secure_storage.dart';
import '../../../../utils/cache_manager.dart';
import '../screens/subscriptions/subscription_auth.dart';
import '../screens/subscriptions/subscription_model.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  var arguments;

  SignUp({required this.arguments});

  @override
  _SignUpState createState() => _SignUpState(arguments: arguments);
}

class _SignUpState extends State<SignUp> {
  var arguments;
  String? accountType;
  int? subscriptionsId;
  String? industryType;
  bool isPersonalAccount = false;
  bool accountTypeChosen = false;

  _SignUpState({required this.arguments});

  final _registrationFormKey = GlobalKey<FormState>();
  final _officialDetailFormKey = GlobalKey<FormState>();

  String? phoneNumber = '';
  String password = '';

  late TextEditingController _bvnController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _businessOrNickNameController;
  late TextEditingController _userNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  DateTime dob = DateTime.now();
  String? gender;

  UserBloc? userBloc;

  List<String> genders = ["Male", "Female"];

  bool basicAccountInfo = false;

  bool? isValidAge;

  bool verifyingUsername = false;
  bool? inputVerified;
  @override
  void initState() {
    phoneNumber = '8146748942';
    // phoneNumber = arguments['phoneNumber'];

    _phoneNumberController = TextEditingController();
    _phoneNumberController.text = phoneNumber!;
    _bvnController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _businessOrNickNameController = TextEditingController();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _businessOrNickNameController.addListener(() {
      String formattedUsername =
          _businessOrNickNameController.text.replaceAll(' ', '.').toLowerCase();

      _userNameController.text = formattedUsername;
    });

    _userNameController.addListener(() {
      if (_userNameController.text.isNotEmpty) {
        Future.delayed(Duration(seconds: 2), () {
          _verifyUserName();
        });
      } else {
        setState(() {
          showButton = false;
          inputVerified = null;
          verifyingUsername = false;
        });
      }
    });
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

        if (basicAccountInfo == false) {
          Navigator.pop(context);
        } else {
          basicAccountInfo = false;
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
              if (basicAccountInfo == false) {
                Navigator.pop(context);
              } else {
                basicAccountInfo = false;
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
                  SizedBox(height: 40),
                  // phoneNumberField(),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  !basicAccountInfo
                      ? Form(
                          key: _officialDetailFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Pick your account type',
                                style: TextStyle(color: darkGrey, fontSize: 14),
                              ),
                              SizedBox(height: 6),
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: dividerColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton2(
                                  isExpanded: true,
                                  value: accountType,
                                  underline: SizedBox.shrink(),
                                  items: ['Personal', 'Developer', 'Business']
                                      .map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      accountType = value!;
                                      accountTypeChosen = true;
                                      isPersonalAccount =
                                          accountType == 'Personal';
                                      clearAllFields();
                                      getSubscriptionList();
                                    });
                                  },
                                ),
                              ),
                              Visibility(
                                visible: accountTypeChosen,
                                child: accountType == 'Personal'
                                    ? personalAccountFields()
                                    : businessAccountFields(),
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: _registrationFormKey,
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
                              SizedBox(height: 40),
                              bvnField(),
                              SizedBox(height: 40),
                              registerBtn(),
                              SizedBox(height: 40),
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

  Widget personalAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        nickNameField(),
        SizedBox(height: 20),
        userNameField(),
        SizedBox(height: 10),
        Text('Username should not exceed 15 characters'),
        SizedBox(height: 20),
        passwordField(),
        SizedBox(height: 10),
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
        nextBtn(),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget businessAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        // ChooseYourPlanWidget(
        //     accountType: accountType,
        //     onChanged: (subscriptionModel) {
        //       subscriptionsId = subscriptionModel.id;
        //     }),
        chooseYourPlanWidget(),
        SizedBox(height: 20),
        Text(
          'Industry',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 6),
        industryDropdown(),
        SizedBox(height: 20),
        nickNameField(),
        SizedBox(height: 20),
        userNameField(),
        SizedBox(height: 10),
        Text('Username should not exceed 15 characters'),
        SizedBox(height: 20),
        passwordField(),
        SizedBox(height: 10),
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
        nextBtn(),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget industryDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton2(
        isExpanded: true,
        value: industryType,
        underline: SizedBox.shrink(),
        items: industryList.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            industryType = value!;
          });
        },
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
            "Slydo ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
          Text(
            "Registration",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
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
      labelText: isPersonalAccount ? "First name" : 'Business Owner First name',
      keyboardType: TextInputType.name,
      validator: fullNameValidator,
    );
  }

  Widget lastNameField() {
    return CustomizedTextFormField(
      controller: _lastNameController,
      labelColor: darkGrey,
      labelText: isPersonalAccount ? "Surname" : 'Business Owner Surname',
      keyboardType: TextInputType.name,
      validator: fullNameValidator,
    );
  }

  Widget bvnField() {
    return CustomizedTextFormField(
      controller: _bvnController,
      labelColor: darkGrey,
      labelText: "BVN (Optional)",
      keyboardType: TextInputType.name,
      validator: (value) {
        return null;
      },
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
      maxLength: 15,
      labelText: isPersonalAccount ? "Username" : 'Business Username',
      keyboardType: TextInputType.text,
      validator: userNameValidator,
      suffixIcon: getUsernameSuffixIcon(),
    );
  }

  Widget getUsernameSuffixIcon() {
    if (verifyingUsername) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularLoadingIndicator(),
      );
    } else if (inputVerified != null) {
      if (inputVerified! == true) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: navyBlue,
            child: Icon(Icons.check, size: 20, color: Colors.white),
          ),
        );
      }

      return Icon(Icons.cancel, color: Colors.red);
    } else {
      return SizedBox.shrink();
    }
  }

  Future _verifyUserName() async {
    bool verifiedInput = false;
    setState(() {
      verifyingUsername = true;
    });
    try {
      await UserAuth().fetchCustomerProfile(_userNameController.text);
      verifiedInput = true;
    } catch (e) {
      verifiedInput = false;
    }
    if (verifiedInput) {
      //If verifiedInput is true it means the profile(username) exists so inputVerified will be false, because we can't use that profile again.

      setState(() {
        verifyingUsername = false;
        inputVerified = false;
        showButton = false;
      });
    } else {
      setState(() {
        verifyingUsername = false;
        inputVerified = true;
        showButton = true;
      });
    }
  }

  String? userNameValidator(String username) {
    RegExp validCharacters = RegExp(r'^[a-zA-Z 0-9\.\+\-\_]*$');

    // RegExp(r'^[a-z0-9]([._-](?![._-])|[a-z0-9]){3,18}[a-z0-9]$');

    if (!validCharacters.hasMatch(username)) {
      return "Username is not valid";
    }

    return checkSlydoName(username);
  }

  Widget nickNameField() {
    return CustomizedTextFormField(
      controller: _businessOrNickNameController,
      labelColor: darkGrey,
      labelText: isPersonalAccount ? "Nick name (Optional)" : 'Business name',
      keyboardType: TextInputType.name,
      validator: isPersonalAccount
          ? nickNameValidator
          : (String value) {
              if (value.isEmpty) {
                return 'Business name cannot be empty';
              } else {
                return null;
              }
            },
    );
  }

  String? nickNameValidator(String nickName) {
    if (_businessOrNickNameController.text.trim() ==
        _userNameController.text.trim()) {
      return "Nickname and Username should not be same";
    }
    return checkSlydoName(nickName);
  }

  Widget passwordInstruction() {
    return Container(
      child: Text(
        "Use a 6 digit number",
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
        title: isPersonalAccount ? "Birthdate" : 'Business Owner Birthdate',
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

  bool showButton = false;

  Widget nextBtn() {
    return showButton
        ? CurvedButton(
            onPressed: triggerInfoChange,
            text: "Proceed",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : SizedBox.shrink();
  }

  void triggerInfoChange() {
    basicAccountInfo = !basicAccountInfo;
    if (mounted) setState(() {});
    // if (_officialDetailFormKey.currentState!.validate() && validateDOB()) {
    //   if (gender != null) {
    //     basicAccountInfo = !basicAccountInfo;
    //     if (mounted) setState(() {});
    //   } else {
    //     showToast(message: 'Pick a gender');
    //   }
    // }
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
    } else if (val != _passwordController.text) {
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
      title: isPersonalAccount ? "Gender" : 'Business Owner Gender',
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
      phoneNumber = _phoneNumberController.text.trim();
      password = _passwordController.text.trim();

      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      debugPrint("DOB:- ${dateFormat.format(dob)}");

      String selectedGender = "";
      if (gender == "Male") {
        selectedGender = "M";
      } else if (gender == "Female") {
        selectedGender = "F";
      }

      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();

      Map<String, dynamic> data = {
        "phone_number": _phoneNumberController.text.trim(),
        "firstname": firstName,
        "lastname": lastName,
        "full_name": "$firstName $lastName",
        "dob": dateFormat.format(dob),
        "gender": selectedGender,
        "username": _userNameController.text.trim(),
        "nickname": _businessOrNickNameController.text.trim(),
        "password1": _passwordController.text.trim(),
        "password2": _confirmPasswordController.text.trim(),
        "profile": {
          'id': subscriptionsId,
          "bvn": _bvnController.text,
          "account_type": accountType,
          'industry_type': industryType,
          "business_name": _businessOrNickNameController,
        },
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

  clearAllFields() {
    _bvnController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _businessOrNickNameController.clear();
    _userNameController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    industryType = null;
  }

  chooseYourPlanWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 10),
        chooseYourPlanDropdown(),
      ],
    );
  }

  Widget chooseYourPlanDropdown() {
    return IgnorePointer(
      ignoring: subscriptionsModelList == null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton2(
          isExpanded: true,
          value: subscriptionsModel,
          underline: SizedBox.shrink(),
          items: subscriptionsModelList == null
              ? [
                  DropdownMenuItem(
                    value: SubscriptionsModel(
                      accountType: '',
                      currency: '',
                      price: 0,
                      id: 0,
                      subscriptionType: '',
                    ),
                    child: Text(''),
                  )
                ]
              : subscriptionsModelList!.map((SubscriptionsModel item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Text(
                          worldCurrencies[item.currency]!,
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${moneyDisplayNormalizer(int.parse(item.price.toString()))} (${item.subscriptionType}) plan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff030F36),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          onChanged: (SubscriptionsModel? value) {
            setState(() {
              subscriptionsModel = value;
            });
            subscriptionsId = subscriptionsModel!.id;
          },
        ),
      ),
    );
  }

  SubscriptionsModel? subscriptionsModel;
  List<SubscriptionsModel>? subscriptionsModelList = [];
  getSubscriptionList() async {
    setState(() {
      subscriptionsModel = null;
      subscriptionsModelList = null;
    });
    if (accountType != null) {
      List<SubscriptionsModel> _subscriptionsModelList =
          await SubscriptionsAuth()
              .getSubscriptionList(accountType: accountType!);
      subscriptionsModelList = _subscriptionsModelList;

      setState(() {});
    }
  }
}

class ChooseYourPlanWidget extends StatefulWidget {
  final String? accountType;
  final Function(SubscriptionsModel) onChanged;
  const ChooseYourPlanWidget(
      {Key? key, required this.onChanged, required this.accountType})
      : super(key: key);

  @override
  _ChooseYourPlanWidgetState createState() => _ChooseYourPlanWidgetState();
}

class _ChooseYourPlanWidgetState extends State<ChooseYourPlanWidget> {
  String? planType;
  SubscriptionsModel? subscriptionsModel;
  List<SubscriptionsModel>? subscriptionsModelList = [];

  @override
  void initState() {
    getSubscriptionList();
    super.initState();
  }

  getSubscriptionList() async {
    if (widget.accountType != null) {
      List<SubscriptionsModel> _subscriptionsModelList =
          await SubscriptionsAuth()
              .getSubscriptionList(accountType: widget.accountType!);
      subscriptionsModelList = _subscriptionsModelList;

      debugPrint('LIST -> ${subscriptionsModelList}');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 10),
        chooseYourPlanDropdown(),
      ],
    );
  }

  Widget chooseYourPlanDropdown() {
    return IgnorePointer(
      ignoring: subscriptionsModelList == null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton2(
          isExpanded: true,
          value: subscriptionsModel,
          underline: SizedBox.shrink(),
          items: subscriptionsModelList!.map((SubscriptionsModel item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Text(
                    worldCurrencies[item.currency]!,
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${moneyDisplayNormalizer(int.parse(item.price.toString()))} (${item.subscriptionType}) plan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff030F36),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (SubscriptionsModel? value) {
            setState(() {
              subscriptionsModel = value;
            });
            widget.onChanged(value!);
          },
        ),
      ),
    );
  }
}

List<String> industryList = [
  'Manufacturing',
  'Technology',
  'Production',
  'Trade',
  'Finance',
  'Small business',
  'Marketing',
  'Science',
  'Research',
  'Food Industry',
  'Investment',
  'Agriculture',
  'Startup',
  'Law',
  'Communication',
  'Construction',
  'Entertainment',
  'Hospitality',
  'Media',
  'E-commerce',
  'Transport',
  'Cryptocurrency',
  'Bank',
  'Education',
  'Insurance',
  'Retail',
  'Mining',
  'Regulation',
  'Fashion',
];
