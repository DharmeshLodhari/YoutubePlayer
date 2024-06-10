import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLifeCycle extends StatefulWidget {
  final Widget? child;

  AppLifeCycle({super.key, this.child});

  @override
  _AppLifeCycleState createState() => _AppLifeCycleState();
}

class _AppLifeCycleState extends State<AppLifeCycle>
    with WidgetsBindingObserver {
  late RefreshBlocForTransaction _refreshBlocForTransaction;
  late RefreshBlocForRequestPayment _refreshBlocForRequestPayment;
  late RefreshBlocForMessages _refreshBlocForMessages;
  final DatabaseHelper _db = DatabaseHelper();
  final _auth = AuthService();
  Map<String, dynamic>? device;

  @override
  Widget build(BuildContext context) {
    _refreshBlocForTransaction =
        Provider.of<RefreshBlocForTransaction>(context);
    _refreshBlocForRequestPayment =
        Provider.of<RefreshBlocForRequestPayment>(context);
    _refreshBlocForMessages = Provider.of<RefreshBlocForMessages>(context);
    return widget.child!;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    // fetching device info from db
    fetchDeviceInfo();
    super.initState();
  }

  void fetchDeviceInfo() async {
    try {
      device = await _db.getDevice();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (isUserIsLoggedIn()) onResume();
        break;
      case AppLifecycleState.inactive:
        if (isUserIsLoggedIn()) onInactive();
        break;
      case AppLifecycleState.paused:
        if (isUserIsLoggedIn()) onPause();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  bool isUserIsLoggedIn() {
    if (myGlobals.scaffoldKey.currentContext != null) {
      return true;
    }
    return false;
  }

  void onResume() {
    // refreshing the list on onResume
    // onRefresh();

    AwesomeNotificationService().awesomeNotifications.cancelAll();

    //this will store the device data and the app state
    final Map<String, String?> tempData = <String, String?>{};
    tempData['token'] = device != null ? device!['firebaseToken'] : "";
    tempData['type'] = device != null ? device!['type'] : "";
    tempData['state'] = "active";
    tempData['device_name'] = device != null ? device!['deviceName'] : "";
    if (device != null) {
      _auth.updateAppState(tempData);
    }

    debugPrint("App Life Cycle state is resumed and onResume is called");
  }

  void onInactive() {
    //this will store the device data and the app state
    final Map<String, String?> tempData = <String, String?>{};
    tempData['token'] = device != null ? device!['firebaseToken'] : "";
    tempData['type'] = device != null ? device!['type'] : "";
    tempData['state'] = "inActive";
    tempData['device_name'] = device != null ? device!['deviceName'] : "";
    if (device != null) {
      _auth.updateAppState(tempData);
    }

    debugPrint("App Life Cycle state is inactive and onInactive is called");
  }

  void onPause() {
    //this will store the device data and the app state
    final Map<String, String?> tempData = <String, String?>{};
    tempData['token'] = device != null ? device!['firebaseToken'] : "";
    tempData['type'] = device != null ? device!['type'] : "";
    tempData['state'] = "in-background";
    tempData['device_name'] = device != null ? device!['deviceName'] : "";
    if (device != null) {
      _auth.updateAppState(tempData);
    }

    debugPrint("App Life Cycle state is paused and onPause is called");
  }

  void onDetached() {
    //this will store the device data and the app state
    final Map<String, String?> tempData = <String, String?>{};
    tempData['token'] = device != null ? device!['firebaseToken'] : "";
    tempData['type'] = device != null ? device!['type'] : "";
    tempData['state'] = "suspended";
    tempData['device_name'] = device != null ? device!['deviceName'] : "";
    if (device != null) {
      _auth.updateAppState(tempData);
    }

    debugPrint("App Life Cycle state is detached and onDetached is called");
  }

  // it will refresh all the list of the app eg: transactions, paymentRequests, messages
  void onRefresh() {
    _refreshBlocForTransaction.isRefresh = true;
    _refreshBlocForRequestPayment.isRefresh = true;
    _refreshBlocForMessages.isRefresh = true;
  }
}
