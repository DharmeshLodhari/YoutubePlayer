import 'package:flutter/cupertino.dart';

class RouteProvider extends ChangeNotifier {
  List<String> _routes = [];

  List<String> get routes => _routes;

  set routes(List<String> value) {
    _routes = value;
    notifyListeners();
  }

  void addRoute({String name}) {
    if (name != null) {
      _routes.add(name);
      debugPrint("Routes:- $_routes");
    }
  }

  void removeRoute({String name}) {
    if (_routes.last == name) _routes.remove(name);
    debugPrint("Routes:- $_routes");
  }
}
