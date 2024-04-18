import 'dart:async';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/company_name.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../routes/route_constants.dart';
import '../../yarn/yarn_auth.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool isRemember = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _yarnAuth = YarnAuth();
  String phoneNumber = '';
  String? password = '';

  //for remember user
  bool isChecked = false;
  bool isUserAgree = false;
  String? countryFromPref;
  String? phoneNumberFromPref;
  String? passwordFromPref;
  String? companyFromPref;
  TextEditingController? phoneNumberController;
  TextEditingController? passwordController;
  TextEditingController? companyController;
  FocusNode? companyFocusNode;
  late SharedPreferences _sharedPreferences;
  late BasketBloc basketBloc;
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;

  final FocusNode _pinPutFocusNode = FocusNode();

  late Country _selectedDialogCountry;
  int currentIndex = 0;

  List<CompanyName> companyList = [];
  // String businessName = "";
  String companyName = "";
  List<String> _dropdownItems = [];

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
    getSharedPreference();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
    companyController = TextEditingController();

    // searchCompanyName("");
    super.initState();
  }

  Future<void> getSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    isChecked = _sharedPreferences.getBool('isChecked') ?? false;

    isRemember = isChecked;

    if (isChecked) {
      countryFromPref = _sharedPreferences.getString('country');

      _selectedDialogCountry =
          CountryPickerUtils.getCountryByIsoCode(countryFromPref);

      SecureUser secureUser = await SecureStorage().getUser();
      phoneNumberFromPref = secureUser.phoneNumber;
      passwordFromPref = secureUser.password;
      companyFromPref = secureUser.company;

      //setting fetched userdata into screen
      if (phoneNumberFromPref != null) {
        phoneNumberController?.text = phoneNumberFromPref!;
      }
      if (passwordFromPref != null) {
        passwordController?.text = passwordFromPref!;
      }
      if (companyFromPref != null) {
        companyName = companyFromPref!;
      }

      if (phoneNumberFromPref != null) {
        phoneNumber =
            "+" + _selectedDialogCountry.phoneCode! + phoneNumberFromPref!;
      }

      password = passwordFromPref;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: whiteBackground,
        appBar: _buildAppbar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              appIcon(),
              SizedBox(height: 10),
              loginTitle(),
              SizedBox(height: 30),
              _buildTabs(),
              SizedBox(height: 30),
              _buildPageView(),
              SizedBox(height: 30),
              loginBtn(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget appIcon() {
    return Container(
      child: Image.asset(
        "assets/images/app_logo_navyBlue.png",
        height: MediaQuery.of(context).size.height / 22,
        frameBuilder: imageFrameBuilder,
      ),
    );
  }

  Widget loginTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            currentIndex == 0 ? "Log in to Slydo" : 'Staff Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
            color: greyBackground, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: buildTabItem(
                onTap: (int index) {
                  currentIndex = index;
                  _dropdownItems.clear();
                  companyController?.clear();
                  setState(() {});
                },
                tabIndex: 0,
                title: 'User',
                currentIndex: currentIndex,
              ),
            ),
            Expanded(
              child: buildTabItem(
                onTap: (int index) {
                  currentIndex = index;
                  setState(() {});
                },
                tabIndex: 1,
                title: 'Staff Admin',
                currentIndex: currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return IndexedStack(
      index: currentIndex,
      children: [userLogin(), staffLogin()],
    );
  }

  Widget userLogin() {
    return Column(
      children: [
        phoneNumberField(),
        SizedBox(height: 20),
        passwordPinFiled(),
        SizedBox(height: 20),
        rememberMeAndForgotPasswordField(),
      ],
    );
  }

  Widget staffLogin() {
    return Column(
      children: [
        companyNameField(),
        SizedBox(height: 20),
        phoneNumberField(),
        SizedBox(height: 20),
        passwordPinFiled(),
        SizedBox(height: 20),
        rememberMeAndForgotPasswordField(),
      ],
    );
  }

  Widget companyNameField() {
    return Column(
      children: [
        CustomizedTextFormField(
          labelText: 'Company Name',
          labelColor: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          keyboardType: TextInputType.text,
          hintText: "Enter company username",
          controller: companyController,
          focusNode: companyFocusNode,
          onChanged: (String val) {
            if (val != null && val.length >= 3) {
              searchCompanyName(val);
            } else {
              setState(() {
                _dropdownItems.clear();
              });
            }
          },
          validator: (val) {
            if (currentIndex == 1) {
              if (val.isNotEmpty) {
                return null;
              }
              return AppLocalization.of(context)!.invalidCompanyName;
            }
          },
        ),
        if (_dropdownItems.isNotEmpty)
          Card(
            elevation: 4,
            child: Container(
              color: white,
              constraints: const BoxConstraints(
                maxHeight: 100,
              ),
              child: RawScrollbar(
                controller: scrollController,
                thumbVisibility: true,
                thickness: 5,
                trackVisibility: true,
                thumbColor: navyBlue,
                radius: Radius.circular(15),
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    controller: scrollController,
                    children: _dropdownItems.map((String value) {
                      return Container(
                        color: white,
                        child: ListTile(
                          dense: true,
                          title: Text(value),
                          onTap: () {
                            companyController?.text = value;
                            companyName = value;
                            _dropdownItems.clear();
                            setState(() {});
                            companyFocusNode?.unfocus();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget dropdownCountrySearch() {
    return Container(
      height: 50,
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              cursorColor: navyBlue,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: navyBlue,
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
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
              ),
            )),
        items: companyList.map((CompanyName item) {
          return item.businessName ?? "";
        }).toList(),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            isDense: true,
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
          baseStyle: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
        ),
        onChanged: (String? value) async {
          setState(() {
            // businessName = companyList
            //         ?.firstWhere((element) => element.businessName == value)
            //         .businessName ??
            // "";
            companyName = companyList
                    .firstWhere((element) => element.businessName == value)
                    .username ??
                "";
            // companyName = value!;
          });
        },
        validator: (String? value) {
          if (currentIndex == 1) {
            if (value != null && value.isNotEmpty) {
              return null;
            } else {
              return 'Pick a company name';
            }
          } else {
            return null;
          }
        },
        selectedItem: companyName,
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
            hintText: "08023000000",
            controller: phoneNumberController,
            validator: (val) {
              if (val.isNotEmpty && val.length >= 9) {
                return null;
              }
              return AppLocalization.of(context)!.invalidPhoneNumber;
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
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
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
            onTap: () {
              _openCountryPickerDialog(isForLogin: true);
            },
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
        Expanded(
          child: Text(
            "(" + country.name! + ")",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  void _openCountryPickerDialog({bool isForLogin = false}) => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: navyBlue),
          child: CountryPickerDialog(
            isForLogin: isForLogin,
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: navyBlue,
            searchInputDecoration: InputDecoration(
              hintText: AppLocalization.of(context)!.search,
              hintStyle: TextStyle(
                fontSize: 16,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            isSearchable: true,
            title: Text(
              AppLocalization.of(context)!.selectYourPhoneCode,
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
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            ),
          ),
          SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val!.length < 4
                ? AppLocalization.of(context)!.invalidPassword
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          //   rememberMeField(),
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
            AppLocalization.of(context)!.rememberMe,
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
          AppLocalization.of(context)!.forgotPassword,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: navyBlue,
            fontFamily: "Inter",
          ),
        ),
      ),
    );
  }

  Widget loginBtn() {
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
    final YarnDashboardBloc yarnSettingsBloc =
        Provider.of<YarnDashboardBloc>(context, listen: false);

    FocusScope.of(context).unfocus();

    if (_loginFormKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      var _user;
      BankAccount? _bankAccount;

      var phoneNumberFromTextField = phoneNumberController!.text.trim();

      if (phoneNumberFromTextField.substring(0, 1) == "0") {
        phoneNumberFromTextField =
            phoneNumberFromTextField.replaceFirst("0", "");
      }

      phoneNumber =
          "+" + _selectedDialogCountry.phoneCode! + phoneNumberFromTextField;
      password = passwordController!.text.trim();
      bool isStaffLogin;
      if (currentIndex == 1) {
        isStaffLogin = true;
      } else {
        isStaffLogin = false;
      }
      await _auth
          .authenticate(phoneNumber, password,
              isStaffLogin: isStaffLogin, company: companyName)
          .then((value) async {
        _user = value;
        if (_user.fullName != null) {
          //method call for storing user info into shared preference
          isRememberChecked();

          /// storeUser data in to the secure storage
          storeUserData(isStaffLogin);

          userBloc.user = _user;

          DatabaseHelper()
              .saveGeneralSettings(userBloc.chatMessageSettings.toDBJson());

          try {
            socketProvider.setCurrentUser(_user);
          } catch (error) {
            debugPrint("ERROR:- $error");
          }

          // Get user's bank account if user is logged in
          if (_user != null) {
            await PaymentAndBankingAuth().getBankAccounts().then((accounts) {
              if (accounts.isNotEmpty) {
                _bankAccount = accounts[0];
              }

              if (_bankAccount != null) {
                bankAccountBloc.bankAccount = _bankAccount;
              }
            });
          }

          initializeShoppingCart();
          await clearDBMessages();

          BackgroundFetchStopBloc backgroundFetchBloc =
              Provider.of<BackgroundFetchStopBloc>(
                  myGlobals.navigationKey.currentContext!,
                  listen: false);

          backgroundFetchBloc.isAllowed = true;

          //  startWorkManager();

          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.DASHBOARD,
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pop(context);
          showToast(message: AppLocalization.of(context)!.userIsNotRegistered);
        }
      }).catchError((error) {
        if (mounted) {
          Navigator.pop(context);
          showToast(message: "$error");
        }
      });
      await _yarnAuth.getUserYarnSettings().then((value) async {
        if (value != null) yarnSettingsBloc.yarnSettings = value;
      });

      print(
          'printing yarn settings id ............ ${yarnSettingsBloc.yarnSettings.allowAdultContent.toString()}');
      print(
          'printing yarn settings id 1 ............ ${yarnSettingsBloc.yarnSettings.allowSensitiveContent.toString()}');
      print(
          'printing yarn settings id ............ ${yarnSettingsBloc.yarnSettings.id.toString()}');
    }
  }

  void startWorkManager() {
    // Workmanager().registerPeriodicTask(
    //   "2",
    //   "simplePeriodicTask",
    //   // When no frequency is provided the default 15 minutes is set.
    //   // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    //   frequency: Duration(minutes: 5),
    // );
  }

  void isRememberChecked() async {
    // await _sharedPreferences.clear();
    bool isLoggedOut = await _sharedPreferences.setBool('isLoggedOut', false);

    bool isCheckedSet = await _sharedPreferences.setBool('isChecked', true);

    bool countryCodeSet = await _sharedPreferences.setString(
        'country', _selectedDialogCountry.isoCode!);

    if (!isCheckedSet || !isLoggedOut || !countryCodeSet) {
      showToast(message: AppLocalization.of(context)!.userIsNotSaved);
    }
  }

  void storeUserData(bool isStaffLogin) async {
    await SecureStorage().clear();

    var phoneNumberFromTextField = phoneNumberController!.text.trim();

    if (phoneNumberFromTextField.substring(0, 1) == "0") {
      phoneNumberFromTextField = phoneNumberFromTextField.replaceFirst("0", "");
    }

    SecureUser secureUser = SecureUser(
      phoneNumber: phoneNumberFromTextField,
      password: password,
      company: companyName,
      isStaffLogin: isStaffLogin,
    );
    await SecureStorage().storeUser(user: secureUser);
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    List items = await ShoppingAuthService().getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(
          item: element,
          type: type,
          currentUser: userBloc.user.convertToUser(),
          withApiCall: false);
    });
    await sharedCartBloc.refreshAllCart(context);
  }

  Future<void> searchCompanyName(String query) async {
    try {
      if (mounted) setState(() {});
      companyList = await ShoppingAuthService().listOfCompanyName(query) ?? [];

      // Clear the existing dropdown items
      _dropdownItems.clear();

      // Extract usernames and add them to the dropdown items

      if (mounted)
        setState(() {
          for (var company in companyList) {
            if (company.username != null) {
              _dropdownItems.add(company.username!);
            }
          }
        });
    } catch (error) {
      debugPrint('Error fetching data: $error');
      if (mounted) setState(() {});
    }
  }

  Widget buildTabItem({
    required int tabIndex,
    required String title,
    required Function(int) onTap,
    int? currentIndex,
  }) {
    return InkWell(
      onTap: () => onTap(tabIndex),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          shape: BoxShape.rectangle,
          color: currentIndex == tabIndex ? navyBlue : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: currentIndex == tabIndex ? white : yarnBlack,
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight:
                  currentIndex == tabIndex ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> clearDBMessages() async {
    await ChatMessageHandler().deleteChatMessages();
    await ChatUserManager().clearChatUsers();
    await ConnectionListManager().clearConnections();
    await DBSocketMessageHandler().clearSocketQueueChatMessage();
    await DatabaseHelper().deleteVirtualAccount();
  }

  @override
  void dispose() {
    phoneNumberController!.dispose();
    passwordController!.dispose();
    super.dispose();
  }
}
