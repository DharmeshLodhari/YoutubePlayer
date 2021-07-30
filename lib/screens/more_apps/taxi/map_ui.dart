import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUI extends StatefulWidget {
  MapUI({Key key}) : super(key: key);

  @override
  _MapUIState createState() => _MapUIState();
}

class _MapUIState extends State<MapUI> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);

  GoogleMapController googleMapController;

  Marker _carOneMarker = Marker(
    markerId: MarkerId('Taxi'),
    infoWindow: const InfoWindow(title: 'Taxi'),
    icon: BitmapDescriptor.fromAsset("assets/images/car_top.png"),
    position: LatLng(6.605874, 3.349152),
  );
  Marker _bikeOneMarker = Marker(
    markerId: MarkerId('Bike'),
    infoWindow: const InfoWindow(title: 'Bike'),
    icon: BitmapDescriptor.fromAsset("assets/images/bike_top.png"),
    position: LatLng(6.626400, 3.303030),
  );
  Marker _tricycleOneMarker = Marker(
    markerId: MarkerId('Tricycle'),
    infoWindow: const InfoWindow(title: 'Tricycle'),
    icon: BitmapDescriptor.fromAsset("assets/images/tricycle_top.png"),
    position: LatLng(6.505050, 3.404040),
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      markers: {
        if (_carOneMarker != null) _carOneMarker,
        if (_bikeOneMarker != null) _bikeOneMarker,
        if (_tricycleOneMarker != null) _tricycleOneMarker
      },
    );
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }
}
