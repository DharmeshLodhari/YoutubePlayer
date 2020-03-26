import 'package:Slydo/data/state_notifier.dart';
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
    super.initState();
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
    // TODO: implementation of onResume
    debugPrint("App Life Cycle state is resumed and onResume is called");
  }

  void onInactive() {
    // TODO: implementation of onInactive
    debugPrint("App Life Cycle state is inactive and onInactive is called");
  }

  void onPause() {
    // TODO: implementation of onPause
    debugPrint("App Life Cycle state is paused and onPause is called");
  }

  void onDetached() {
    // TODO: implementation of onDetached
    debugPrint("App Life Cycle state is detached and onDetached is called");
  }

  // it will refresh all the list of the app eg: transactions, paymentRequests, messages
  void onRefresh() {
    _refreshBlocForTransaction.isRefresh = true;
    _refreshBlocForRequestPayment.isRefresh = true;
    _refreshBlocForMessages.isRefresh = true;
  }
}
