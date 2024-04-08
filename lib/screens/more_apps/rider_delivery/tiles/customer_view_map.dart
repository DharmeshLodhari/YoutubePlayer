import 'dart:async';
import 'dart:typed_data';

import 'package:Slydo/flutter_polyline_points/flutter_polyline_points.dart';
import 'package:Slydo/flutter_polyline_points/utils/polyline_result.dart';
import 'package:Slydo/flutter_polyline_points/utils/request_enums.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomerViewMap extends StatefulWidget {
  CustomerViewMap({
    super.key,
    this.journeyDetail,
  });

  final DeliveryModel? journeyDetail;

  @override
  _CustomerViewMapState createState() => _CustomerViewMapState();
}

class _CustomerViewMapState extends State<CustomerViewMap> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  String rideMarkerImage = "assets/images/bike_top.png";
  GoogleMapController? controller;
  Location _locationController = new Location();
  bool isLoading = false;

  Map<PolylineId, Polyline> polylines = {};
  Uint8List? _markerImageData;

  RiderLocation? riderLocation;
  Timer? _timer;

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

      Map<String, dynamic>? location;
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        location = await RiderDeliveryAuthService()
            .fetchRiderLocation(widget.journeyDetail?.id);

        final LatLng latLng = LatLng(location?["location"]["latitude"],
            location?["location"]["longitude"]);

        riderLocation = RiderLocation(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            dispatcherHeading: location?["dispatcher_heading"]);

        _cameraToPosition(latLng);

        if (mounted) setState(() {});
      });

      getPolylinePoints().then((coordinates) => {
            generatePolyLineFromPoints(coordinates),
          });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildShowRoute(),
    );
  }

  Widget _buildShowRoute() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            onMapCreated: ((GoogleMapController controller) =>
                _mapController.complete(controller)),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  widget.journeyDetail?.pickupAddress?.latitude ?? 0.0,
                  widget.journeyDetail?.pickupAddress?.longitude ?? 0.0),
              zoom: 13,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("_riderLocation"),
                icon: BitmapDescriptor.fromBytes(_markerImageData!),
                rotation: riderLocation?.getHeading() ?? 0.0,
                position: LatLng(riderLocation?.latitude ?? 0.0,
                    riderLocation?.longitude ?? 0.0),
                anchor: const Offset(0.5, 0.5),
              ),
              Marker(
                markerId: const MarkerId("_sourceLocation"),
                icon: BitmapDescriptor.defaultMarkerWithHue(0),
                position: LatLng(
                    widget.journeyDetail?.pickupAddress?.latitude ?? 0.0,
                    widget.journeyDetail?.pickupAddress?.longitude ?? 0.0),
              ),
              Marker(
                markerId: const MarkerId("_destinationLocation"),
                icon: BitmapDescriptor.defaultMarkerWithHue(250),
                position: LatLng(
                    widget.journeyDetail?.deliveryAddress?.latitude ?? 0.0,
                    widget.journeyDetail?.deliveryAddress?.longitude ?? 0.0),
              )
            },
            polylines: Set<Polyline>.of(polylines.values),
          );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    controller = await _mapController.future;
    final double zoomLevel = await controller?.getZoomLevel() ?? 13;
    final CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: zoomLevel,
    );
    // await controller?.animateCamera(
    //   CameraUpdate.newCameraPosition(_newCameraPosition),
    // );
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

    //   if (riderDeliveryBloc.deliveryDetails?.isInProgress == true) {
    //     _locationController.onLocationChanged
    //         .listen((LocationData currentLocation) {
    //       if (currentLocation.latitude != null &&
    //           currentLocation.longitude != null) {
    if (mounted)
      setState(() {
        // _currentP =
        //     LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _cameraToPosition(LatLng(
            riderLocation?.longitude ?? 0.0, riderLocation?.longitude ?? 0.0));
      });
    // }
    //     });
    //   }
  }

  Future<List<LatLng>> getPolylinePoints() async {
    final ShippingAddress? deliveryModel =
        widget.journeyDetail?.deliveryAddress;
    final ShippingAddress? pickupModel = widget.journeyDetail?.pickupAddress;
    final List<LatLng> polylineCoordinates = [];
    final PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = PolylineResult();

    result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(pickupModel?.latitude ?? 0.0, pickupModel?.longitude ?? 0.0),
      PointLatLng(
          deliveryModel?.latitude ?? 0.0, deliveryModel?.longitude ?? 0.0),
      travelMode: TravelMode.driving,
    );
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
    final PolylineId id = const PolylineId("poly");
    final Polyline polyline = Polyline(
        polylineId: id, color: navyBlue, points: polylineCoordinates, width: 3);
    if (mounted)
      setState(() {
        polylines[id] = polyline;
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
