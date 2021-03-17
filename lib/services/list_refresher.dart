import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/route_provider.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListRefresher {
  Duration _refreshDurationInterval = Duration(minutes: 3);
  static Timer _timerForListRefresher;

  void initialize() {
    debugPrint("Refresher initializing");

    if (_timerForListRefresher?.isActive ?? false) {
      _timerForListRefresher.cancel();
    }

    _timerForListRefresher = Timer.periodic(_refreshDurationInterval, (time) {
      if (myGlobals.scaffoldKey.currentContext != null) {
        debugPrint("<====== Refreshing list ======>");
        RouteProvider routeProvider = Provider.of<RouteProvider>(
            myGlobals.scaffoldKey.currentContext,
            listen: false);

        if (routeProvider.routes.contains("/dashboard")) {
          RefreshBlocForRequestPayment refreshBlocForRequestPayment =
              Provider.of<RefreshBlocForRequestPayment>(
                  myGlobals.scaffoldKey.currentContext,
                  listen: false);
          refreshBlocForRequestPayment.isRefresh = true;
        }

        if (routeProvider.routes.contains("/transactions")) {
          RefreshBlocForTransaction refreshBlocForTransaction =
              Provider.of<RefreshBlocForTransaction>(
                  myGlobals.scaffoldKey.currentContext,
                  listen: false);
          refreshBlocForTransaction.isRefresh = true;
        }

        if (routeProvider.routes.contains("/friends-dashboard")) {
          RefreshBlocForConnectionDashboard refreshBlocForConnectionDashboard =
              Provider.of<RefreshBlocForConnectionDashboard>(
                  myGlobals.scaffoldKey.currentContext,
                  listen: false);
          refreshBlocForConnectionDashboard.isRefresh = true;
        }
      }
    });
  }
}
