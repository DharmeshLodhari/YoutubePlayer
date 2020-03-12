import 'package:Slydo/models/user.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  UserLocation _currentLocation;

  var location = Location();

//  Future<UserLocation> getLocation() async {
//    try {
//      var userLocation = await location.getLocation();
//      _currentLocation = UserLocation(
//        latitude: userLocation.latitude,
//        longitude: userLocation.longitude,
//      );
//
//    } on Exception catch (e) {
//      print('Could not get location: ${e.toString()}');
//    }
//
//    return _currentLocation;
//  }

  Future<UserLocation> getLocation() async {
    var userLocation;
    try {
      userLocation = await location.getLocation();
    } on PlatformException catch (e) {
      var error = "";
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant location permission';
        throw error;
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied - please enable it from app settings';
        throw error;
      } else {
        error = "Something went wrong";
        throw error;
      }
    }
    _currentLocation = UserLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
    );

    return _currentLocation;
  }
}
