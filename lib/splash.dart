import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/global_key.dart';
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
  String errorText = "";

  @override
  void initState() {
    checkConnection();
    try {
      initPlatformState();
    } catch (error) {
      debugPrint("ERROR2:- $error");
      if (mounted) setState(() {});
    }
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  void checkConnection() async {
    await Connectivity().checkConnectivity().then((value) async {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        hasConnection = true;
        if (mounted) setState(() {});
        try {
          await getLoggedInUser();
        } catch (error) {
          debugPrint("ERROR1:- $error");
        }
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.black,
            duration: Toast.LENGTH_LONG,
            textColor: Colors.white);

        hasConnection = false;
        if (mounted) setState(() {});
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
          ? Scaffold(
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
                  // SizedBox(
                  //   height: 16,
                  // ),
                  // Text(
                  //   errorText,
                  //   style: TextStyle(
                  //       fontFamily: "CircularStd",
                  //       fontSize: 14,
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w600),
                  // )
                ],
              ),
            ))
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
    // await Future.delayed(Duration(milliseconds: 500));
    _sharedPreferences = await SharedPreferences.getInstance();

    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final MainSocketProvider socketProvider =
        Provider.of<MainSocketProvider>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
    if (isLoggedOut) {
      debugPrint("IsLoggedOut:- $isLoggedOut");
      Navigator.pop(MyGlobals().navigationKey.currentContext);
      Navigator.of(MyGlobals().navigationKey.currentContext)
          .pushNamed("/index");
      return;
    }

    isChecked = _sharedPreferences.getBool('isChecked') ?? false;

    if (isChecked) {
      countryFromPref = _sharedPreferences.getString('country');
      errorText += "countryFromPref = $countryFromPref\n";
      Country country1;
      try {
        country1 = CountryPickerUtils.getCountryByIsoCode("NG");
      } catch (error) {
        errorText += "error while fetching country1 = $error\n";
      }
      if (country1 != null) {
        errorText += "country1 phoneCode ${country1.phoneCode}\n";
        errorText += "country1 name ${country1.name}\n";
        errorText += "country1 isoCode ${country1.isoCode}\n";
        errorText += "country1 iso3Code ${country1.iso3Code}\n";
      }

      Country country2;
      try {
        country2 = CountryPickerUtils.getCountryByIsoCode(countryFromPref);
      } catch (error) {
        errorText += "error while fetching country2 = $error\n";
      }
      if (country2 != null) {
        errorText += "country2 phoneCode ${country2.phoneCode}\n";
        errorText += "country2 name ${country2.name}\n";
        errorText += "country2 isoCode ${country2.isoCode}\n";
        errorText += "country2 iso3Code ${country2.iso3Code}\n";

        SecureUser secureUser = await SecureStorage().getUser();
        userPhoneNumber = secureUser.phoneNumber;
        userPassword = secureUser.password;

        var phoneNumber = "+" + country2.phoneCode + userPhoneNumber;
        var password = userPassword;

        errorText += "phoneNumber $phoneNumber\n";
        errorText += "password $password\n";

        User user;
        try {
          user = await _auth.authenticate(phoneNumber, password);
        } catch (e) {
          errorText += "ERROR while fetching USER:- $e\n";
        }
        if (user != null) {
          errorText += "User:- ${user.toJson()}\n";

          List<BankAccount> accounts;

          try {
            accounts = await PaymentAndBankingAuth().getBankAccounts();
          } catch (e) {
            errorText += "ERROR while fetching ACCOUNTS:- $e\n";
          }

          if (accounts != null) {
            errorText += "accounts:- ${accounts.length}\n";
            accounts.forEach((element) {
              errorText +=
                  "element:- ${element.accountName} ${element.isDefault} \n";
            });

            bankAccountBloc.bankAccount = accounts.first;
            userBloc.user = user;
            socketProvider.currentUser = user;

            setState(() {});

            await initializeShoppingCart();

            setState(() {});

            Navigator.of(MyGlobals().navigationKey.currentContext)
                .pushNamedAndRemoveUntil(
              "/dashboard",
              (Route<dynamic> route) => false,
            );
            return;
          } else {
            errorText += "accounts not found\n";
          }
        } else {
          errorText += "User not found\n";
        }
      }
      if (mounted) setState(() {});
    } else {
      Navigator.pop(MyGlobals().navigationKey.currentContext);
      Navigator.of(MyGlobals().navigationKey.currentContext)
          .pushNamed("/index");
      return Future.value(null);
    }

    // try {
    //   if (isChecked) {
    //     countryFromPref = _sharedPreferences.getString('country');
    //     if (countryFromPref != null || countryFromPref != "") {
    //       Country country;
    //       try {
    //         country = CountryPickerUtils.getCountryByIsoCode(countryFromPref);
    //       } catch (error) {
    //         debugPrint("ERROR3:- $error countryFromPref= $countryFromPref");
    //       }
    //       if (country != null) {
    //         SecureUser secureUser = await SecureStorage().getUser();
    //         userPhoneNumber = secureUser.phoneNumber;
    //         userPassword = secureUser.password;
    //
    //         var phoneNumber = "+" + country.phoneCode + userPhoneNumber;
    //         var password = userPassword;
    //
    //         if (userPhoneNumber != "" && userPassword != "") {
    //           var _user;
    //           var _bankAccount;
    //
    //           User user;
    //
    //           try {
    //             user = await _auth.authenticate(phoneNumber, password);
    //           } catch (error) {
    //             debugPrint("ERROR5:- $error");
    //             Navigator.pop(MyGlobals().navigationKey.currentContext);
    //             Navigator.of(MyGlobals().navigationKey.currentContext)
    //                 .pushNamed("/index");
    //             return;
    //           }
    //
    //           if (user != null) {
    //             _user = user;
    //
    //             userBloc.user = _user;
    //             socketProvider.currentUser = _user;
    //
    //             List<BankAccount> accounts;
    //
    //             try {
    //               accounts = await PaymentAndBankingAuth().getBankAccounts();
    //             } catch (error) {
    //               debugPrint("ERROR4:- $error");
    //               Navigator.pop(MyGlobals().navigationKey.currentContext);
    //               Navigator.of(MyGlobals().navigationKey.currentContext)
    //                   .pushNamed("/index");
    //               return;
    //             }
    //
    //             if (accounts != null && accounts.isNotEmpty) {
    //               _bankAccount = accounts[0];
    //               if (_bankAccount != null) {
    //                 bankAccountBloc.bankAccount = _bankAccount;
    //                 if (_user.isVerified == true) {
    //                   //initialize shoppingcart
    //                   initializeShoppingCart();
    //                   Navigator.of(MyGlobals().navigationKey.currentContext)
    //                       .pushNamedAndRemoveUntil(
    //                     "/dashboard",
    //                     (Route<dynamic> route) => false,
    //                   );
    //                   return;
    //                 }
    //               } else {
    //                 //initialize shoppingcart
    //                 initializeShoppingCart();
    //                 Navigator.of(MyGlobals().navigationKey.currentContext)
    //                     .pushNamedAndRemoveUntil(
    //                   "/dashboard",
    //                   (Route<dynamic> route) => false,
    //                 );
    //                 return;
    //               }
    //             } else {
    //               initializeShoppingCart();
    //               Navigator.of(MyGlobals().navigationKey.currentContext)
    //                   .pushNamedAndRemoveUntil(
    //                 "/dashboard",
    //                 (Route<dynamic> route) => false,
    //               );
    //               return;
    //             }
    //           } else {
    //             Navigator.pop(MyGlobals().navigationKey.currentContext);
    //             Navigator.of(MyGlobals().navigationKey.currentContext)
    //                 .pushNamed("/index");
    //             return;
    //           }
    //         } else {
    //           Navigator.pop(MyGlobals().navigationKey.currentContext);
    //           Navigator.of(MyGlobals().navigationKey.currentContext)
    //               .pushNamed("/index");
    //           return;
    //         }
    //       } else {
    //         Navigator.pop(MyGlobals().navigationKey.currentContext);
    //         Navigator.of(MyGlobals().navigationKey.currentContext)
    //             .pushNamed("/index");
    //         return;
    //       }
    //     } else {
    //       Navigator.pop(MyGlobals().navigationKey.currentContext);
    //       Navigator.of(MyGlobals().navigationKey.currentContext)
    //           .pushNamed("/index");
    //       return;
    //     }
    //   } else {
    //     debugPrint(
    //         "ERROr11:- countryFromPref = $countryFromPref isChecked = $isChecked isLoggedOut = $isLoggedOut");
    //     Navigator.pop(MyGlobals().navigationKey.currentContext);
    //     Navigator.of(MyGlobals().navigationKey.currentContext)
    //         .pushNamed("/index");
    //     return;
    //   }
    // } catch (error) {
    //   debugPrint("ERROR7:- $error");
    //   Navigator.of(MyGlobals().navigationKey.currentContext)
    //       .pushNamed("/index");
    //   return;
    // }
    // Navigator.pop(MyGlobals().navigationKey.currentContext);
    // Navigator.of(MyGlobals().navigationKey.currentContext).pushNamed("/index");
    // return;
  }

  Future<void> initializeShoppingCart() async {
    try {
      debugPrint("initializeShoppingCart called");
      List items = await ShoppingAuthService().getShoppingCart();
      items.forEach((element) {
        String type = element is Product ? "product" : "service";
        basketBloc.addItemToCart(item: element, type: type);
      });
    } catch (e) {
      errorText += "ERROR:- while loading shopping cart ITEM\n";
      debugPrint("ERROR:- while loading shopping cart ITEM");
    }
  }
}
