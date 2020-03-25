import 'package:flutter/material.dart';

class AppLifeCycle extends StatefulWidget {
  final Widget child;
  AppLifeCycle({Key key, this.child});
  @override
  _AppLifeCycleState createState() => _AppLifeCycleState();
}

class _AppLifeCycleState extends State<AppLifeCycle>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
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
}
