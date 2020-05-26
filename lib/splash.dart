import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'data/state_notifier.dart';
import 'locale/app_localization.dart';
import 'models/device.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isChecked = false;
  bool isLoggedOut = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  SharedPreferences _sharedPreferences;
  final _auth = AuthService();
  BasketBloc basketBloc;

  // bool for to check if internet connection is available or not
  var hasConnection = false;

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
    basketBloc = Provider.of<BasketBloc>(context);
    return Container(
      color: lightBlue(),
      child: hasConnection
          ? SpinKitChasingDots(
              color: Colors.white,
              size: 100.0,
              duration: Duration(milliseconds: 4000),
            )
          : Scaffold(
              backgroundColor: lightBlue(),
              appBar: AppBar(
                title: Text('Slydo'),
                backgroundColor: darkBlue(),
                elevation: 0.0,
                automaticallyImplyLeading: false,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  NoItemInList(
                    msg: AppLocalization.of(context)
                        .internetConnectionNotAvailable,
                  ),
                  MaterialButton(
                    color: darkBlue(),
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
    _sharedPreferences = await SharedPreferences.getInstance();
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    if (_sharedPreferences != null) {
      isChecked = _sharedPreferences.getBool('isChecked') ?? false;
      isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
      if (isLoggedOut) {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/index");
      } else {
        phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
        passwordFromPref = _sharedPreferences.getString('password') ?? "";

        await _sharedPreferences.setBool('isLoggedOut', isLoggedOut);
        await _sharedPreferences.setBool('isChecked', isChecked);
        await _sharedPreferences.setString('username', phoneNumberFromPref);
        await _sharedPreferences.setString('password', passwordFromPref);

        var phoneNumber = phoneNumberFromPref;
        var password = passwordFromPref;

        if (phoneNumberFromPref != "" && passwordFromPref != "") {
          var _user;
          var _bankAccount;
          _auth.authenticate(phoneNumber, password).then((value) {
            _user = value;

            if (_user.fullName != null) {
              userBloc.user = _user;

              if (_user != null) {
                _auth.getBankAccounts().then((accounts) {
                  try {
                    if (accounts.isNotEmpty) {
                      _bankAccount = accounts[0];
                    }

                    if (_bankAccount != null) {
                      bankAccountBloc.bankAccount = _bankAccount;
                      if (_user.isVerified == true) {
                        //initialize shoppingcart
                        initializeShoppingCart();
                        Navigator.of(context).pushNamed('/dashboard');
                      } else {
                        Navigator.of(context)
                            .popAndPushNamed('/bvn-verification');
                      }
                    } else {
                      //initialize shoppingcart
                      initializeShoppingCart();
                      Navigator.of(context).pushNamed('/dashboard');
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                });
              }
            } else {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/index");
            }
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
    List items = await _auth.getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(item: element, type: type);
    });
  }
}
