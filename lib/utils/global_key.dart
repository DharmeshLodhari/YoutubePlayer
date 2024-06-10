import 'dart:async';

import 'package:flutter/material.dart';

MyGlobals myGlobals = MyGlobals();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyGlobals {
  MyGlobals._internal();

  static final MyGlobals _myGlobals = MyGlobals._internal();
  static final GlobalKey _scaffoldKey = GlobalKey();
  static StreamSubscription? notificationStream;

  static final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  factory MyGlobals() {
    return _myGlobals;
  }

  GlobalKey get scaffoldKey => _scaffoldKey;

  GlobalKey<NavigatorState> get navigationKey => _navKey;

  bool get hasNavigator => navigationKey.currentState != null;
  NavigatorState? get navigator => navigationKey.currentState;

  bool get hasContext => navigator?.overlay?.context != null;
  BuildContext? get context => navigator?.overlay?.context;
}
