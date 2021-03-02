import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/route_provider.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListRefresher {
  Duration _refreshDurationInterval = Duration(seconds: 5);
  Timer _timerForListRefresher;

  void initialize() {
    // if (_timerForListRefresher?.isActive ?? false) {
    //   _timerForListRefresher.cancel();
    // }
    try {
      _timerForListRefresher = Timer(_refreshDurationInterval, () {
        debugPrint("<====== Refreshing ======>");
        // _timerForListRefresher.cancel();
        RouteProvider routeProvider = Provider.of<RouteProvider>(
            myGlobals.scaffoldKey.currentContext,
            listen: false);
        debugPrint("RouteProvider routes ${routeProvider.routes}");
        debugPrint("==> ${routeProvider.routes.contains("/dashboard")}");
        if (routeProvider.routes.contains("/dashboard")) {
          RefreshBlocForRequestPayment refreshBlocForRequestPayment =
              Provider.of<RefreshBlocForRequestPayment>(
                  myGlobals.scaffoldKey.currentContext,
                  listen: false);
          refreshBlocForRequestPayment.isRefresh = true;
        }
      });
    } catch (e) {
      debugPrint("ERROR:_ $e");
    }
  }
}
