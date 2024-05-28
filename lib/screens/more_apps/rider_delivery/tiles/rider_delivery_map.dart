import 'dart:async';
import 'dart:math' show atan2, cos, sin, sqrt;
import 'dart:typed_data';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/flutter_polyline_points/flutter_polyline_points.dart';
import 'package:Slydo/flutter_polyline_points/utils/polyline_result.dart';
import 'package:Slydo/flutter_polyline_points/utils/request_enums.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  // static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LocationData? _currentP;
  String rideMarkerImage = "assets/images/bike_top.png";
  GoogleMapController? controller;
  Set<Circle> circles = Set();

  Map<PolylineId, Polyline> polylines = {};
  Uint8List? _markerImageData;
  final Location _locationTracker = Location();
  late LocationData? localData;

  late UserBloc userBloc;
  late RiderDeliveryBloc riderDeliveryBloc;
  String? username;
  String? _mapStyle;

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

      enableAGNSS();
      localData = await getCurrentLocation();
      _currentP = localData;

      rootBundle.loadString('assets/map_style.json').then((string) {
        _mapStyle = string;
      });

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

  void enableAGNSS() {
    // Configure A-GNSS settings (specific to the platform)
    // For Android, you might use a method like this:
    _locationTracker.changeSettings(accuracy: LocationAccuracy.navigation);
    // For iOS, A-GNSS is typically enabled by default.
  }

  Future<LocationData?> getCurrentLocation() async {
    LocationData? currentLocation;
    try {
      currentLocation = await _locationTracker.getLocation();
      double? accuracy = currentLocation.accuracy;
      debugPrint('Location Accuracy: $accuracy meters');
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
    // final LocationData location = await _locationTracker.getLocation();
    return currentLocation;
  }

  Future<Uint8List> getRiderMarker() async {
    debugPrint("rider => $rideMarkerImage");
    final ByteData byteData =
        await DefaultAssetBundle.of(context).load(rideMarkerImage);
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getMarkerImage() async {
    final Uint8List imageData = await getRiderMarker();
    return imageData;
  }

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

  Marker _buildRiderMarker() {
    return Marker(
      markerId: const MarkerId("_currentLocation"),
      icon: BitmapDescriptor.fromBytes(_markerImageData!),
      rotation: (_currentP?.heading ?? 0) + 12,
      draggable: false,
      zIndex: 2,
      flat: true,
      position: LatLng(_currentP!.latitude!, _currentP!.longitude!),
      anchor: const Offset(0.5, 0.5),
    );
  }

  Marker _buildPickupMarker() {
    return Marker(
      markerId: const MarkerId("_sourceLocation"),
      icon: BitmapDescriptor.defaultMarkerWithHue(0),
      position: LatLng(
        riderDeliveryBloc.deliveryDetails?.pickupAddress?.latitude ?? 0.0,
        riderDeliveryBloc.deliveryDetails?.pickupAddress?.longitude ?? 0.0,
      ),
    );
  }

  Marker _buildDestinationMarker() {
    return Marker(
      markerId: const MarkerId("_destinationLocation"),
      icon: BitmapDescriptor.defaultMarkerWithHue(250),
      position: LatLng(
        riderDeliveryBloc.deliveryDetails?.deliveryAddress?.latitude ?? 0.0,
        riderDeliveryBloc.deliveryDetails?.deliveryAddress?.longitude ?? 0.0,
      ),
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
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            onMapCreated: ((GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _mapController.complete(controller);
            }),
            initialCameraPosition: _buildInitialCameraPosition(),
            markers: _buildMarkerData(),
            polylines: Set<Polyline>.of(polylines.values),
            circles: {
              if (deliveryModel?.isAfterOfferAccepted(username) == true)
                _buildPickupCircle(),
              if (deliveryModel?.isOfferStarted(username) == true)
                _buildDestinationCircle(),
            },
          );
  }

  CameraPosition _buildInitialCameraPosition() {
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    if (deliveryModel?.isOfferEnded(username) == true) {
      return CameraPosition(
        target: LatLng(deliveryModel?.deliveryAddress?.latitude ?? 0.0,
            deliveryModel?.deliveryAddress?.longitude ?? 0.0),
        zoom: 13,
      );
    } else {
      return CameraPosition(
        target: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
            deliveryModel?.pickupAddress?.longitude ?? 0.0),
        zoom: 13,
      );
    }
  }

  Set<Marker> _buildMarkerData() {
    Set<Marker> marker = <Marker>{};
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    if (deliveryModel?.isOfferAccepted(username) == false) {
      marker = {
        if (_currentP != null && _markerImageData != null) _buildRiderMarker(),
        _buildPickupMarker(),
        _buildDestinationMarker(),
      };
    } else if (deliveryModel?.isAfterOfferAccepted(username) == true) {
      marker = {
        if (_currentP != null && _markerImageData != null) _buildRiderMarker(),
        _buildPickupMarker(),
      };
    } else if (deliveryModel?.isOfferStarted(username) == true) {
      marker = {
        if (_currentP != null && _markerImageData != null) _buildRiderMarker(),
        _buildPickupMarker(),
        _buildDestinationMarker(),
      };
    } else if (deliveryModel?.isOfferEnded(username) == true) {
      marker = {
        if (_currentP != null && _markerImageData != null) _buildRiderMarker(),
        _buildDestinationMarker(),
      };
    } else {
      marker = {
        if (_currentP != null && _markerImageData != null) _buildRiderMarker(),
        _buildPickupMarker(),
        _buildDestinationMarker(),
      };
    }
    return marker;
  }

  Future<void> _cameraToPosition(LocationData pos) async {
    controller = await _mapController.future;
    final double zoomLevel = await controller?.getZoomLevel() ?? 13;
    final CameraPosition _newCameraPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: zoomLevel,
    );
    // await controller?.animateCamera(
    //   CameraUpdate.newCameraPosition(_newCameraPosition),
    // );
  }

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

  Duration calculateDurationInMinutes(
      double distanceInMeters, double riderSpeedMetersPerSecond) {
    // Calculate duration in seconds
    double durationInSeconds = distanceInMeters / riderSpeedMetersPerSecond;

    // Convert duration to minutes
    // double durationInMinutes = durationInSeconds / 60;

    // return durationInMinutes.floor();

    Duration d = Duration(seconds: durationInSeconds.floor());

    return d;
  }

  Circle _buildPickupCircle() {
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    return Circle(
      center: LatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
          deliveryModel?.pickupAddress?.longitude ?? 0.0),
      radius: 50,
      fillColor: navyBlue.withAlpha(50),
      strokeColor: navyBlue.withAlpha(100),
      strokeWidth: 1,
      circleId: const CircleId("_sourceLocation"),
    );
  }

  Circle _buildDestinationCircle() {
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    return Circle(
      center: LatLng(deliveryModel?.deliveryAddress?.latitude ?? 0.0,
          deliveryModel?.deliveryAddress?.longitude ?? 0.0),
      radius: 50,
      fillColor: navyBlue.withAlpha(50),
      strokeColor: navyBlue.withAlpha(100),
      strokeWidth: 1,
      circleId: const CircleId("_destinationLocation"),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationTracker.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationTracker.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationTracker.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationTracker.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationTracker.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        if (mounted)
          setState(() {
            _currentP = currentLocation;

            _cameraToPosition(currentLocation);

            final double pickupDistance = distanceBetween(
                currentLocation,
                LatLng(
                    riderDeliveryBloc
                            .deliveryDetails?.pickupAddress?.latitude ??
                        0.0,
                    riderDeliveryBloc
                            .deliveryDetails?.pickupAddress?.longitude ??
                        0.0));

            riderDeliveryBloc.deliveryDetails?.travelDistance =
                pickupDistance.toString();

            riderDeliveryBloc.deliveryDetails?.travelDuration =
                calculateDurationInMinutes(
                    pickupDistance, currentLocation.speed ?? 0);

            final double destiDistance = distanceBetween(
                currentLocation,
                LatLng(
                    riderDeliveryBloc
                            .deliveryDetails?.deliveryAddress?.latitude ??
                        0.0,
                    riderDeliveryBloc
                            .deliveryDetails?.deliveryAddress?.longitude ??
                        0.0));

            if (riderDeliveryBloc.deliveryDetails?.isOfferStarted(username) ==
                    true ||
                riderDeliveryBloc.deliveryDetails
                        ?.isAfterOfferAccepted(username) ==
                    true) {
              updateCurrentLocation(currentLocation);

              if (pickupDistance <= 50) {
                riderDeliveryBloc.isRiderNearbyPickupLocation(true);
              } else {
                riderDeliveryBloc.isRiderNearbyPickupLocation(false);
              }

              if (destiDistance <= 50) {
                riderDeliveryBloc.isRiderNearbyDestinationLocation(true);
              } else {
                riderDeliveryBloc.isRiderNearbyDestinationLocation(false);
              }
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
          debugPrint('Location updated successfully in the background');
        }
      }).catchError((error) {
        debugPrint(error.toString());
      });
    }
  }

  Future<List<LatLng>> getPolylinePoints() async {
    final DeliveryModel? deliveryModel = riderDeliveryBloc.deliveryDetails;
    final List<LatLng> polylineCoordinates = [];
    final PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = PolylineResult();
    TravelMode mode = TravelMode.driving;
    int counter = 0;

    do {
      if (deliveryModel != null) {
        if (!deliveryModel.isOfferAccepted(username) ||
            deliveryModel.isOfferStarted(username)) {
          result = await polylinePoints.getRouteBetweenCoordinates(
            GOOGLE_MAPS_API_KEY,
            PointLatLng(deliveryModel.pickupAddress?.latitude ?? 0.0,
                deliveryModel.pickupAddress?.longitude ?? 0.0),
            PointLatLng(deliveryModel.deliveryAddress?.latitude ?? 0.0,
                deliveryModel.deliveryAddress?.longitude ?? 0.0),
            travelMode: mode,
          );
        } else if (deliveryModel.isAfterOfferAccepted(username)) {
          result = await polylinePoints.getRouteBetweenCoordinates(
            GOOGLE_MAPS_API_KEY,
            PointLatLng(
                localData?.latitude ?? 0.0, localData?.longitude ?? 0.0),
            PointLatLng(deliveryModel.pickupAddress?.latitude ?? 0.0,
                deliveryModel.pickupAddress?.longitude ?? 0.0),
            travelMode: mode,
          );
        }
        counter++;
      }

      if (result.points.isNotEmpty) {
        deliveryModel?.totalDistance = result.distance;
        deliveryModel?.totalDuration = result.duration;

        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        debugPrint("${result.errorMessage}");
        mode = TravelMode.walking;
      }
    } while (
        result.points.isEmpty && mode == TravelMode.walking && counter < 5);

    return polylineCoordinates;

    // if (deliveryModel?.isOfferAccepted(username) == false ||
    //     deliveryModel?.isOfferStarted(username) == true) {
    //   result = await polylinePoints.getRouteBetweenCoordinates(
    //     GOOGLE_MAPS_API_KEY,
    //     PointLatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
    //         deliveryModel?.pickupAddress?.longitude ?? 0.0),
    //     PointLatLng(deliveryModel?.deliveryAddress?.latitude ?? 0.0,
    //         deliveryModel?.deliveryAddress?.longitude ?? 0.0),
    //     travelMode: TravelMode.driving,
    //   );
    // } else if (deliveryModel?.isAfterOfferAccepted(username) == true) {
    //   result = await polylinePoints.getRouteBetweenCoordinates(
    //     GOOGLE_MAPS_API_KEY,
    //     PointLatLng(localData.latitude!, localData.longitude!),
    //     PointLatLng(deliveryModel?.pickupAddress?.latitude ?? 0.0,
    //         deliveryModel?.pickupAddress?.longitude ?? 0.0),
    //     travelMode: TravelMode.driving,
    //   );
    // }
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //   });
    // } else {
    //   debugPrint(result.errorMessage);
    // }
    // return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    final PolylineId id = const PolylineId("poly");
    final Polyline polyline = Polyline(
      polylineId: id,
      color: navyBlue,
      points: polylineCoordinates,
      width: 9,
    );
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
