import 'package:Slydo/screens/more_apps/taxi/model/DirectionsModal.dart';
import 'package:flutter/material.dart';

class RiderDeliveryBloc extends ChangeNotifier {
  Directions? _driverToStartingPointDirections;

  Directions? get driverToStartingPointDirections =>
      _driverToStartingPointDirections;

  set driverToStartingPointDirections(Directions? value) {
    _driverToStartingPointDirections = value;
    notifyListeners();
  }
}
