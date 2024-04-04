import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutHelper {
  Future<void> logoutUser() async {
    final BackgroundFetchStopBloc backgroundFetchBloc =
        Provider.of<BackgroundFetchStopBloc>(
            myGlobals.navigationKey.currentContext!,
            listen: false);

    backgroundFetchBloc.isAllowed = false;

    emptyBasketCart();
    SharedPreferences _sharedPreferences;

    MainSocketMessageHandler().dispose();

    await AuthService().logOut().catchError((error) {
      debugPrint("ERROR:- while logging out the user");
    });

    CacheManager().deleteCache(clearAll: true);

    final MainSocketProvider socketProvider = Provider.of<MainSocketProvider>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    await socketProvider.close();

    PushNotificationService().logout();

    final BankAccountBloc bankAccountBlocPart = Provider.of<BankAccountBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);
    final DashboardBloc dashboardBloc = Provider.of<DashboardBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    bankAccountBlocPart.bankAccount = BankAccount();
    // dashboardBloc.index = 0;
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool('isLoggedOut', true);
    _sharedPreferences.setBool('isAppTutorialDone', true);

    /// clearing all data when user is logout
    if (!_sharedPreferences.getBool("isChecked")!) {
      debugPrint("WorkManager cancel");
      // Workmanager().cancelAll();
      await SecureStorage().clear();
    }

    Navigator.of(myGlobals.navigationKey.currentContext!).popUntil(
      ModalRoute.withName('/splash'),
    );

    Navigator.of(myGlobals.navigationKey.currentContext!)
        .pushNamed("/index", arguments: {'isIntroDone': true});
  }

  void emptyBasketCart() {
    final BasketBloc basketBloc = Provider.of<BasketBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    basketBloc.items.clear();
    basketBloc.total = 0;
  }
}
