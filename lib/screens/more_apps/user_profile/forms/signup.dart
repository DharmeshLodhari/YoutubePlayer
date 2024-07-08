import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/currency.dart';
import '../../../../routes/route_constants.dart';
import '../../../../services/secure_storage.dart';
import '../screens/subscriptions/subscription_auth.dart';
import '../screens/subscriptions/subscription_model.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  final dynamic arguments;

  const SignUp({super.key, required this.arguments});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? accountType;
  int? subscriptionsId;
  String? industryType;
  bool showDOB = false;
  bool isPersonalAccount = false;
  bool accountTypeChosen = false;

  final _bankDetailsFormKey = GlobalKey<FormState>();
  final _personalDetailFormKey = GlobalKey<FormState>();

  String? phoneNumber = '';
  String password = '';
  String otpCode = '';

  late TextEditingController _bvnController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _businessOrNickNameController;
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _accountTypeController;
  late TextEditingController _referralCodeController;
  final _auth = AuthService();

  bool loading = false;

  DateTime dob = DateTime.now();
  String? gender;

  UserBloc? userBloc;

  List<String> genders = ["Male", "Female"];

  bool basicAccountInfo = false;

  bool? isValidAge;

  bool verifyingUsername = false;
  bool? inputVerified;

  bool verifyingReferralUsername = false;
  bool? referralInputVerified;

  RegExp dotReg = RegExp(r'\.$');
  RegExp spaceReg = RegExp(r' $');
  RegExp asteriskReg = RegExp(r'\*');
  RegExp multipleDotReg = RegExp(r'\.{2,}');

  int maxUsernameLength = 30;
  bool isUserAgree = false;
  List<ProductIndustryResults> industries = [];

  @override
  void initState() {
    getProductIndustries();
    phoneNumber = widget.arguments['phoneNumber'];
    otpCode = widget.arguments['otpCode'];
    accountType = widget.arguments['accountType'];

    debugPrint('Phone number -> $phoneNumber');
    debugPrint('accountType -> $accountType');
    debugPrint('otpCode -> $otpCode');

    _bvnController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _businessOrNickNameController = TextEditingController();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _accountTypeController = TextEditingController();
    _referralCodeController = TextEditingController();

    _accountTypeController.text = accountType ?? "";
    accountTypeChosen = true;
    isPersonalAccount = accountType == 'Personal';
    getSubscriptionList();

    _businessOrNickNameController.addListener(() {
      final String name = _businessOrNickNameController.text;

      if (!dotReg.hasMatch(name) &&
          !asteriskReg.hasMatch(name) &&
          !spaceReg.hasMatch(name) &&
          (_userNameController.text.length <= maxUsernameLength - 1 ||
              name.length <= maxUsernameLength - 1)) {
        final String formattedUsername = _businessOrNickNameController.text
            .replaceAll(' ', '.')
            .replaceAll(multipleDotReg, '.')
            .toLowerCase();

        if (formattedUsername.length <= maxUsernameLength) {
          _userNameController.text = formattedUsername;
        }
      }
    });

    _userNameController.addListener(() {
      if (_userNameController.text.toLowerCase().isNotEmpty) {
        debugPrint('USER NAME CTRL');
        Future.delayed(const Duration(seconds: 2), () {
          if (_userNameController.text.length >= 4) {
            _verifyUserName();
          }
        });
      } else {
        setState(() {
          showButton = false;
          inputVerified = false;
          verifyingUsername = false;
        });
      }
    });

    _referralCodeController.addListener(() {
      if (_referralCodeController.text.toLowerCase().isNotEmpty) {
        debugPrint('USER NAME CTRL');
        Future.delayed(const Duration(seconds: 2), () {
          if (_referralCodeController.text.length >= 4) {
            _verifyReferralUserName();
          }
        });
      } else {
        setState(() {
          referralInputVerified = false;
          verifyingReferralUsername = false;
        });
      }
    });
    super.initState();
  }

  void getProductIndustries() async {
    loading = true;
    if (mounted) setState(() {});
    final result = await _auth.listOfIndustries();
    if (result != null) {
      industries = result["product"];
      loading = false;
      if (mounted) setState(() {});
    } else {
      industries = [];
      loading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
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
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: _buildAppbar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
    );
  }

  Widget _buildBody() {
    return loading
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            ),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appIcon(),
                  const SizedBox(
                    height: 10,
                  ),
                  registerTitle(),
                  const SizedBox(height: 40),
                  if (!basicAccountInfo)
                    Form(
                      key: _personalDetailFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          accountTypeField(),
                          Visibility(
                            visible: accountTypeChosen,
                            child: accountType == 'Personal'
                                ? personalAccountFields()
                                : businessAccountFields(),
                          ),
                        ],
                      ),
                    )
                  else
                    Form(
                      key: _bankDetailsFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nameInstructionNote(),
                          const SizedBox(height: 20),
                          firstNameField(),
                          const SizedBox(height: 20),
                          lastNameField(),
                          const SizedBox(height: 20),
                          getDOBField(),
                          if (isValidAge != null && !isValidAge!)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  "You are not eligible to use Slydo",
                                  style:
                                      TextStyle(color: mateRed, fontSize: 13),
                                ),
                              ],
                            )
                          else
                            Container(),
                          const SizedBox(height: 20),
                          getGenderField(),
                          const SizedBox(height: 20),
                          registrationTermsAndCondition(),
                          // bvnField(),
                          const SizedBox(height: 40),
                          registerBtn(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget personalAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        nickNameField(),
        const SizedBox(height: 20),
        userNameField(),
        // Text(
        //   'username should not exceed 15 characters',
        //   style: TextStyle(
        //     fontSize: 12,
        //   ),
        // ),
        // Text(
        //   'username should not less than 4 characters',
        //   style: TextStyle(
        //     fontSize: 12,
        //   ),
        // ),
        // Text(
        //   'replace spaces with dots',
        //   style: TextStyle(
        //     fontSize: 12,
        //   ),
        // ),
        const SizedBox(height: 20),
        referralCodeField(),
        const SizedBox(height: 20),
        passwordField(),
        const SizedBox(height: 10),
        passwordInstruction(),
        const SizedBox(
          height: 20,
        ),
        confirmPasswordField(),
        const SizedBox(
          height: 40,
        ),
        nextBtn(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget businessAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // chooseYourPlanWidget(),
        // SizedBox(height: 20),
        Text(
          'Industry',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(height: 6),
        industryDropdown(),
        const SizedBox(height: 20),
        nickNameField(),
        const SizedBox(height: 20),
        userNameField(),
        const SizedBox(height: 10),
        const Text('Username should not exceed 15 characters'),
        const SizedBox(height: 20),
        referralCodeField(),
        const SizedBox(height: 20),
        passwordField(),
        const SizedBox(height: 10),
        passwordInstruction(),
        const SizedBox(height: 20),
        confirmPasswordField(),
        const SizedBox(
          height: 40,
        ),
        nextBtn(),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget industryDropdown() {
    return DropdownButtonFormField2(
      // buttonHeight: 50,
      isExpanded: true,
      value: industryType,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
      items: industries.map((ProductIndustryResults item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name!),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          industryType = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick an industry';
        }
      },
    );
  }

  Widget appIcon() {
    return Image.asset(
      "assets/images/app_logo_navyBlue.png",
      height: MediaQuery.of(context).size.height / 16,
      frameBuilder: imageFrameBuilder,
    );
  }

  Widget registerTitle() {
    return Row(
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
    );
  }

  Widget nameInstructionNote() {
    return Text(
      "Please ensure the information below matches that which is on your government issued ID",
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
    );
  }

  Widget accountTypeField() {
    return CustomizedTextFormField(
      controller: _accountTypeController,
      labelColor: darkGrey,
      labelText: 'Account type',
      keyboardType: TextInputType.name,
      enabled: false,
    );
  }

  Widget firstNameField() {
    return CustomizedTextFormField(
      controller: _firstNameController,
      labelColor: darkGrey,
      labelText:
          isPersonalAccount ? "First name" : 'Business Owner\'s First name',
      keyboardType: TextInputType.name,
      validator: fullNameValidator,
    );
  }

  Widget lastNameField() {
    return CustomizedTextFormField(
      controller: _lastNameController,
      labelColor: darkGrey,
      labelText: isPersonalAccount ? "Surname" : 'Business Owner\'s Surname',
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
    final List<String> nameList = enteredName.trim().split(" ");

    /// For not allowing user to put any profession title
    final List<String> notValidProfessionTitles = [
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

    final RegExp regExp = RegExp(r"^[A-Za-z\s]{1,}[A-Za-z\s-]{0,}$");

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
      maxLength: maxUsernameLength,
      labelText: isPersonalAccount ? "Username" : 'Business Username',
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r"\s")),
      ],
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
            child: const Icon(Icons.check, size: 20, color: Colors.white),
          ),
        );
      }

      return const Icon(Icons.cancel, color: Colors.red);
    } else {
      return const SizedBox.shrink();
    }
  }

  Future _verifyUserName() async {
    bool verifiedInput = false;
    setState(() {
      verifyingUsername = true;
    });
    try {
      await UserAuth()
          .fetchCustomerProfile(_userNameController.text.trim().toLowerCase());
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
      showToast(message: 'Username not available');
    } else {
      setState(() {
        verifyingUsername = false;
        inputVerified = true;
        showButton = true;
      });
    }
  }

  Future _verifyReferralUserName() async {
    bool verifiedInput = false;
    setState(() {
      verifyingReferralUsername = true;
    });
    try {
      await UserAuth().fetchCustomerProfile(
          _referralCodeController.text.trim().toLowerCase());
      verifiedInput = true;
    } catch (e) {
      verifiedInput = false;
    }
    if (verifiedInput) {
      //If verifiedInput is true it means the profile(username) exists so inputVerified will be false, because we can't use that profile again.

      setState(() {
        referralInputVerified = true;
        verifyingReferralUsername = false;
      });
      showToast(message: 'Username is available');
    } else {
      setState(() {
        verifyingReferralUsername = false;
        referralInputVerified = false;
      });
    }
  }

  String? userNameValidator(String username) {
    final RegExp validCharacters = RegExp(r'^[a-zA-Z 0-9\.\+\-\_]*$');

    // RegExp(r'^[a-z0-9]([._-](?![._-])|[a-z0-9]){3,18}[a-z0-9]$');

    if (!validCharacters.hasMatch(username)) {
      return "Username is not valid";
    }
    if (dotReg.hasMatch(username)) {
      return 'Username cannot end with a period (.)';
    }
    if (asteriskReg.hasMatch(username)) {
      return 'Username cannot contain an asterisk (*)';
    }
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 4) {
      return 'Username cannot be less than 4 characters';
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

  Widget referralCodeField() {
    return CustomizedTextFormField(
      controller: _referralCodeController,
      labelColor: darkGrey,
      labelText: 'Referral Code (Optional)',
      validator: (String val) {
        if (val.isNotEmpty && !referralInputVerified!) {
          return "Invalid referral";
        }
      },
      suffixIcon: getReferralUsernameSuffixIcon(),
    );
  }

  Widget getReferralUsernameSuffixIcon() {
    if (verifyingReferralUsername) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularLoadingIndicator(),
      );
    } else if (referralInputVerified != null) {
      if (referralInputVerified! == true) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: navyBlue,
            child: const Icon(Icons.check, size: 20, color: Colors.white),
          ),
        );
      } else {
        return const Icon(Icons.cancel, color: Colors.red);
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  String? nickNameValidator(String nickName) {
    return checkSlydoName(nickName);
  }

  Widget passwordInstruction() {
    return Text(
      "Use a 6 digit number",
      style: TextStyle(
          fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
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
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime(dob.year, dob.month, dob.day),
          firstDate: DateTime(1920, 0, 1),
          lastDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ).then((value) {
          dob = DateTime(value!.year, value.month, value.day);
          showDOB = true;
          setState(() {});
          validateDOB();
        }).catchError((error) {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomizedDropDownField(
            title:
                isPersonalAccount ? "Birthdate" : 'Business Owner\'s Birthdate',
            child: ListTile(
              dense: true,
              title: Text(
                /*This is so that when the user
                   * comes to this page before picking a date, the field will be empty*/
                showDOB == true ? formatDate(dob) : '',
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
                maxLines: 1,
              ),
              trailing: Icon(
                SlydoAppIcon.date,
                size: 16,
                color: darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('You must be 12 years or older'),
        ],
      ),
    );
  }

  Widget registrationTermsAndCondition() {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.transparent,
                  ),
                  child: Checkbox(
                    value: isUserAgree,
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onChanged: (value) {
                      // if (mounted) {
                      //   setState(() {
                      //     isUserAgree = value;
                      //   });
                      // }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By checking the box, you are agreeing to our ',
                    style: TextStyle(fontSize: 14, color: blackFont),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions, ',
                    style: TextStyle(
                        fontSize: 14,
                        color: navyBlue,
                        fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('http://https://slydo.co/termsandconditions');
                      },
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        fontSize: 14,
                        color: navyBlue,
                        fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('http://https://slydo.co/privacypolicy');
                      },
                  ),
                  TextSpan(
                    text: ' which includes our ',
                    style: TextStyle(fontSize: 14, color: blackFont),
                  ),
                  TextSpan(
                    text: 'EULA terms.',
                    style: TextStyle(
                        fontSize: 14,
                        color: navyBlue,
                        fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('http://https://slydo.co/termsandconditions');
                      },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      onTap: () {
        if (mounted) {
          isUserAgree = !isUserAgree;
          setState(() {});
        }
      },
    );
  }

  Widget registerBtn() {
    return isUserAgree == true
        ? CurvedButton(
            onPressed: registerUser,
            text: "Register",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : const SizedBox.shrink();
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
        : const SizedBox.shrink();
  }

  void triggerInfoChange() {
    if (_personalDetailFormKey.currentState!.validate()) {
      basicAccountInfo = !basicAccountInfo;
      if (mounted) setState(() {});
    }
  }

  bool validateDOB() {
    final DateTime dateTime = DateTime.now();

    // Validating for 12 years and above
    if (dob.add(const Duration(days: 4380)).isBefore(dateTime)) {
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
    final matcher = RegExp(
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
    final matcher = RegExp(
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
      title: isPersonalAccount ? "Gender" : 'Business Owner\'s Gender',
      child: ListTile(
        dense: true,
        title: Text(
          gender != null ? gender! : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
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
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
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

    if (gender == null) {
      showToast(message: 'Please pick a gender');
      return;
    }

    if (_bankDetailsFormKey.currentState!.validate()) {
      password = _passwordController.text.trim();

      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      debugPrint("DOB:- ${dateFormat.format(dob)}");

      String selectedGender = "";
      if (gender == "Male") {
        selectedGender = "M";
      } else if (gender == "Female") {
        selectedGender = "F";
      }

      final String firstName = _firstNameController.text.toTitleCase().trim();
      final String lastName = _lastNameController.text.toTitleCase().trim();
      final String referralCode =
          _referralCodeController.text.toLowerCase().trim();
      final String userName = _userNameController.text
          .toLowerCase()
          // .replaceAll(' ', '.')
          // .replaceAll(multipleDotReg, '.')
          // .toLowerCase()
          .trim();
      final String businessOrNickName =
          _businessOrNickNameController.text.toTitleCase().trim();

      final Map<String, dynamic> data = {
        "phone_number": phoneNumber,
        "firstname": firstName,
        "lastname": lastName,
        "full_name": "$firstName $lastName",
        "referral_code": referralCode,
        "dob": dateFormat.format(dob),
        "gender": selectedGender,
        "username": userName,
        "bvn": _bvnController.text,
        "nickname": businessOrNickName,
        "password1": _passwordController.text.trim(),
        "password2": _confirmPasswordController.text.trim(),
        "otp_code": otpCode,
      };

      if (accountType != 'Personal') {
        data['profile'] = {
          'id': 1,
          'industry': industryType,
          "account_type": accountType,
          "business_name": businessOrNickName,
        };
      }
      if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");

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
      final msg = AppLocalization.of(context)!.invalidDetails;
      showToast(message: msg);
    }
  }

  void clearAllFields() {
    _bvnController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _businessOrNickNameController.clear();
    _userNameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _referralCodeController.clear();

    industryType = null;
  }

  Widget chooseYourPlanWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(height: 10),
        chooseYourPlanDropdown(),
      ],
    );
  }

  Widget chooseYourPlanDropdown() {
    return IgnorePointer(
      ignoring: subscriptionsModelList == null,
      child: DropdownButtonFormField2(
        // buttonHeight: 50,
        isExpanded: true,
        dropdownStyleData: const DropdownStyleData(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
        value: subscriptionsModel,
        style: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
        ),
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
                  child: const Text(''),
                )
              ]
            : subscriptionsModelList!.map((SubscriptionsModel item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Text(
                        '(FREE) ',
                        style: TextStyle(
                          color: navyBlue,
                        ),
                      ),
                      Text(
                        worldCurrencies[item.currency]!,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '${moneyDisplayNormalizer(int.parse(item.price.toString()))} (${item.subscriptionType}) plan',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
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
        validator: (SubscriptionsModel? value) {
          if (value != null && value.subscriptionType.isNotEmpty) {
            return null;
          } else {
            return 'Choose a plan';
          }
        },
      ),
    );
  }

  SubscriptionsModel? subscriptionsModel;
  List<SubscriptionsModel>? subscriptionsModelList = [];
  void getSubscriptionList() async {
    setState(() {
      subscriptionsModel = null;
      subscriptionsModelList = null;
    });
    if (accountType != null) {
      final List<SubscriptionsModel> _subscriptionsModelList =
          await SubscriptionsAuth()
              .getSubscriptionList(accountType: accountType ?? "");
      subscriptionsModelList = _subscriptionsModelList;

      setState(() {});
    }
  }
}
