import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  UserLocation? _currentLocation;

  var location = Location();

  Future<UserLocation?> getLocation() async {
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

  Future<UserLocation?> getLocationEndless() async {
    var userLocation;
    try {
      var error = "";
      ph.PermissionStatus permissionStatus =
          await ph.Permission.location.request();

      if (permissionStatus == ph.PermissionStatus.granted) {
        userLocation = await location.getLocation();
      } else {
        error = 'permission denied - please enable it from app settings';
        throw error;
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
    _currentLocation = UserLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
    );

    return _currentLocation;
  }
}
