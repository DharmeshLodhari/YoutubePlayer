import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class MapUI extends StatefulWidget {
  const MapUI({
    super.key,
    this.showRideToStartingPointPolyline = false,
    this.showStartingPointToDestinationPolyline = false,
    this.startRide = false,
  });

  final bool showStartingPointToDestinationPolyline;
  final bool showRideToStartingPointPolyline;
  final bool startRide;

  @override
  State<MapUI> createState() => _MapUIState();
}

class _MapUIState extends State<MapUI> {
  late CameraPosition _initialCameraPosition;

  GoogleMapController? googleMapController;

  Marker? _rideMarker;
  Marker? _startingLocation;
  Marker? _destinationLocation;
  late TaxiBloc taxiBloc;

  StreamSubscription? _locationSubscription;
  final Location _locationTracker = Location();
  Marker? _riderMarker;
  Circle? _rideAccuracyCircle;

  String rideMarkerImage = "assets/images/car_top.png";

  @override
  void initState() {
    final TaxiBloc taxiBloc = Provider.of<TaxiBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    _initialCameraPosition =
        const CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);

    if (taxiBloc.startingPoint != null) {
      _startingLocation = Marker(
        markerId: const MarkerId('Starting Point'),
        infoWindow: const InfoWindow(title: 'Pickup Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(0),
        position: LatLng(taxiBloc.startingPoint!.geometry!.location!.lat!,
            taxiBloc.startingPoint!.geometry!.location!.lng!),
      );
    }
    if (taxiBloc.destinationPoint != null) {
      _destinationLocation = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(250),
        position: LatLng(taxiBloc.destinationPoint!.geometry!.location!.lat!,
            taxiBloc.destinationPoint!.geometry!.location!.lng!),
      );
    }

    if (taxiBloc.rideDetail != null) {
      // BitmapDescriptor pin;
      // String markerName;
      //
      if (taxiBloc.rideDetail!["name"] == "Bike" ||
          taxiBloc.rideDetail!["name"] == "Tricycle") {
        if (taxiBloc.rideDetail!["name"] == "Bike") {
          //     pin = BitmapDescriptor.fromAsset("assets/images/bike_top.png");
          rideMarkerImage = "assets/images/bike_top.png";
          //     markerName = "Bike";
        } else {
          //     pin = BitmapDescriptor.fromAsset("assets/images/tricycle_top.png");
          rideMarkerImage = "assets/images/tricycle_top.png";
          //     markerName = "Tricycle";
        }
      } else {
        //   pin = BitmapDescriptor.fromAsset("assets/images/car_top.png");
        rideMarkerImage = "assets/images/car_top.png";
        //   markerName = "Taxi";
      }

      // _rideMarker = Marker(
      //   markerId: MarkerId(markerName),
      //   infoWindow: const InfoWindow(title: "Taxi"),
      //   icon: pin,
      //   position: LatLng(taxiBloc.startingPoint.geometry.location.lat - 0.0015,
      //       taxiBloc.startingPoint.geometry.location.lng),
      // );
    }

    if (widget.showStartingPointToDestinationPolyline) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(taxiBloc.startingPoint!.geometry!.location!.lat!,
              taxiBloc.startingPoint!.geometry!.location!.lng!),
          zoom: 14.5);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          if (mounted) {
            googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
                LatLngBounds(
                    southwest: LatLng(
                        taxiBloc.startingPoint!.geometry!.location!.lat!,
                        taxiBloc.startingPoint!.geometry!.location!.lng!),
                    northeast: LatLng(
                        taxiBloc.destinationPoint!.geometry!.location!.lat!,
                        taxiBloc.destinationPoint!.geometry!.location!.lng!)),
                50));
          }
        });
      });
    }

    if (widget.showRideToStartingPointPolyline) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(
              taxiBloc.startingPoint!.geometry!.location!.lat! - 0.0015,
              taxiBloc.startingPoint!.geometry!.location!.lng!),
          zoom: 14);
    }

    if (widget.startRide) {
      debugPrint("====>startRide ${widget.startRide}");
      getCurrentLocation();
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
      markers: getMarkers() as Set<Marker>,
      polylines: getPolylines(),
      circles: getCircles() as Set<Circle>,
    );
  }

  Set<Marker?> getMarkers() {
    return {
      if (_rideMarker != null) _rideMarker,
      if (_startingLocation != null) _startingLocation,
      if (_destinationLocation != null) _destinationLocation,
      if (_riderMarker != null) _riderMarker,
    };
  }

  Set<Circle?> getCircles() {
    return {
      if (_rideAccuracyCircle != null) _rideAccuracyCircle,
    };
  }

  Set<Polyline> getPolylines() {
    return {
      if (taxiBloc.startingPointToDestinationDirections != null &&
          widget.showStartingPointToDestinationPolyline)
        Polyline(
          polylineId: const PolylineId('startingPointToDestination'),
          color: navyBlue,
          width: 5,
          points: taxiBloc.startingPointToDestinationDirections!.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      // if (taxiBloc.driverToStartingPointDirections != null &&
      //     widget.showRideToStartingPointPolyline)
      //   Polyline(
      //     polylineId: PolylineId('driverToStartingPoint'),
      //     color: naturalGreen,
      //     width: 5,
      //     points: taxiBloc.driverToStartingPointDirections.polylinePoints
      //         .map((e) => LatLng(e.latitude, e.longitude))
      //         .toList(),
      //   ),
    };
  }

  Future<Uint8List> getRiderMarker() async {
    debugPrint("rider => $rideMarkerImage");
    final ByteData byteData =
        await DefaultAssetBundle.of(context).load(rideMarkerImage);
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    final LatLng latlng =
        LatLng(newLocalData.latitude!, newLocalData.longitude!);
    setState(() {
      _riderMarker = Marker(
          markerId: const MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading! + 40,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      _rideAccuracyCircle = Circle(
          circleId: const CircleId("car"),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      final Uint8List imageData = await getRiderMarker();
      final location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        debugPrint("==>altitude ${newLocalData.altitude}");
        debugPrint("==>${newLocalData.latitude}");
        debugPrint("==>heading ${newLocalData.heading}");

        if (googleMapController != null) {
          googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: newLocalData.heading!,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  zoom: 18.00)));
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
