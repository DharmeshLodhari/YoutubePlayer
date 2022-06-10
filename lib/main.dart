import 'dart:async';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_generator.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/business/bloc/contract_bloc.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/events/event_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/flight/flight_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/hotels/hotel_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_shake_detection.dart';
import 'package:Slydo/screens/more_apps/movies/movie_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/music/music_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/music/music_player.dart';
import 'package:Slydo/screens/more_apps/property/property_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_screen.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/train/train_dashboard_bloc.dart';
import 'package:Slydo/services/app_config_bloc.dart';
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
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:workmanager/workmanager.dart';

import 'locale/app_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

void callbackDispatcher() {
  // Workmanager().executeTask((task, inputData) {
  //   try {
  //     debugPrint("WorkManager started message synchronization");
  //     ChatMessageSynchronizer().syncMessages(fetchFresh: true);
  //   } catch (e) {
  //     debugPrint("WorkManager exception caught: $e");
  //   }
  //   return Future.value(true);
  // });

  AppConfig();

  Workmanager().executeTask((task, inputData) async {
    await AppConfigurationService().getAppConfigurations().then(
      (value) {
        debugPrint('APP CONFIGS ::: $value');

        storage.write(
            key: appConfigurationKey,
            value: AppConfigurationModel.serialize(value!));
      },
    );
    return Future.value(true);
    // try {
    //   debugPrint("WorkManager started app configuration synchronization");
    //   await AppConfigurationService().getAppConfigurations().then(
    //     (value) {
    //       debugPrint('APP CONFIGS ::: $value');
    //       locator<AppConfigurationBloc>().appConfigurationModel = value;
    //
    //       debugPrint(
    //           'CONFIG MODEL :: ${locator<AppConfigurationBloc>().appConfigurationModel?.enableUtility}');
    //     },
    //   );
    //   return Future.value(true);
    // } catch (e) {
    //   debugPrint("WorkManager exception caught: $e");
    //   return Future.error('Fetching app configuration failed:: $e');
    // }
  });
}

void main() async {
  debugPrint('MAIN RUNNING');

  WidgetsFlutterBinding.ensureInitialized();

  AppConfig();

  initializeBackgroundService();

  await FlutterDownloader.initialize();

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
    runZonedGuarded(() {
      runApp(
        MultiProvider(providers: providersList, child: MyApp()),
      );
    }, (exception, stack) {
      FirebaseCrashlytics.instance.recordError(exception, stack);
//    final _auth = AuthService();
//    _auth.logOut();
//    exit(0);
    });
  });
}

void initializeBackgroundService() async {
  try {
    await AppConfigurationService().getAppConfigurations().then(
      (value) {
        debugPrint('APP CONFIGS ::: $value');

        storage.write(
            key: appConfigurationKey,
            value: AppConfigurationModel.serialize(value!));
      },
    );
  } catch (e) {
    debugPrint('APP CONFIG ERROR ---> ${e.toString()}');
  }
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  debugPrint('BACKGROUND SERVICE RUNNING');
  Workmanager().registerPeriodicTask(
    "appConfigPeriodicTask",
    "appConfigPeriodicTaskName",
  );
}

class MyApp extends StatefulWidget {
  //default local language
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLocalizationDelegate _localeOverrideDelegate =
      AppLocalizationDelegate(Locale('en', 'US'));

  @override
  void initState() {
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ShareManager().initializeShareManager();
    });*/

    super.initState();
  }

  @override
  void dispose() {
    //ShareManager().disposeShareManager();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLifeCycle(
      child: LayoutBuilder(builder: (context, constraints) {
        return OrientationBuilder(builder: (context, orientation) {
          SizerUtil.setScreenSize(constraints, orientation);
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
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              backgroundColor: navyBlue,
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: navyBlue,
              ),
            ),
          );
        });
      }),
    );
  }
}

List<ChangeNotifierProvider> providersList = [
  ChangeNotifierProvider<UserBloc>.value(
    value: UserBloc(),
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
  ChangeNotifierProvider<InvoiceBloc>.value(
    value: InvoiceBloc(),
  ),
  ChangeNotifierProvider<ContractBloc>.value(
    value: ContractBloc(),
  ),

  ///Uncomment this when we implement this functionality
  ChangeNotifierProvider<MovieDashboardBloc>.value(
    value: MovieDashboardBloc(),
  ),
  ChangeNotifierProvider<BusDashboardBloc>.value(
    value: BusDashboardBloc(),
  ),
  ChangeNotifierProvider<TrainDashboardBloc>.value(
    value: TrainDashboardBloc(),
  ),
  ChangeNotifierProvider<FlightDashboardBloc>.value(
    value: FlightDashboardBloc(),
  ),
  ChangeNotifierProvider<EventDashboardBloc>.value(
    value: EventDashboardBloc(),
  ),
  ChangeNotifierProvider<ShoppingDashboardBloc>.value(
    value: ShoppingDashboardBloc(),
  ),
  ChangeNotifierProvider<HotelDashboardBloc>.value(
    value: HotelDashboardBloc(),
  ),
  ChangeNotifierProvider<PropertyDashboardBloc>.value(
    value: PropertyDashboardBloc(),
  ),
  ChangeNotifierProvider<PropertyFilterBloc>.value(
    value: PropertyFilterBloc(),
  ),
  ChangeNotifierProvider<MusicDashboardBloc>.value(
    value: MusicDashboardBloc(),
  ),
  ChangeNotifierProvider<MusicPlayer>.value(
    value: MusicPlayer(),
  ),

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

  ChangeNotifierProvider<BackgroundFetchStopBloc>.value(
    value: BackgroundFetchStopBloc(),
  ),

  ChangeNotifierProvider<TaxiBloc>.value(
    value: TaxiBloc(),
  ),
  ChangeNotifierProvider<CheckoutScreenBloc>.value(
    value: CheckoutScreenBloc(),
  ),
  ChangeNotifierProvider<AppConfigurationBloc>.value(
    value: AppConfigurationBloc(),
  ),
];
