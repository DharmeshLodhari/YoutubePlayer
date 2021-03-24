import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool isRemember = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _auth = AuthService();
  String phoneNumber = '';
  String password = '';

  //for remember user
  bool isChecked = false;
  String countryFromPref;
  String phoneNumberFromPref;
  String passwordFromPref;
  TextEditingController phoneNumberController;
  TextEditingController passwordController;
  SharedPreferences _sharedPreferences;
  BasketBloc basketBloc;

  final FocusNode _pinPutFocusNode = FocusNode();

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  @override
  void initState() {
    getSharedPreference();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  Future<void> getSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (_sharedPreferences != null) {
      if (mounted) {
        setState(() {
          isChecked = _sharedPreferences.getBool('isChecked') ?? false;
        });
      }
      isRemember = isChecked;

      if (isChecked) {
        countryFromPref = _sharedPreferences.getString('country') ?? "NG";
        _selectedDialogCountry =
            CountryPickerUtils.getCountryByIsoCode(countryFromPref);

        SecureUser secureUser = await SecureStorage().getUser();
        phoneNumberFromPref = secureUser.phoneNumber ?? "";
        passwordFromPref = secureUser.password ?? "";

        //setting fetched userdata into screen
        phoneNumberController.text = phoneNumberFromPref;
        passwordController.text = passwordFromPref;
        phoneNumber =
            "+" + _selectedDialogCountry.phoneCode + phoneNumberFromPref;
        password = passwordFromPref;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: whiteBackground,
        appBar: AppBar(
          backgroundColor: whiteBackground,
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
                  flex: 7,
                  child: Form(
                    key: _loginFormKey,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appIcon(),
                          flexibleSpace(flex: 1),
                          loginTitle(),
                          flexibleSpace(flex: 4),
                          phoneNumberField(),
                          flexibleSpace(flex: 1),
                          passwordPinFiled(),
                          flexibleSpace(flex: 1),
                          rememberMeAndForgotPasswordField(),
                          flexibleSpace(flex: 4),
                          loginBtnField(),
                          flexibleSpace(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                flexibleSpace(flex: 3),
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

  Widget loginTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Log in to ",
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: getCountryDropdown()),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 5,
          child: CustomizedTextFormField(
            labelColor: darkGrey,
            keyboardType: TextInputType.phone,
            controller: phoneNumberController,
            validator: (val) {
              if (val.isNotEmpty && val.length >= 9) {
                return null;
              }
              return AppLocalization.of(context).invalidPhoneNumber;
            },
          ),
        ),
      ],
    );
  }

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Phone number",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          color: whiteBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            onTap: _openCountryPickerDialog,
            title: _buildDialogItem(_selectedDialogCountry),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        SizedBox(width: 4.0),
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            "+${country.phoneCode}",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          color: blackFont,
        ),
        SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildDialogItemWithName(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          "(" + country.name + ")",
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: navyBlue),
          child: CountryPickerDialog(
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: navyBlue,
            searchInputDecoration: InputDecoration(
              hintText: AppLocalization.of(context).search,
              hintStyle: TextStyle(
                fontSize: 16,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            isSearchable: true,
            title: Text(
              AppLocalization.of(context).selectYourPhoneCode,
              style: TextStyle(
                fontSize: 14,
                color: blackFont,
                fontWeight: FontWeight.w400,
              ),
            ),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _buildDialogItemWithName,
          ),
        ),
      );

  Widget passwordPinFiled() {
    BoxDecoration pinPutDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyBorderColor));
    BoxDecoration selectedDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: navyBlue));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(fontSize: 14, color: darkGrey),
          ),
          SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val.length < 4
                ? AppLocalization.of(context).invalidPassword
                : null,
            fieldsCount: 6,
            focusNode: _pinPutFocusNode,
            controller: passwordController,
            submittedFieldDecoration: pinPutDecoration,
            selectedFieldDecoration: selectedDecoration,
            followingFieldDecoration: pinPutDecoration,
            pinAnimationType: PinAnimationType.scale,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            textStyle: TextStyle(color: blackFont, fontSize: 35),
          ),
        ],
      ),
    );
  }

  Widget rememberMeAndForgotPasswordField() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          rememberMeField(),
          forgotPasswordField(),
        ],
      ),
    );
  }

  Widget rememberMeField() {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: new BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: new BorderRadius.circular(5),
                ),
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.transparent,
                  ),
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      if (mounted) {
                        if (isChecked) {
                          isChecked = false;
                          isRemember = false;
                        } else {
                          isChecked = true;
                          isRemember = true;
                        }
                        setState(() {});
                      }
                    },
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            AppLocalization.of(context).rememberMe,
            style: TextStyle(color: blackFont, fontSize: 14),
          ),
        ],
      ),
      onTap: () {
        if (mounted) {
          if (isChecked) {
            isChecked = false;
            isRemember = false;
          } else {
            isChecked = true;
            isRemember = true;
          }
          setState(() {});
        }
      },
    );
  }

  Widget forgotPasswordField() {
    return Container(
        child: GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/forgot-password');
      },
      child: Text(
        AppLocalization.of(context).forgotPassword,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
      ),
    ));
  }

  Widget loginBtnField() {
    return CurvedButton(
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Log in",
      onPressed: login,
    );
  }

  void login() async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final MainSocketProvider socketProvider =
        Provider.of<MainSocketProvider>(context, listen: false);
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);

    if (_loginFormKey.currentState.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      var _user;
      BankAccount _bankAccount;

      var phoneNumberFromTextField = phoneNumberController.text.trim();

      if (phoneNumberFromTextField.substring(0, 1) == "0") {
        phoneNumberFromTextField =
            phoneNumberFromTextField.replaceFirst("0", "");
      }

      phoneNumber =
          "+" + _selectedDialogCountry.phoneCode + phoneNumberFromTextField;
      password = passwordController.text.trim();

      _auth.authenticate(phoneNumber, password).then((value) async {
        _user = value;
        if (_user.fullName != null) {
          //method call for storing user info into shared preference
          isRememberChecked();

          /// storeUser data in to the secure storage
          storeUserData();

          userBloc.user = _user;

          socketProvider.currentUser = _user;

          // Get user's bank account if user is logged in
          if (_user != null) {
            PaymentAndBankingAuth().getBankAccounts().then((accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            });
          }

          initializeShoppingCart();
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/dashboard",
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pop(context);
          Toast.show(AppLocalization.of(context).userIsNotRegistered, context,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white);
        }
      }).catchError((error) {
        Navigator.pop(context);
        Toast.show("$error", context,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      });
    }
  }

  void isRememberChecked() async {
    bool isLoggedOut = await _sharedPreferences.setBool('isLoggedOut', false);
    if (isRemember) {
      await _sharedPreferences.clear();
      bool isCheckedSet =
          await _sharedPreferences.setBool('isChecked', isChecked);

      bool countryCodeSet = await _sharedPreferences.setString(
          'country', _selectedDialogCountry.isoCode);

      if (!isCheckedSet || !isLoggedOut || !countryCodeSet) {
        Toast.show(AppLocalization.of(context).userIsNotSaved, context);
      }
    } else {
      bool isSuccessFullyStored =
          await _sharedPreferences.setBool('isChecked', isChecked);
      if (!isSuccessFullyStored) {
        Toast.show(AppLocalization.of(context).userIsNotSaved, context);
      }
    }
  }

  void storeUserData() async {
    await SecureStorage().clear();

    var phoneNumberFromTextField = phoneNumberController.text.trim();

    if (phoneNumberFromTextField.substring(0, 1) == "0") {
      phoneNumberFromTextField = phoneNumberFromTextField.replaceFirst("0", "");
    }

    SecureUser secureUser =
        SecureUser(phoneNumber: phoneNumberFromTextField, password: password);
    await SecureStorage().storeUser(user: secureUser);
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    List items = await ShoppingAuthService().getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(item: element, type: type);
    });
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
