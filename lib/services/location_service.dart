import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  UserLocation? _currentLocation;

  Location location = Location();

  Future<UserLocation?> getLocation() async {
    LocationData? userLocation;
    try {
      userLocation = await fetchLocation();
      if (userLocation != null) {
        _currentLocation = UserLocation(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
        );

        return _currentLocation;
      }
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
    return null;
  }

  Future<UserLocation?> getLocationEndless() async {
    LocationData? userLocation;
    try {
      userLocation = await fetchLocation();
      if (userLocation != null) {
        _currentLocation = UserLocation(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
        );

        return _currentLocation;
      }
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
    return null;
  }

  Future<LocationData?> fetchLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData currentPosition;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      currentPosition = currentLocation;
    });
    return currentPosition;
  }
}
