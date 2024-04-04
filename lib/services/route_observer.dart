import 'package:Slydo/services/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyRouteObserver extends RouteObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    final RouteProvider routeProvider =
        Provider.of<RouteProvider>(route.navigator!.context, listen: false);

    routeProvider.removeRoute(name: route.settings.name);

    debugPrint(
        "POP: (Popped => Previous) ${route.settings.name} => ${previousRoute?.settings.name}"); // note : take route name in stacks below
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final RouteProvider routeProvider =
        Provider.of<RouteProvider>(route.navigator!.context, listen: false);

    routeProvider.addRoute(name: route.settings.name);
    debugPrint(
        "PUSH: (Previous => New) ${previousRoute?.settings.name} => ${route.settings.name}"); // note : take new route name that just pushed
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // debugPrint(
    //     "Route REMOVE :-- ${previousRoute?.settings?.name}  ${route?.settings?.name} ");
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint(
        "Route REPLACE :--${oldRoute?.settings.name}  ${newRoute?.settings.name} ");
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
