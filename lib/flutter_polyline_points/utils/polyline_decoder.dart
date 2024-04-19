import 'package:Slydo/flutter_polyline_points/PointLatLng.dart';

/// Decode the google encoded string using Encoded Polyline Algorithm Format
/// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
class PolylineDecoder {
  static List<PointLatLng> run(String encoded) {
    final List<PointLatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;
    final BigInt big0 = BigInt.from(0);
    final BigInt big0x1f = BigInt.from(0x1f);
    final BigInt big0x20 = BigInt.from(0x20);

    while (index < len) {
      int shift = 0;
      BigInt b, result;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      BigInt rShifted = result >> 1;
      int dLat;
      if (result.isOdd)
        dLat = (~rShifted).toInt();
      else
        dLat = rShifted.toInt();
      lat += dLat;

      shift = 0;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      rShifted = result >> 1;
      int dLng;
      if (result.isOdd)
        dLng = (~rShifted).toInt();
      else
        dLng = rShifted.toInt();
      lng += dLng;

      points.add(PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }

    return points;
  }
}
