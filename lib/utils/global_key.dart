import 'package:flutter/material.dart';

MyGlobals myGlobals = MyGlobals();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}
