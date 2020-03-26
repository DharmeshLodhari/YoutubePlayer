import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLifeCycle extends StatefulWidget {
  final Widget child;
  AppLifeCycle({Key key, this.child});
  @override
  _AppLifeCycleState createState() => _AppLifeCycleState();
}

class _AppLifeCycleState extends State<AppLifeCycle>
    with WidgetsBindingObserver {
  RefreshBlocForTransaction _refreshBlocForTransaction;
  RefreshBlocForRequestPayment _refreshBlocForRequestPayment;
  RefreshBlocForMessages _refreshBlocForMessages;
  DatabaseHelper _db = DatabaseHelper();
  final _auth = AuthService();
  Map<String, dynamic> device;

  @override
  Widget build(BuildContext context) {
    _refreshBlocForTransaction =
        Provider.of<RefreshBlocForTransaction>(context);
    _refreshBlocForRequestPayment =
        Provider.of<RefreshBlocForRequestPayment>(context);
    _refreshBlocForMessages = Provider.of<RefreshBlocForMessages>(context);
    return widget.child;
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
      debugPrint(e);
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
        onResume();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  void onResume() {
    // refreshing the list on onResume
    onRefresh();

    //this will store the device data and the app state
    Map<String, String> tempData = Map<String, String>();
    tempData['token'] = device != null ? device['firebaseToken'] : "";
    tempData['type'] = device != null ? device['type'] : "";
    tempData['state'] = "active";
    tempData['device_name'] = device != null ? device['deviceName'] : "";
    _auth.updateAppState(tempData);

    debugPrint("App Life Cycle state is resumed and onResume is called");
  }

  void onInactive() {
    //this will store the device data and the app state
    Map<String, String> tempData = Map<String, String>();
    tempData['token'] = device != null ? device['firebaseToken'] : "";
    tempData['type'] = device != null ? device['type'] : "";
    tempData['state'] = "inActive";
    tempData['device_name'] = device != null ? device['deviceName'] : "";
    _auth.updateAppState(tempData);

    debugPrint("App Life Cycle state is inactive and onInactive is called");
  }

  void onPause() {
    //this will store the device data and the app state
    Map<String, String> tempData = Map<String, String>();
    tempData['token'] = device != null ? device['firebaseToken'] : "";
    tempData['type'] = device != null ? device['type'] : "";
    tempData['state'] = "inBackground";
    tempData['device_name'] = device != null ? device['deviceName'] : "";
    _auth.updateAppState(tempData);

    debugPrint("App Life Cycle state is paused and onPause is called");
  }

  void onDetached() {
    //this will store the device data and the app state
    Map<String, String> tempData = Map<String, String>();
    tempData['token'] = device != null ? device['firebaseToken'] : "";
    tempData['type'] = device != null ? device['type'] : "";
    tempData['state'] = "suspended";
    tempData['device_name'] = device != null ? device['deviceName'] : "";
    _auth.updateAppState(tempData);

    debugPrint("App Life Cycle state is detached and onDetached is called");
  }

  // it will refresh all the list of the app eg: transactions, paymentRequests, messages
  void onRefresh() {
    _refreshBlocForTransaction.isRefresh = true;
    _refreshBlocForRequestPayment.isRefresh = true;
    _refreshBlocForMessages.isRefresh = true;
  }
}
