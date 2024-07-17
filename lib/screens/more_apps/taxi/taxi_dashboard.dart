import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/taxi/model/PlaceModal.dart';
import 'package:Slydo/screens/more_apps/taxi/taxi_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TaxiDashboard extends StatefulWidget {
  const TaxiDashboard({super.key});

  @override
  State<TaxiDashboard> createState() => _TaxiDashboardState();
}

class _TaxiDashboardState extends State<TaxiDashboard> {
  late TaxiBloc taxiBloc;

  LatLng? userCurrentLocation;
  bool isLoading = false;

  @override
  void initState() {
    getNearbyRides();
    super.initState();
  }

  void getNearbyRides() async {
    isLoading = true;
    if (mounted) setState(() {});
    final UserLocation? userLocation =
        await LocationService().getLocation().catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
      debugPrint("ERROR:- $error");
    });

    if (userLocation != null) {
      userCurrentLocation =
          LatLng(userLocation.latitude!, userLocation.longitude!);
    }
    isLoading = false;
    if (mounted) setState(() {});

    /// TODO: get user location and call api with location to get nearby rides
    /// & display rides on maps
  }

  /// TODO: store selected places in database and show them in recent places

  @override
  Widget build(BuildContext context) {
    taxiBloc = Provider.of<TaxiBloc>(context);
    return SafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      left: false,
      right: false,
      child: WillPopScope(
        onWillPop: () async {
          if (taxiBloc.destinationPoint != null) {
            taxiBloc.destinationPoint = null;
            return Future.value(false);
          }

          taxiBloc.startingPoint = null;
          taxiBloc.rideDetail = null;
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: isLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : _ScaffoldBody(userCurrentLocation: userCurrentLocation),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          if (taxiBloc.destinationPoint != null) {
            taxiBloc.destinationPoint = null;
            return;
          } else {
            taxiBloc.startingPoint = null;
            taxiBloc.rideDetail = null;
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text(
        "Transport",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScaffoldBody extends StatefulWidget {
  const _ScaffoldBody({this.userCurrentLocation});
  final LatLng? userCurrentLocation;

  @override
  __ScaffoldBodyState createState() => __ScaffoldBodyState();
}

class __ScaffoldBodyState extends State<_ScaffoldBody> {
  final double _initialSheetChildSize = 0.3;
  final double _initialSheetChildSizeAfterDestination = 0.25;
  double _dragScrollSheetExtent = 0;

  double _widgetHeight = 0;
  double _fabPosition = 0;
  final double _fabPositionPadding = 10;

  late CameraPosition _initialCameraPosition;

  List<PlaceModal> places = [];

  GoogleMapController? googleMapController;

  Marker? _carOneMarker;
  Marker? _bikeOneMarker;
  Marker? _tricycleOneMarker;
  Circle? _myLocationMarker;

  late TaxiBloc taxiBloc;
  int? index;

  @override
  void initState() {
    places = TaxiAuth().getFakePlaces();

    super.initState();
    _initialCameraPosition =
        const CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);

    if (widget.userCurrentLocation != null) {
      _initialCameraPosition = CameraPosition(
          target: LatLng(widget.userCurrentLocation!.latitude,
              widget.userCurrentLocation!.longitude),
          zoom: 14);

      _myLocationMarker = Circle(
          circleId: const CircleId("MyLocation"),
          center: LatLng(widget.userCurrentLocation!.latitude,
              widget.userCurrentLocation!.longitude),
          fillColor: navyBlue.withAlpha(70),
          radius: 100,
          visible: true,
          zIndex: 1,
          strokeWidth: 2,
          strokeColor: navyBlue);

      assignMarkers();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // render the floating button on widget
        _fabPosition = _initialSheetChildSize * context.size!.height;
      });
    });
  }

  void assignMarkers() async {
    debugPrint(
        "${widget.userCurrentLocation!.latitude} => ${widget.userCurrentLocation!.longitude}");
    _carOneMarker = Marker(
      markerId: const MarkerId("Taxi"),
      infoWindow: const InfoWindow(title: "Taxi"),
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/images/car_top.png"),
      position: LatLng(widget.userCurrentLocation!.latitude - 0.003300,
          widget.userCurrentLocation!.longitude + 0.009100),
    );
    _bikeOneMarker = Marker(
      markerId: const MarkerId("Bike"),
      infoWindow: const InfoWindow(title: "Taxi"),
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/images/bike_top.png"),
      position: LatLng(widget.userCurrentLocation!.latitude - 0.010150,
          widget.userCurrentLocation!.longitude - 0.000100),
    );
    _tricycleOneMarker = Marker(
      markerId: const MarkerId("Tricycle"),
      infoWindow: const InfoWindow(title: "Taxi"),
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/images/tricycle_top.png"),
      position: LatLng(widget.userCurrentLocation!.latitude - 0.010150,
          widget.userCurrentLocation!.longitude - 0.010100),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    taxiBloc = Provider.of<TaxiBloc>(context);
    return Stack(
      children: getStackChildren(),
    );
  }

  List<Widget> getStackChildren() {
    final List<Widget> items = [];
    items.add(GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      circles: {
        if (_myLocationMarker != null) _myLocationMarker!,
      },
      markers: {
        if (_carOneMarker != null) _carOneMarker!,
        if (_bikeOneMarker != null) _bikeOneMarker!,
        if (_tricycleOneMarker != null) _tricycleOneMarker!,
      },
    ));

    // FlutterMap(
    //   mapController: mapController,
    //   options:
    //       MapOptions(center: mapPoint, zoom: 18.0, minZoom: 5, maxZoom: 18),
    //   layers: [
    //     TileLayerOptions(
    //       urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    //       subdomains: ['a', 'b', 'c'],
    //       overrideTilesWhenUrlChanges: true,
    //     ),
    //     MarkerLayerOptions(
    //       markers: [
    //         Marker(
    //           point: mapPoint,
    //           builder: (ctx) => Container(
    //             child: Icon(
    //               SlydoAppIcon.location,
    //               color: blackFont,
    //               size: 28,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // ),

    if (taxiBloc.destinationPoint == null) {
      items.add(getFloatingActionButton());
      items.add(
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (DraggableScrollableNotification notification) {
            setState(() {
              _widgetHeight = context.size!.height;
              _dragScrollSheetExtent = notification.extent;

              // Calculate FAB position based on parent widget height and DraggableScrollable position
              _fabPosition = _dragScrollSheetExtent * _widgetHeight;
            });
            return;
          } as bool Function(DraggableScrollableNotification)?,
          child: DraggableScrollableSheet(
            initialChildSize: taxiBloc.destinationPoint != null
                ? _initialSheetChildSizeAfterDestination
                : _initialSheetChildSize,
            maxChildSize: taxiBloc.destinationPoint != null
                ? _initialSheetChildSizeAfterDestination
                : 0.5,
            minChildSize: taxiBloc.destinationPoint != null
                ? _initialSheetChildSizeAfterDestination
                : 0.135,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  color: Colors.white,
                  child:
                      getSearchDestination(scrollController: scrollController)),
            ),
          ),
        ),
      );
    } else {
      items.add(getSelectedLocationUI());
    }

    return items;
  }

  Widget getSelectedLocationUI() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Card(
          elevation: 4,
          shadowColor: dividerColor,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Destination location",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: blackFont),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    leading: RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      height: 32,
                      borderRadius: 12,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.location,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    title: Text(
                      taxiBloc.destinationPoint!.name!,
                      style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    ),
                    subtitle:
                        Text(taxiBloc.destinationPoint!.formattedAddress!),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  submitButton()
                ],
              ),
            ),
          ),
        ));
  }

  Widget getFloatingActionButton() {
    return Positioned(
      bottom: _fabPosition + _fabPositionPadding,
      right: _fabPositionPadding, // Padding to create some space on the right
      child: FloatingActionButton(
        elevation: 2,
        backgroundColor: Colors.white,
        onPressed: () async {
          final locationService = LocationService();
          final UserLocation? userLocation =
              await locationService.getLocation().catchError((error) {
            debugPrint("ERROR:- $error");
          });

          if (userLocation == null) {
            return null;
          }
          debugPrint("${userLocation.latitude}  ${userLocation.longitude}");
          googleMapController!.animateCamera(CameraUpdate.newLatLng(
              LatLng(userLocation.latitude!, userLocation.longitude!)));

          // mapPoint = LatLng(userLocation.latitude, userLocation.longitude);
          // if (mounted) setState(() {});
          // mapController.moveAndRotate(mapPoint, 19, 0);
        },
        child: Icon(
          Icons.my_location,
          color: blackFont,
        ),
      ),
    );
  }

  Widget getSearchDestination({ScrollController? scrollController}) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: ListView(
        controller: scrollController,
        children: [
          Text(
            "Where are you going?",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
          ),
          const SizedBox(
            height: 12,
          ),
          getSearchTextField(),
          for (int i = 0; i < places.length; i++)
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              leading: RoundedBackgroundIcon(
                backgroundColor: lightGrey,
                height: 32,
                borderRadius: 12,
                width: 32,
                icon: Icon(
                  SlydoAppIcon.location,
                  size: 14,
                  color: blackFont,
                ),
              ),
              title: Text(
                places[i].name!,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              subtitle: Text(places[i].formattedAddress!),
              onTap: () {
                taxiBloc.destinationPoint = places[i];
                index = i;
              },
            ),
        ],
      ),
    );
  }

  Widget getSearchTextField() {
    return GestureDetector(
      onTap: () {
        // widget.toggleAddressSelection(true);

        Navigator.of(context).pushNamed("/select-destination-for-taxi-ride");
      },
      child: SearchTextField(
        hintText: "Search",
        textEditingController: TextEditingController(),
        isDisabled: true,
        hintStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        onSubmit: () {},
      ),
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        if (taxiBloc.startingPoint == null) {
          if (index != 0) {
            taxiBloc.startingPoint = places[0];
          } else {
            taxiBloc.startingPoint = places[1];
          }
        }
        Navigator.of(context).pushNamed("/select-ride-type",
            arguments: {"currentChild": const TaxiDashboard()});
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Set destination location",
    );
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }
}
