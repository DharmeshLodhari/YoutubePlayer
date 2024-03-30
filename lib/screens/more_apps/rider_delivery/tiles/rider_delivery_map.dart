import 'dart:async';
import 'dart:typed_data';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RiderDeliveryMap extends StatefulWidget {
  RiderDeliveryMap({
    super.key,
    // this.deliveryDetails,
    // this.showRideToStartingPointPolyline = false,
    // this.showStartingPointToDestinationPolyline = false,
  });

  // final DeliveryModel? deliveryDetails;
  // final bool showStartingPointToDestinationPolyline;
  // final bool showRideToStartingPointPolyline;

  @override
  _RiderDeliveryMapState createState() => _RiderDeliveryMapState();
}

class _RiderDeliveryMapState extends State<RiderDeliveryMap> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  // static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LocationData? _currentP;
  String rideMarkerImage = "assets/images/bike_top.png";
  GoogleMapController? controller;

  Map<PolylineId, Polyline> polylines = {};
  Uint8List? _markerImageData;
  Location _locationTracker = Location();
  late LocationData localData;

  late UserBloc userBloc;
  late RiderDeliveryBloc riderDeliveryBloc;
  String? username;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      _markerImageData = await getMarkerImage();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      username = userBloc.user.userName;

      localData = await getCurrentLocation();
      _currentP = localData;

      getPolylinePoints().then((coordinates) => {
            generatePolyLineFromPoints(coordinates),
          });

      getLocationUpdates().then(
        (_) => {
          getPolylinePoints().then((coordinates) => {
                generatePolyLineFromPoints(coordinates),
              }),
        },
      );
    });
  }

  Future<LocationData> getCurrentLocation() async {
    LocationData location = await _locationTracker.getLocation();
    return location;
  }

  Future<Uint8List> getRiderMarker() async {
    debugPrint("rider => $rideMarkerImage");
    ByteData byteData =
        await DefaultAssetBundle.of(context).load(rideMarkerImage);
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getMarkerImage() async {
    Uint8List imageData = await getRiderMarker();
    return imageData;
  }

  Marker _buildRiderMarker() {
    return Marker(
      markerId: MarkerId("_currentLocation"),
      icon: BitmapDescriptor.fromBytes(_markerImageData!),
      rotation: _currentP?.heading ?? 0,
      position: LatLng(_currentP!.latitude!, _currentP!.longitude!),
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context, listen: false);
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    return Scaffold(
      // body: _buildShowRoute(),
      body: _currentP == null
          ? const Center(
              child: Text("Loading..."),
            )
          : _buildShowRoute(),
    );
  }

  Widget _buildShowRoute() {
    DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    if (deliveryModel?.isOfferAccepted(username) == false) {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
                    deliveryModel?.pickupAddress?.longitude ?? 0.0),
                zoom: 13,
              ),
              markers: {
                if (_currentP != null && _markerImageData != null)
                  _buildRiderMarker(),
                Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(0),
                    position: LatLng(
                        deliveryModel?.pickupAddress?.latitude ?? 0.0,
                        deliveryModel?.pickupAddress?.longitude ?? 0.0)),
                Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(250),
                    position: LatLng(
                        riderDeliveryBloc
                                .deliveryDetails?.deliveryAddress?.latitude ??
                            0.0,
                        riderDeliveryBloc
                                .deliveryDetails?.deliveryAddress?.longitude ??
                            0.0))
              },
              polylines: Set<Polyline>.of(polylines.values),
            );
    } else if (deliveryModel?.isAfterOfferAccepted(username) == true) {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
                    deliveryModel?.pickupAddress?.longitude ?? 0.0),
                zoom: 13,
              ),
              markers: {
                if (_currentP != null && _markerImageData != null)
                  _buildRiderMarker(),
                Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(0),
                    position: LatLng(
                        deliveryModel?.pickupAddress?.latitude ?? 0.0,
                        deliveryModel?.pickupAddress?.longitude ?? 0.0)),
              },
              polylines: Set<Polyline>.of(polylines.values),
            );
    } else if (deliveryModel?.isOfferStarted(username) == true) {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
                    deliveryModel?.pickupAddress?.longitude ?? 0.0),
                zoom: 13,
              ),
              markers: {
                if (_currentP != null && _markerImageData != null)
                  _buildRiderMarker(),
                Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(0),
                    position: LatLng(
                        deliveryModel?.pickupAddress?.latitude ?? 0.0,
                        deliveryModel?.pickupAddress?.longitude ?? 0.0)),
                Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(250),
                    position: LatLng(
                        deliveryModel?.deliveryAddress?.latitude ?? 0.0,
                        deliveryModel?.deliveryAddress?.longitude ?? 0.0))
              },
              polylines: Set<Polyline>.of(polylines.values),
            );
    } else if (deliveryModel?.isOfferEnded(username) == true) {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
                    deliveryModel?.pickupAddress?.longitude ?? 0.0),
                zoom: 13,
              ),
              markers: {
                if (_currentP != null && _markerImageData != null)
                  _buildRiderMarker(),
                Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(250),
                    position: LatLng(
                        deliveryModel?.deliveryAddress?.latitude ?? 0.0,
                        deliveryModel?.deliveryAddress?.longitude ?? 0.0))
              },
              polylines: Set<Polyline>.of(polylines.values),
            );
    } else {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
                    deliveryModel?.pickupAddress?.longitude ?? 0.0),
                zoom: 13,
              ),
              markers: {
                if (_currentP != null && _markerImageData != null)
                  _buildRiderMarker(),
                Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(0),
                    position: LatLng(
                        deliveryModel?.pickupAddress?.latitude ?? 0.0,
                        deliveryModel?.pickupAddress?.longitude ?? 0.0)),
                Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(250),
                    position: LatLng(
                        deliveryModel?.deliveryAddress?.latitude ?? 0.0,
                        deliveryModel?.deliveryAddress?.longitude ?? 0.0))
              },
              polylines: Set<Polyline>.of(polylines.values),
            );
    }
  }

  Future<void> _cameraToPosition(LocationData pos) async {
    controller = await _mapController.future;
    double zoomLevel = await controller?.getZoomLevel() ?? 13;
    CameraPosition _newCameraPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: zoomLevel,
    );
    await controller?.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        if (mounted)
          setState(() {
            _currentP = currentLocation;

            _cameraToPosition(currentLocation);
            if (riderDeliveryBloc.deliveryDetails?.isOfferStarted(username) ==
                    true ||
                riderDeliveryBloc.deliveryDetails
                        ?.isAfterOfferAccepted(username) ==
                    true) {
              updateCurrentLocation(currentLocation);
            }
          });
      }
    });
  }

  Future<void> updateCurrentLocation(LocationData currentP) async {
    if (riderDeliveryBloc.deliveryDetails?.isOfferStarted(username) ?? false) {
      await RiderDeliveryAuthService()
          .updateCurrentLocation(
              riderDeliveryBloc.deliveryDetails?.id, currentP)
          .then((value) {
        if (value == true) {
          print('Location updated successfully in the background');
        }
      }).catchError((error) {
        debugPrint(error.toString());
      });
    }
  }

  Future<List<LatLng>> getPolylinePoints() async {
    DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = PolylineResult();

    if (deliveryModel?.isOfferAccepted(username) == false) {
      result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAPS_API_KEY,
        PointLatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
            deliveryModel?.pickupAddress?.longitude ?? 0.0),
        PointLatLng(deliveryModel?.deliveryAddress?.latitude ?? 0.0,
            deliveryModel?.deliveryAddress?.longitude ?? 0.0),
        travelMode: TravelMode.driving,
      );
    } else if (deliveryModel?.isAfterOfferAccepted(username) == true) {
      result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAPS_API_KEY,
        PointLatLng(localData.latitude!, localData.longitude!),
        PointLatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
            deliveryModel?.pickupAddress?.longitude ?? 0.0),
        travelMode: TravelMode.driving,
      );
    } else if (deliveryModel?.isOfferStarted(username) == true) {
      result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAPS_API_KEY,
        PointLatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
            deliveryModel?.pickupAddress?.longitude ?? 0.0),
        PointLatLng(deliveryModel?.deliveryAddress?.latitude ?? 0.0,
            deliveryModel?.deliveryAddress?.longitude ?? 0.0),
        travelMode: TravelMode.driving,
      );
    }
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: naturalGreen,
        points: polylineCoordinates,
        width: 8);
    if (mounted)
      setState(() {
        polylines[id] = polyline;
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  // late CameraPosition _initialCameraPosition;
  //
  // GoogleMapController? googleMapController;
  // bool? startRide = false;
  //
  // // Marker? _rideMarker;
  // Marker? _startingLocation;
  // Marker? _destinationLocation;
  // // late UserBloc userBloc;
  // late RiderDeliveryBloc riderDeliveryBloc;
  //
  // StreamSubscription? _locationSubscription;
  // Location _locationTracker = Location();
  // Marker? _riderMarker;
  // Circle? _rideAccuracyCircle;
  // // String? username;
  //
  // String rideMarkerImage = "assets/images/bike_top.png";
  //
  // // @override
  // // void initState() {
  // // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  // //   username = userBloc.user.userName;
  // //
  // //   if (widget.deliveryDetails?.isOfferAccepted(username) == false) {
  // //     startRide = false;
  // //   }
  // //
  // //   if (widget.deliveryDetails?.isOfferAccepted(username) == true) {
  // //     if (startRide == true) {
  // //       debugPrint("====>startRide ${startRide}");
  // //       getCurrentLocation();
  // //     }
  // //   }
  // // });
  // //
  // // if (riderDeliveryBloc.rideDetail != null) {
  // //   // BitmapDescriptor pin;
  // //   // String markerName;
  // //   //
  // //   if (riderDeliveryBloc.rideDetail!["name"] == "Bike" ||
  // //       riderDeliveryBloc.rideDetail!["name"] == "Tricycle") {
  // //     if (riderDeliveryBloc.rideDetail!["name"] == "Bike") {
  // //       //     pin = BitmapDescriptor.fromAsset("assets/images/bike_top.png");
  // //       rideMarkerImage = "assets/images/bike_top.png";
  // //       //     markerName = "Bike";
  // //     } else {
  // //       //     pin = BitmapDescriptor.fromAsset("assets/images/tricycle_top.png");
  // //       rideMarkerImage = "assets/images/tricycle_top.png";
  // //       //     markerName = "Tricycle";
  // //     }
  // //   } else {
  // //     //   pin = BitmapDescriptor.fromAsset("assets/images/car_top.png");
  // //     rideMarkerImage = "assets/images/car_top.png";
  // //     //   markerName = "Taxi";
  // //   }
  // //
  // //   // _rideMarker = Marker(
  // //   //   markerId: MarkerId(markerName),
  // //   //   infoWindow: const InfoWindow(title: "Taxi"),
  // //   //   icon: pin,
  // //   //   position: LatLng(riderDeliveryBloc.startingPoint.geometry.location.lat - 0.0015,
  // //   //       riderDeliveryBloc.startingPoint.geometry.location.lng),
  // //   // );
  // // }
  // //
  // // if (widget.showStartingPointToDestinationPolyline) {
  // //   _initialCameraPosition = CameraPosition(
  // //       target: LatLng(
  // //         widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
  // //         widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
  // //       ),
  // //       zoom: 10);
  // //
  // //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  // //     Future.delayed(Duration(seconds: 1)).then((value) {
  // //       if (mounted) {
  // //         googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
  // //             LatLngBounds(
  // //                 southwest: LatLng(
  // //                   widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
  // //                   widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
  // //                 ),
  // //                 northeast: LatLng(
  // //                   widget.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
  // //                   widget.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
  // //                 )),
  // //             50));
  // //       }
  // //     });
  // //   });
  // // }
  // //
  // // if (widget.showRideToStartingPointPolyline) {
  // //   _initialCameraPosition = CameraPosition(
  // //       target: LatLng(
  // //         widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
  // //         widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
  // //       ),
  // //       zoom: 13);
  // // }
  // //
  // //   super.initState();
  // // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
  //   // userBloc = Provider.of<UserBloc>(context, listen: false);
  //
  //   // _initialCameraPosition =
  //   //     CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 13);
  //
  //   _initialCameraPosition = CameraPosition(
  //       target: LatLng(
  //         widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
  //         widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
  //       ),
  //       zoom: 13);
  //
  //   _startingLocation = Marker(
  //     markerId: MarkerId('Starting Point'),
  //     infoWindow: const InfoWindow(title: 'Pickup Point'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(0),
  //     position: LatLng(
  //       widget.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
  //       widget.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
  //     ),
  //   );
  //
  //   _destinationLocation = Marker(
  //     markerId: MarkerId('Destination'),
  //     infoWindow: const InfoWindow(title: 'Destination'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(250),
  //     position: LatLng(
  //       widget.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
  //       widget.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
  //     ),
  //   );
  //
  //   return GoogleMap(
  //     initialCameraPosition: _initialCameraPosition,
  //     myLocationButtonEnabled: false,
  //     zoomControlsEnabled: false,
  //     onMapCreated: (controller) {
  //       googleMapController = controller;
  //     },
  //     markers: getMarkers(),
  //     polylines: getPolylines(),
  //     circles: getCircles(),
  //   );
  // }
  //
  // Set<Marker> getMarkers() {
  //   return {
  //     // if (_rideMarker != null) _rideMarker,
  //     if (_startingLocation != null) _startingLocation!,
  //     if (_destinationLocation != null) _destinationLocation!,
  //     if (_riderMarker != null) _riderMarker!,
  //   };
  // }
  //
  // Set<Circle> getCircles() {
  //   return {
  //     if (_rideAccuracyCircle != null) _rideAccuracyCircle!,
  //   };
  // }
  //
  // Set<Polyline> getPolylines() {
  //   return {
  //     // if (riderDeliveryBloc.driverToStartingPointDirections != null &&
  //     //     widget.deliveryDetails?.isOfferAccepted(username) == false)
  //     Polyline(
  //       polylineId: PolylineId('driverToStartingPoint'),
  //       color: naturalGreen,
  //       width: 5,
  //       points: riderDeliveryBloc
  //           .driverToStartingPointDirections!.polylinePoints
  //           .map((e) => LatLng(e.latitude, e.longitude))
  //           .toList(),
  //     ),
  //     // if (riderDeliveryBloc.startingPointToDestinationDirections != null &&
  //     //     widget.deliveryDetails?.isOfferAccepted(username) == true)
  //     //   Polyline(
  //     //     polylineId: PolylineId('startingPointToDestination'),
  //     //     color: navyBlue,
  //     //     width: 5,
  //     //     points: riderDeliveryBloc
  //     //         .startingPointToDestinationDirections!.polylinePoints
  //     //         .map((e) => LatLng(e.latitude, e.longitude))
  //     //         .toList(),
  //     //   ),
  //   };
  // }
  //
  // Future<Uint8List> getRiderMarker() async {
  //   debugPrint("rider => $rideMarkerImage");
  //   ByteData byteData =
  //       await DefaultAssetBundle.of(context).load(rideMarkerImage);
  //   return byteData.buffer.asUint8List();
  // }
  //
  // void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
  //   LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
  //   this.setState(() {
  //     _riderMarker = Marker(
  //         markerId: MarkerId("home"),
  //         position: latlng,
  //         rotation: newLocalData.heading! + 40,
  //         draggable: false,
  //         zIndex: 2,
  //         flat: true,
  //         anchor: Offset(0.5, 0.5),
  //         icon: BitmapDescriptor.fromBytes(imageData));
  //     _rideAccuracyCircle = Circle(
  //         circleId: CircleId("car"),
  //         radius: newLocalData.accuracy!,
  //         zIndex: 1,
  //         strokeColor: Colors.blue,
  //         center: latlng,
  //         fillColor: Colors.blue.withAlpha(70));
  //   });
  // }
  //
  // void getCurrentLocation() async {
  //   try {
  //     Uint8List imageData = await getRiderMarker();
  //     var location = await _locationTracker.getLocation();
  //
  //     updateMarkerAndCircle(location, imageData);
  //
  //     if (_locationSubscription != null) {
  //       _locationSubscription!.cancel();
  //     }
  //
  //     _locationSubscription =
  //         _locationTracker.onLocationChanged.listen((newLocalData) {
  //       debugPrint("==>altitude ${newLocalData.altitude}");
  //       debugPrint("==>latitude ${newLocalData.latitude}");
  //       debugPrint("==>longitude ${newLocalData.longitude}");
  //       debugPrint("==>heading ${newLocalData.heading}");
  //
  //       if (googleMapController != null) {
  //         googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
  //             new CameraPosition(
  //                 bearing: newLocalData.heading!,
  //                 target:
  //                     LatLng(newLocalData.latitude!, newLocalData.longitude!),
  //                 zoom: 14.00)));
  //         updateMarkerAndCircle(newLocalData, imageData);
  //       }
  //     });
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       debugPrint("Permission Denied");
  //     }
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   googleMapController?.dispose();
  //
  //   if (_locationSubscription != null) {
  //     _locationSubscription?.cancel();
  //   }
  //   super.dispose();
  // }
}
