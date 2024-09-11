import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const String GOOGLE_MAPS_API_KEY = "AIzaSyAs0AD96236ASgq_7l8u4q9OHW0bOuESV8";

// Function to calculate distance between two LatLng points for a given radius
double distanceBetween(LocationData pos1, LatLng pos2) {
  const double radius = 6371000; // Earth's radius in meters
  final double lat1 = pos1.latitude! * (3.141592653589793 / 180);
  final double lon1 = pos1.longitude! * (3.141592653589793 / 180);
  final double lat2 = pos2.latitude * (3.141592653589793 / 180);
  final double lon2 = pos2.longitude * (3.141592653589793 / 180);
  final double dLat = lat2 - lat1;
  final double dLon = lon2 - lon1;
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distance = radius * c;
  return distance;
}
