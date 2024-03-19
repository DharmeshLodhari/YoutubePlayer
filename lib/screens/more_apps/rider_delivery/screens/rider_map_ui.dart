import 'dart:async';
import 'dart:typed_data';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RiderMapUI extends StatefulWidget {
  RiderMapUI({
    Key? key,
    this.deliveryDetails,
    this.showRideToStartingPointPolyline = false,
    this.showStartingPointToDestinationPolyline = false,
    this.startRide = false,
  }) : super(key: key);

  final DeliveryModel? deliveryDetails;
  final bool showStartingPointToDestinationPolyline;
  final bool showRideToStartingPointPolyline;
  final bool startRide;

  @override
  _RiderMapUIState createState() => _RiderMapUIState();
}

class _RiderMapUIState extends State<RiderMapUI> {
  late CameraPosition _initialCameraPosition;

  GoogleMapController? googleMapController;

  // Marker? _rideMarker;
  Marker? _startingLocation;
  Marker? _destinationLocation;
  late RiderDeliveryBloc riderDeliveryBloc;

  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  Marker? _riderMarker;
  Circle? _rideAccuracyCircle;

  String rideMarkerImage = "assets/images/bike_top.png";

  @override
  void initState() {
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    _initialCameraPosition =
        CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 14);

    _startingLocation = Marker(
      markerId: MarkerId('Starting Point'),
      infoWindow: const InfoWindow(title: 'Pickup Point'),
      icon: BitmapDescriptor.defaultMarkerWithHue(0),
      position: LatLng(
        widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
        widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
      ),
    );
    _destinationLocation = Marker(
      markerId: MarkerId('Destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(250),
      position: LatLng(
        widget.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
        widget.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
      ),
    );

    // if (riderDeliveryBloc.rideDetail != null) {
    //   // BitmapDescriptor pin;
    //   // String markerName;
    //   //
    //   if (riderDeliveryBloc.rideDetail!["name"] == "Bike" ||
    //       riderDeliveryBloc.rideDetail!["name"] == "Tricycle") {
    //     if (riderDeliveryBloc.rideDetail!["name"] == "Bike") {
    //       //     pin = BitmapDescriptor.fromAsset("assets/images/bike_top.png");
    //       rideMarkerImage = "assets/images/bike_top.png";
    //       //     markerName = "Bike";
    //     } else {
    //       //     pin = BitmapDescriptor.fromAsset("assets/images/tricycle_top.png");
    //       rideMarkerImage = "assets/images/tricycle_top.png";
    //       //     markerName = "Tricycle";
    //     }
    //   } else {
    //     //   pin = BitmapDescriptor.fromAsset("assets/images/car_top.png");
    //     rideMarkerImage = "assets/images/car_top.png";
    //     //   markerName = "Taxi";
    //   }
    //
    //   // _rideMarker = Marker(
    //   //   markerId: MarkerId(markerName),
    //   //   infoWindow: const InfoWindow(title: "Taxi"),
    //   //   icon: pin,
    //   //   position: LatLng(riderDeliveryBloc.startingPoint.geometry.location.lat - 0.0015,
    //   //       riderDeliveryBloc.startingPoint.geometry.location.lng),
    //   // );
    // }

    if (widget.showStartingPointToDestinationPolyline) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(
            widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
            widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
          ),
          zoom: 10);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          if (mounted) {
            googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
                LatLngBounds(
                    southwest: LatLng(
                      widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
                      widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
                    ),
                    northeast: LatLng(
                      widget.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
                      widget.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
                    )),
                50));
          }
        });
      });
    }

    // if (widget.showRideToStartingPointPolyline) {
    // _initialCameraPosition = CameraPosition(
    //     target: LatLng(
    //       widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
    //       widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
    //     ),
    //     zoom: 13);
    // }

    if (widget.startRide) {
      debugPrint("====>startRide ${widget.startRide}");
      getCurrentLocation();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      markers: getMarkers(),
      polylines: getPolylines(),
      circles: getCircles(),
    );
  }

  Set<Marker> getMarkers() {
    return {
      // if (_rideMarker != null) _rideMarker!,
      if (_startingLocation != null) _startingLocation!,
      if (_destinationLocation != null) _destinationLocation!,
      if (_riderMarker != null) _riderMarker!,
    };
  }

  Set<Circle> getCircles() {
    return {
      if (_rideAccuracyCircle != null) _rideAccuracyCircle!,
    };
  }

  Set<Polyline> getPolylines() {
    return {
      if (riderDeliveryBloc.startingPointToDestinationDirections != null &&
          widget.showStartingPointToDestinationPolyline)
        Polyline(
          polylineId: PolylineId('startingPointToDestination'),
          color: navyBlue,
          width: 5,
          points: riderDeliveryBloc
              .startingPointToDestinationDirections!.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      //   if (riderDeliveryBloc.driverToStartingPointDirections != null &&
      //           widget.showRideToStartingPointPolyline)
      //     Polyline(
      //       polylineId: PolylineId('driverToStartingPoint'),
      //       color: naturalGreen,
      //       width: 5,
      //       points: riderDeliveryBloc
      //           .driverToStartingPointDirections!.polylinePoints
      //           .map((e) => LatLng(e.latitude, e.longitude))
      //           .toList(),
      //     ),
    };
  }

  Future<Uint8List> getRiderMarker() async {
    debugPrint("rider => $rideMarkerImage");
    ByteData byteData =
        await DefaultAssetBundle.of(context).load(rideMarkerImage);
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    this.setState(() {
      _riderMarker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading! + 40,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData),
      );
      _rideAccuracyCircle = Circle(
        circleId: CircleId("car"),
        radius: newLocalData.accuracy!,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getRiderMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        debugPrint("==>altitude ${newLocalData.altitude}");
        debugPrint("==>latitude ${newLocalData.latitude}");
        debugPrint("==>longitude ${newLocalData.longitude}");
        debugPrint("==>heading ${newLocalData.heading}");

        if (googleMapController != null) {
          googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: newLocalData.heading!,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  zoom: 14.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    googleMapController?.dispose();

    if (_locationSubscription != null) {
      _locationSubscription?.cancel();
    }
    super.dispose();
  }
}
