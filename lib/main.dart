import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() {

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
          ],
          child: MaterialApp(
            initialRoute: '/',
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
          )),
    );
  }, onError: Crashlytics.instance.recordError);
}
