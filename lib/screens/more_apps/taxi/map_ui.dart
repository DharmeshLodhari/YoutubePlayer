import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapUI extends StatefulWidget {
  MapUI({
    Key key,
    this.showRideToStartingPointPolyline = false,
    this.showStartingPointToDestinationPolyline = false,
  }) : super(key: key);

  final bool showStartingPointToDestinationPolyline;
  final bool showRideToStartingPointPolyline;

  @override
  _MapUIState createState() => _MapUIState();
}

class _MapUIState extends State<MapUI> {
  CameraPosition _initialCameraPosition;

  GoogleMapController googleMapController;

  Marker _rideMarker;
  Marker _startingLocation;
  Marker _destinationLocation;
  TaxiBloc taxiBloc;

  @override
  void initState() {
    TaxiBloc taxiBloc = Provider.of<TaxiBloc>(
        myGlobals.navigationKey.currentContext,
        listen: false);

    _initialCameraPosition =
        CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);

    if (taxiBloc.startingPoint != null) {
      _startingLocation = Marker(
        markerId: MarkerId('Starting Point'),
        infoWindow: const InfoWindow(title: 'Pickup Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(0),
        position: LatLng(taxiBloc.startingPoint.geometry.location.lat,
            taxiBloc.startingPoint.geometry.location.lng),
      );
    }
    if (taxiBloc.destinationPoint != null) {
      _destinationLocation = Marker(
        markerId: MarkerId('Destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(250),
        position: LatLng(taxiBloc.destinationPoint.geometry.location.lat,
            taxiBloc.destinationPoint.geometry.location.lng),
      );
    }

    if (taxiBloc.rideDetail != null) {
      BitmapDescriptor pin;
      String markerName;

      if (taxiBloc.rideDetail["name"] == "Bike" ||
          taxiBloc.rideDetail["name"] == "Tricycle") {
        if (taxiBloc.rideDetail["name"] == "Bike") {
          pin = BitmapDescriptor.fromAsset("assets/images/bike_top.png");
          markerName = "Bike";
        } else {
          pin = BitmapDescriptor.fromAsset("assets/images/tricycle_top.png");
          markerName = "Tricycle";
        }
      } else {
        pin = BitmapDescriptor.fromAsset("assets/images/car_top.png");
        markerName = "Taxi";
      }

      _rideMarker = Marker(
        markerId: MarkerId(markerName),
        infoWindow: const InfoWindow(title: "Taxi"),
        icon: pin,
        position: LatLng(taxiBloc.startingPoint.geometry.location.lat - 0.0015,
            taxiBloc.startingPoint.geometry.location.lng),
      );
    }

    if (widget.showStartingPointToDestinationPolyline) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(taxiBloc.startingPoint.geometry.location.lat,
              taxiBloc.startingPoint.geometry.location.lng),
          zoom: 14.5);
    }

    if (widget.showRideToStartingPointPolyline) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(taxiBloc.startingPoint.geometry.location.lat - 0.0015,
              taxiBloc.startingPoint.geometry.location.lng),
          zoom: 17,
          bearing: 100);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    taxiBloc = Provider.of<TaxiBloc>(context);
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      markers: getMarkers(),
      polylines: getPolylines(),
    );
  }

  Set<Marker> getMarkers() {
    return {
      if (_rideMarker != null) _rideMarker,
      if (_startingLocation != null) _startingLocation,
      if (_destinationLocation != null) _destinationLocation,
    };
  }

  Set<Polyline> getPolylines() {
    return {
      if (taxiBloc.startingPointToDestinationDirections != null &&
          widget.showStartingPointToDestinationPolyline)
        Polyline(
          polylineId: PolylineId('startingPointToDestination'),
          color: navyBlue,
          width: 5,
          points: taxiBloc.startingPointToDestinationDirections.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      if (taxiBloc.driverToStartingPointDirections != null &&
          widget.showRideToStartingPointPolyline)
        Polyline(
          polylineId: PolylineId('driverToStartingPoint'),
          color: naturalGreen,
          width: 5,
          points: taxiBloc.driverToStartingPointDirections.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
    };
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }
}
