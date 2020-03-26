import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/route_generator.dart';
import 'package:Slydo/services/app_life_cycle.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  //Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() {
    runApp(
      MultiProvider(
          providers: [
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
          ],
          child: AppLifeCycle(
            child: MaterialApp(
              initialRoute: '/splash',
              onGenerateRoute: RouteGenerator.generateRoute,
              debugShowCheckedModeBanner: false,
            ),
          )),
    );
  }, onError: (exception, stack) {
    Crashlytics.instance.recordError(exception, stack);
//    final _auth = AuthService();
//    _auth.logOut();
//    exit(0);
  });
}
