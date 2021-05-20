import 'package:flutter/material.dart';

MyGlobals myGlobals = MyGlobals();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyGlobals {
  MyGlobals._internal();

  static final MyGlobals _myGlobals = MyGlobals._internal();
  static GlobalKey _scaffoldKey = GlobalKey();

  static GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  factory MyGlobals() {
    return _myGlobals;
  }

  GlobalKey get scaffoldKey => _scaffoldKey;

  GlobalKey get navigationKey => _navKey;
}
