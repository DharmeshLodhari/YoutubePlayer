import 'dart:async';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_message_settings.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'data/socket_provider.dart';
import 'data/state_notifier.dart';
import 'locale/app_localization.dart';
import 'screens/more_apps/user_profile/models/device.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool isChecked = false;
  bool isLoggedOut = false;
  String? countryFromPref;
  String? userPhoneNumber;
  String? userPassword;
  String? company;
  bool isStaffLogin = false;
  late SharedPreferences _sharedPreferences;
  late BasketBloc basketBloc;
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;

  // bool for to check if internet connection is available or not
  bool hasConnection = true;
  String errorText = "";

  VideoPlayerController? playerController;
  late VoidCallback listener;

  bool? isUserFound;
  Timer? timer;

  @override
  void initState() {
    listener = () {
      setState(() {});
    };
    initializeVideo();
    playerController!.play();

    ///video splash display only 5 second you can change the duration according to your need
    timer = startTime();

    try {
      initPlatformState();
    } catch (error) {
      debugPrint("ERROR2:- $error");
      if (mounted) setState(() {});
    }
    checkConnection();
    AwesomeNotificationService().awesomeNotifications.cancelAll();
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
  }

  Timer startTime() {
    final _duration = const Duration(seconds: 1);
    return Timer.periodic(_duration, (timer) {
      navigationPage();
    });
  }

  void navigationPage() {
    debugPrint(
        "isUserFound => $isUserFound playerController.value.isPlaying => ${playerController!.value.isPlaying}");
    if (isUserFound != null && playerController!.value.isPlaying == false) {
      playerController!.setVolume(0.0);
      playerController!.removeListener(listener);
      if (isUserFound == true) {
        if (timer != null) timer?.cancel();
        Navigator.of(MyGlobals().navigationKey.currentContext!)
            .pushNamedAndRemoveUntil(
          "/dashboard",
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(MyGlobals().navigationKey.currentContext!)
            .pushReplacementNamed("/index");
      }
    }
  }

  void initializeVideo() {
    playerController =
        VideoPlayerController.asset('assets/images/splash/splash-v3.mp4',
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
            ))
          ..addListener(listener)
          ..setVolume(0)
          ..initialize()
          ..play();
  }

  @override
  void deactivate() {
    if (playerController != null) {
      playerController?.setVolume(0.0);
      playerController?.removeListener(listener);
    }
    super.deactivate();
  }

  @override
  void dispose() async {
    super.dispose();
    if (playerController != null) {
      await playerController?.pause();
      await playerController?.dispose();
    }
    if (timer != null) timer?.cancel();
  }

  void checkConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.mobile)) {
      hasConnection = true;
      if (mounted) setState(() {});
      try {
        await getLoggedInUser();
      } catch (error) {
        debugPrint("ERROR1:- $error");
        return Future.value(null);
      }
    } else {
      showToast(
          message: AppLocalization.of(context)!.internetConnectionNotAvailable);

      hasConnection = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> initPlatformState() async {
    List? languagesList;
    String? currentLocale;

    //checking if the language data is stored in system or not
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      final String languageCode = sharedPreferences.getString("language")!;
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
      late Language language;
      languages.forEach((lang) {
        if (lang.languageCode == currentLocale!.substring(0, 2)) {
          language = lang;
          return;
        }
      });

      AppLocalization.load(Locale(language.languageCode, ""));
      debugPrint("Language Set From System ${language.name}");

      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      if (sharedPreferences.containsKey("language")) {
        final bool result = await sharedPreferences.setString(
            "language", language.languageCode);
        debugPrint("Language is updated in sharedPreference => $result");
      } else {
        final bool result = await sharedPreferences.setString(
            "language", language.languageCode);
        debugPrint("Language is set in sharedPreference => $result");
      }
    } on PlatformException {
      debugPrint("Error obtaining current locale");
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/app_logo.png"), context);
    basketBloc = Provider.of<BasketBloc>(context);
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: hasConnection
          ? Scaffold(
              body: Stack(fit: StackFit.expand, children: <Widget>[
              AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    child: (playerController != null
                        ? VideoPlayer(
                            playerController!,
                          )
                        : Container()),
                  )),
            ]))
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
                      msg: AppLocalization.of(context)!
                          .internetConnectionNotAvailable,
                    ),
                  ),
                  MaterialButton(
                    color: navyBlue,
                    onPressed: checkConnection,
                    child: Text(
                      AppLocalization.of(context)!.retry,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> getLoggedInUser() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final MainSocketProvider socketProvider =
        Provider.of<MainSocketProvider>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    // for not showing intro second time we are maintaining this variable in shared pref
    isLoggedOut = _sharedPreferences.getBool('isLoggedOut') ?? false;
    if (isLoggedOut) {
      debugPrint("IsLoggedOut:- $isLoggedOut");
      isUserFound = false;
      return;
    }

    isChecked = _sharedPreferences.getBool('isChecked') ?? false;

    if (isChecked) {
      countryFromPref = _sharedPreferences.getString('country');
      errorText += "countryFromPref = $countryFromPref\n";
      Country? country1;
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

      Country? country2;
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

        final SecureUser secureUser = await SecureStorage().getUser();
        userPhoneNumber = secureUser.phoneNumber;
        userPassword = secureUser.password;
        company = secureUser.company;
        isStaffLogin = secureUser.isStaffLogin ?? false;

        final phoneNumber = "+" + country2.phoneCode! + userPhoneNumber!;
        errorText += "phoneNumber $phoneNumber\n";

        User? user;
        try {
          user = await _auth.authenticate(phoneNumber, userPassword,
              isStaffLogin: isStaffLogin, company: company);
        } catch (e) {
          errorText += "ERROR while fetching USER:- $e\n";
          isUserFound = false;
        }
        if (user != null) {
          errorText += "User:- ${user.toJson()}\n";

          List<BankAccount>? accounts;

          try {
            accounts = await PaymentAndBankingAuth().getBankAccounts();
          } catch (e) {
            errorText += "ERROR while fetching ACCOUNTS:- $e\n";
            isUserFound = false;
            CacheManager().deleteCache(clearAll: true);
            return;
          }

          if (accounts.isNotEmpty) {
            errorText += "accounts:- ${accounts.length}\n";
            accounts.forEach((element) {
              errorText +=
                  "element:- ${element.accountName} ${element.isDefault} \n";
            });

            if (accounts.length > 0) {
              bankAccountBloc.bankAccount = accounts.first;
            }

            userBloc.user = user;

            /// get User's YARN Setting
            getUserYarnSetting();

            /// get user settings from DB
            final Map<String, dynamic> settings =
                await DatabaseHelper().getGeneralSettings();
            final ChatMessageSettings chatMessageSettings =
                ChatMessageSettings.fromDBJson(settings);
            userBloc.chatMessageSettings = chatMessageSettings;

            try {
              socketProvider.setCurrentUser(user);
            } catch (error) {
              debugPrint("ERROR:- $error");
            }

            setState(() {});

            await initializeShoppingCart();

            setState(() {});

            isUserFound = true;
            return;
          } else {
            errorText += "accounts not found\n";
          }
        } else {
          errorText += "User not found\n";
        }
      }
      if (mounted) setState(() {});
    }
    isUserFound = false;
    CacheManager().deleteCache(clearAll: true);

    return Future.value(null);

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
      final List items = await ShoppingAuthService().getShoppingCart();
      items.forEach((element) {
        final String type = element is Product ? "product" : "service";
        basketBloc.addItemToCart(
            item: element,
            type: type,
            currentUser: userBloc.user.convertToUser(),
            withApiCall: false);
      });
      await sharedCartBloc.refreshAllCart(context);
    } catch (e) {
      errorText += "ERROR:- while loading shopping cart ITEM\n";
      debugPrint("ERROR:- while loading shopping cart ITEM");
      isUserFound = false;
      CacheManager().deleteCache(clearAll: true);
    }
  }

  void getUserYarnSetting() async {
    await YarnAuth().getUserYarnSettings().then((value) async {
      if (value != null) {
        final YarnDashboardBloc yarnDashboardBloc =
            Provider.of<YarnDashboardBloc>(
                MyGlobals().navigationKey.currentContext ?? context,
                listen: false);
        yarnDashboardBloc.yarnSettings = value;
      }
    });
  }
}
