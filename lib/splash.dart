import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'data/socket_provider.dart';
import 'data/state_notifier.dart';
import 'locale/app_localization.dart';
import 'screens/more_apps/user_profile/models/device.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isChecked = false;
  bool isLoggedOut = false;
  String countryFromPref;
  String userPhoneNumber;
  String userPassword;
  SharedPreferences _sharedPreferences;
  BasketBloc basketBloc;

  // bool for to check if internet connection is available or not
  var hasConnection = true;

  Widget splashLogo = Scaffold(
      body: Container(
    height: double.infinity,
    width: double.infinity,
    color: navyBlue,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/app_logo.png",
          color: Colors.white,
          fit: BoxFit.fill,
          height: 75,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          "Slydo",
          style: TextStyle(
              fontFamily: "CircularStd",
              fontSize: 52,
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
      ],
    ),
  ));

  @override
  void initState() {
    checkConnection();
    initPlatformState();
    super.initState();
  }

  void checkConnection() {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        if (mounted) {
          setState(() {
            hasConnection = true;
          });
        }

        getLoggedInUser();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        if (mounted) {
          setState(() {
            hasConnection = false;
          });
        }
      }
    });
  }

  Future<void> initPlatformState() async {
    List languagesList;
    String currentLocale;

    //checking if the language data is stored in system or not
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      String languageCode = sharedPreferences.getString("language");
      AppLocalization.load(Locale(languageCode, ""));
      debugPrint("Language Set From SharedPreference => $languageCode ");
      return;
    }

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      languagesList = await Devicelocale.preferredLanguages;
      debugPrint("Device preferred languages => $languagesList");
    } on PlatformException {
      debugPrint("Error obtaining preferred languages");
    }
    try {
      currentLocale = await Devicelocale.currentLocale;
      debugPrint("Device current language => $currentLocale");
      Language language;
      languages.forEach((lang) {
        if (lang.languageCode == currentLocale.substring(0, 2)) {
          language = lang;
          return;
        }
      });

      AppLocalization.load(Locale(language.languageCode, ""));
      debugPrint("Language Set From System ${language.name}");

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      if (sharedPreferences.containsKey("language")) {
        bool result = await sharedPreferences.setString(
            "language", language.languageCode);
        debugPrint("Language is updated in sharedPreference => $result");
      } else {
        bool result = await sharedPreferences.setString(
            "language", language.languageCode);
        debugPrint("Language is set in sharedPreference => $result");
      }
    } on PlatformException {
      debugPrint("Error obtaining current locale");
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/app_logo.png"), context);
    basketBloc = Provider.of<BasketBloc>(context);
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: hasConnection
          ? splashLogo
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  'Slydo',
                  style: TextStyle(color: navyBlue),
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                automaticallyImplyLeading: false,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: NoItemInList(
                      msg: AppLocalization.of(context)
                          .internetConnectionNotAvailable,
                    ),
                  ),
                  MaterialButton(
                    color: navyBlue,
                    child: Text(
                      AppLocalization.of(context).retry,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: checkConnection,
                  )
                ],
              ),
            ),
    );
  }

  Future<void> getLoggedInUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    _sharedPreferences = await SharedPreferences.getInstance();
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final MainSocketProvider socketProvider =
        Provider.of<MainSocketProvider>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    if (_sharedPreferences != null) {
      isChecked = _sharedPreferences.getBool('isChecked') ?? false;
      isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
      if (isLoggedOut) {
        debugPrint("IsLoggedOyut:- $isLoggedOut");
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/index");
      } else {
        countryFromPref = _sharedPreferences.getString('country') ?? "NG";
        Country country =
            CountryPickerUtils.getCountryByIsoCode(countryFromPref);

        SecureUser secureUser = await SecureStorage().getUser();
        userPhoneNumber = secureUser.phoneNumber ?? "";
        userPassword = secureUser.password ?? "";

        await _sharedPreferences.setBool('isLoggedOut', isLoggedOut);
        await _sharedPreferences.setBool('isChecked', isChecked);
        await _sharedPreferences.setString('country', countryFromPref);

        var phoneNumber = "+" + country.phoneCode + userPhoneNumber;
        var password = userPassword;

        if (userPhoneNumber != "" && userPassword != "") {
          var _user;
          var _bankAccount;
          _auth.authenticate(phoneNumber, password).then((value) {
            _user = value;

            if (_user.fullName != null) {
              userBloc.user = _user;
              socketProvider.currentUser = _user;

              if (_user != null) {
                PaymentAndBankingAuth().getBankAccounts().then((accounts) {
                  try {
                    if (accounts.isNotEmpty) {
                      _bankAccount = accounts[0];
                    }

                    if (_bankAccount != null) {
                      bankAccountBloc.bankAccount = _bankAccount;
                      if (_user.isVerified == true) {
                        //initialize shoppingcart
                        initializeShoppingCart();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "/dashboard",
                          (Route<dynamic> route) => false,
                        );
                      }
                    } else {
                      //initialize shoppingcart
                      initializeShoppingCart();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        "/dashboard",
                        (Route<dynamic> route) => false,
                      );
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/index");
                  }
                });
              }
            } else {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/index");
            }
          }).catchError((error) {
            Navigator.pop(context);
            Navigator.of(context).pushNamed("/index");
          });
        } else {
          Navigator.pop(context);
          Navigator.of(context).pushNamed("/index");
        }
      }
    } else {
      Navigator.pop(context);
      Navigator.of(context).pushNamed("/index");
    }
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    List items = await ShoppingAuthService().getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(item: element, type: type);
    });
  }
}
