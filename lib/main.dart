import 'dart:async';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_generator.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_shake_detection.dart';
import 'package:Slydo/services/app_life_cycle.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/local_notification_service.dart';
import 'package:Slydo/services/route_observer.dart';
import 'package:Slydo/services/route_provider.dart';
import 'package:Slydo/services/timer_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'locale/app_localization.dart';

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  //Crashlytics.instance.enableInDevMode = true;

  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService().init();

  await Firebase.initializeApp();

  AwesomeNotificationService().init();

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

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
          ChangeNotifierProvider<RefreshBlocForConnectionDashboard>.value(
            value: RefreshBlocForConnectionDashboard(),
          ),
          ChangeNotifierProvider<BasketBloc>.value(
            value: BasketBloc(),
          ),
          ChangeNotifierProvider<AddressBloc>.value(
            value: AddressBloc(),
          ),
          ChangeNotifierProvider<DashboardBloc>.value(
            value: DashboardBloc(),
          ),

          ///Uncomment this when we implement this functionality
          // ChangeNotifierProvider<MovieDashboardBloc>.value(
          //   value: MovieDashboardBloc(),
          // ),
          // ChangeNotifierProvider<BusDashboardBloc>.value(
          //   value: BusDashboardBloc(),
          // ),
          // ChangeNotifierProvider<TrainDashboardBloc>.value(
          //   value: TrainDashboardBloc(),
          // ),
          // ChangeNotifierProvider<FlightDashboardBloc>.value(
          //   value: FlightDashboardBloc(),
          // ),
          // ChangeNotifierProvider<EventDashboardBloc>.value(
          //   value: EventDashboardBloc(),
          // ),
          // ChangeNotifierProvider<ShoppingDashboardBloc>.value(
          //   value: ShoppingDashboardBloc(),
          // ),
          // ChangeNotifierProvider<HotelDashboardBloc>.value(
          //   value: HotelDashboardBloc(),
          // ),
          // ChangeNotifierProvider<PropertyDashboardBloc>.value(
          //   value: PropertyDashboardBloc(),
          // ),
          // ChangeNotifierProvider<PropertyFilterBloc>.value(
          //   value: PropertyFilterBloc(),
          // ),
          // ChangeNotifierProvider<MusicDashboardBloc>.value(
          //   value: MusicDashboardBloc(),
          // ),
          // ChangeNotifierProvider<MusicPlayer>.value(
          //   value: MusicPlayer(),
          // ),

          ChangeNotifierProvider<AddInvoiceBloc>.value(
            value: AddInvoiceBloc(),
          ),
          ChangeNotifierProvider<TimerService>.value(
            value: TimerService(),
          ),
          ChangeNotifierProvider<MainSocketProvider>.value(
            value: MainSocketProvider(),
          ),
          ChangeNotifierProvider<ChatShakeDetection>.value(
            value: ChatShakeDetection(),
          ),
          ChangeNotifierProvider<RouteProvider>.value(
            value: RouteProvider(),
          ),
          ChangeNotifierProvider<ShareMessageToChatBloc>.value(
            value: ShareMessageToChatBloc(),
          ),
          ChangeNotifierProvider<ConnectionListBloc>.value(
            value: ConnectionListBloc(),
          ),
        ], child: MyApp()),
      );
    }, onError: (exception, stack) {
      FirebaseCrashlytics.instance.recordError(exception, stack);
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
      child: LayoutBuilder(builder: (context, constraints) {
        return OrientationBuilder(builder: (context, orientation) {
          SizerUtil().init(constraints, orientation);
          return MaterialApp(
            navigatorKey: MyGlobals().navigationKey,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              _localeOverrideDelegate
            ],
            navigatorObservers: [MyRouteObserver()],
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
            theme: ThemeData(
                primaryColor: navyBlue,
                fontFamily: "OpenSans",
                textSelectionHandleColor: navyBlue,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                backgroundColor: navyBlue),
          );
        });
      }),
    );
  }
}
