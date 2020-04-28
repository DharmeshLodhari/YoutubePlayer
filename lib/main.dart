import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/route_generator.dart';
import 'package:Slydo/services/app_life_cycle.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'locale/app_localization.dart';

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  //Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();
  // to set orientation only vertical
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((value) {
    runZoned(() {
      runApp(
        MultiProvider(providers: [
          ChangeNotifierProvider<UserBloc>.value(
            value: UserBloc(),
          ),
          ChangeNotifierProvider<PayeeBloc>.value(
            value: PayeeBloc(),
          ),
          ChangeNotifierProvider<CustomerProfileBloc>.value(
            value: CustomerProfileBloc(),
          ),
          ChangeNotifierProvider<BankAccountBloc>.value(
            value: BankAccountBloc(),
          ),
          ChangeNotifierProvider<RefreshBlocForTransaction>.value(
            value: RefreshBlocForTransaction(),
          ),
          ChangeNotifierProvider<RefreshBlocForRequestPayment>.value(
            value: RefreshBlocForRequestPayment(),
          ),
          ChangeNotifierProvider<RefreshBlocForMessages>.value(
            value: RefreshBlocForMessages(),
          ),
        ], child: MyApp()),
      );
    }, onError: (exception, stack) {
      Crashlytics.instance.recordError(exception, stack);
//    final _auth = AuthService();
//    _auth.logOut();
//    exit(0);
    });
  });
}

class MyApp extends StatelessWidget {
  //default local language
  final AppLocalizationDelegate _localeOverrideDelegate =
      AppLocalizationDelegate(Locale('en', 'US'));

  @override
  Widget build(BuildContext context) {
    return AppLifeCycle(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          _localeOverrideDelegate
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('fr', 'FR'),
          const Locale('es', 'ES'),
          const Locale('pt', 'PT'),
          const Locale('am', 'ET'),
          const Locale('ar', 'AE'),
          const Locale('ha', 'KE'),
          const Locale('sw', 'KE'),
          const Locale('yo', 'NG'),
          const Locale('zu', 'ZA'),
        ],
        initialRoute: '/splash',
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
