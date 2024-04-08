import 'dart:async';

import 'package:flutter/material.dart';

MyGlobals myGlobals = MyGlobals();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyGlobals {
  MyGlobals._internal();

  static final MyGlobals _myGlobals = MyGlobals._internal();
  static final GlobalKey _scaffoldKey = GlobalKey();
  static StreamSubscription? _notificationStream;

  static final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  static set notificationStream(StreamSubscription? value) {
    _notificationStream = value;
  }

  factory MyGlobals() {
    return _myGlobals;
  }

  GlobalKey get scaffoldKey => _scaffoldKey;

  GlobalKey<NavigatorState> get navigationKey => _navKey;

  static StreamSubscription? get notificationStream => _notificationStream;
}
