import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  UserLocation? _currentLocation;

  Location location = Location();

  Future<UserLocation?> getLocation() async {
    LocationData userLocation;
    try {
      userLocation = await fetchLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );

      return _currentLocation;
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
  }

  Future<UserLocation?> getLocationEndless() async {
    LocationData userLocation;
    try {
      userLocation = await fetchLocation();

      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );

      return _currentLocation;
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
  }

  fetchLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _currentPosition;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      _currentPosition = currentLocation;
    });
    return _currentPosition;
  }
}
