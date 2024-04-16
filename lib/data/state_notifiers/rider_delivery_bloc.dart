import 'dart:async';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/near_by_location.dart';
import 'package:Slydo/screens/more_apps/taxi/model/DirectionsModal.dart';
import 'package:flutter/material.dart';

class RiderDeliveryBloc extends ChangeNotifier {
  DeliveryModel? deliveryDetails;

  Directions? _driverToStartingPointDirections;

  Directions? _startingPointToDestinationDirections;

  Directions? get driverToStartingPointDirections =>
      _driverToStartingPointDirections;

  set driverToStartingPointDirections(Directions? value) {
    _driverToStartingPointDirections = value;
    notifyListeners();
  }

  Directions? get startingPointToDestinationDirections =>
      _startingPointToDestinationDirections;

  set startingPointToDestinationDirections(Directions? value) {
    _startingPointToDestinationDirections = value;
    notifyListeners();
  }

  bool isNearbyPickupLocation = false;
  bool isNearbyDestinationLocation = false;

  void isRiderNearbyPickupLocation(bool value) {
    isNearbyPickupLocation = value;
    notifyListeners();
  }

  void isRiderNearbyDestinationLocation(bool value) {
    isNearbyDestinationLocation = value;
    notifyListeners();
  }

  Future<void> updateDeliveryModel(DeliveryModel data) async {
    deliveryDetails = data;
    NearByLocation? rideAtLocation =
        await DatabaseHelper().getRiderAtLocation(data.orderId);
    deliveryDetails?.riderAtLocation = rideAtLocation;
    notifyListeners();
  }

  Future<DeliveryModel> refreshJobDetail(String? journeyId) async {
    DeliveryModel deliveryModel = await getJobDetail(journeyId);
    notifyListeners();
    return deliveryModel;
  }

  getJobDetail(String? journeyId) async {
    await RiderDeliveryAuthService().fetchJob(journeyId).then((value) {
      if (value != null) {
        updateDeliveryModel(value);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }
}
