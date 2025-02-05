import 'dart:async';
import 'dart:typed_data';

import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/flutter_polyline_points/flutter_polyline_points.dart';
import 'package:Slydo/flutter_polyline_points/utils/polyline_result.dart';
import 'package:Slydo/flutter_polyline_points/utils/request_enums.dart';
import 'package:Slydo/screens/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/rider_delivery/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RiderDeliveryMap extends StatefulWidget {
  const RiderDeliveryMap({super.key});

  @override
  State<RiderDeliveryMap> createState() => _RiderDeliveryMapState();
}

class _RiderDeliveryMapState extends State<RiderDeliveryMap> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LocationData? _currentP;
  String rideMarkerImage = "assets/images/bike_top.png";
  GoogleMapController? controller;
  Set<Circle> circles = {};

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
      final double? accuracy = currentLocation.accuracy;
      debugPrint('Location Accuracy: $accuracy meters');
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
    // final LocationData location = await _locationTracker.getLocation();
    return currentLocation;
  }

  Future<Uint8List> getRiderMarker() async {
    // debugPrint("rider => $rideMarkerImage");
    final ByteData byteData =
        await DefaultAssetBundle.of(context).load(rideMarkerImage);
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getMarkerImage() async {
    final Uint8List imageData = await getRiderMarker();
    return imageData;
  }

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
    final CameraPosition newCameraPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: zoomLevel,
    );
    // await controller?.animateCamera(
    //   CameraUpdate.newCameraPosition(_newCameraPosition),
    // );
  }

  Duration calculateDurationInMinutes(
      double distanceInMeters, double riderSpeedMetersPerSecond) {
    // Calculate duration in seconds
    final double durationInSeconds =
        distanceInMeters / riderSpeedMetersPerSecond;

    // Convert duration to minutes
    // double durationInMinutes = durationInSeconds / 60;

    // return durationInMinutes.floor();

    final Duration d = Duration(seconds: durationInSeconds.floor());

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
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationTracker.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationTracker.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationTracker.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationTracker.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationTracker.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        if (mounted) {
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

        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        debugPrint("${result.errorMessage}");
        mode = TravelMode.walking;
      }
    } while (
        result.points.isEmpty && mode == TravelMode.walking && counter < 5);

    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    const PolylineId id = PolylineId("poly");
    final Polyline polyline = Polyline(
      polylineId: id,
      color: navyBlue,
      points: polylineCoordinates,
      width: 9,
    );
    if (mounted) {
      setState(() {
        polylines[id] = polyline;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
