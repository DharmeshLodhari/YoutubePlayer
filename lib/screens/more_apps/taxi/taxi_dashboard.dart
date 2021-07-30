import 'package:Slydo/screens/more_apps/taxi/select_address.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/search_text_field.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaxiDashboard extends StatefulWidget {
  @override
  _TaxiDashboardState createState() => _TaxiDashboardState();
}

class _TaxiDashboardState extends State<TaxiDashboard> {
  Map<String, dynamic> selectedDestination;
  bool isDestinationSelected = false;

  bool isAddressSelection = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isAddressSelection) {
          isAddressSelection = false;
          if (mounted) setState(() {});
          return false;
        }

        if (selectedDestination == null)
          return Future.value(true);
        else {
          selectedDestination = null;
          isDestinationSelected = false;
          if (mounted) setState(() {});
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: isAddressSelection
            ? SelectAddressForTaxi(
                toggleAddressSelection: toggleAddressSelection,
                updateSelectedDestination: updateSelectedDestination)
            : ScaffoldBody(
                toggleAddressSelection: toggleAddressSelection,
                selectedDestination: selectedDestination,
                isDestinationSelected: isDestinationSelected,
                updateSelectedDestination: updateSelectedDestination),
      ),
    );
  }

  void updateSelectedDestination(Map<String, dynamic> place) {
    isDestinationSelected = true;
    selectedDestination = place;
    setState(() {});
  }

  void toggleAddressSelection(bool selectAddress) {
    isAddressSelection = selectAddress;
    if (mounted) setState(() {});
  }

  Widget appBar() {
    return AppBar(
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
          if (isAddressSelection) {
            isAddressSelection = false;
            if (mounted) setState(() {});
            return;
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        isAddressSelection ? "Select Address" : "Transport",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ScaffoldBody extends StatefulWidget {
  Map<String, dynamic> selectedDestination;
  void Function(Map<String, dynamic> place) updateSelectedDestination;
  void Function(bool selectAddress) toggleAddressSelection;
  bool isDestinationSelected;
  ScaffoldBody({
    this.selectedDestination,
    this.updateSelectedDestination,
    this.isDestinationSelected,
    this.toggleAddressSelection,
  });
  @override
  _ScaffoldBodyState createState() => _ScaffoldBodyState();
}

class _ScaffoldBodyState extends State<ScaffoldBody> {
  double _initialSheetChildSize = 0.135;
  double _initialSheetChildSizeAfterDestination = 0.25;
  double _dragScrollSheetExtent = 0;

  double _widgetHeight = 0;
  double _fabPosition = 0;
  double _fabPositionPadding = 10;

  TextEditingController searchDestinationController;

  static const _initialCameraPosition =
      CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);

  List<Map<String, dynamic>> places = [
    {"name": "Ikeja City Mall, Alausa", "place": "Ikeja"},
    {"name": "101, Lagos-Ikorodu Expressway,", "place": "Lagos"},
    {"name": "67, Mobolaji Bank Anthony Way,", "place": "Ikeja"},
    {"name": "Agege Post Office, Agege,", "place": "Lagos"},
    {"name": "101, Lagos-Ikorodu Expressway,", "place": "Lagos"},
    {"name": "67, Mobolaji Bank Anthony Way,", "place": "Ikeja"},
  ];

  LatLng mapPoint = LatLng(6.605874, 3.349149);

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
  void initState() {
    super.initState();

    searchDestinationController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // render the floating button on widget
        _fabPosition = _initialSheetChildSize * context.size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: getStackChildren(),
    );
  }

  List<Widget> getStackChildren() {
    List<Widget> items = [];
    // items.add(Image.asset(
    //   "assets/images/map.png",
    //   height: double.infinity,
    //   width: double.infinity,
    //   fit: BoxFit.fill,
    // ));
    items.add(GoogleMap(
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

    if (widget.selectedDestination == null) {
      items.add(getFloatingActionButton());
      items.add(
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (DraggableScrollableNotification notification) {
            setState(() {
              _widgetHeight = context.size.height;
              _dragScrollSheetExtent = notification.extent;

              // Calculate FAB position based on parent widget height and DraggableScrollable position
              _fabPosition = _dragScrollSheetExtent * _widgetHeight;
            });
            return;
          },
          child: DraggableScrollableSheet(
            initialChildSize: widget.isDestinationSelected
                ? _initialSheetChildSizeAfterDestination
                : _initialSheetChildSize,
            maxChildSize: widget.isDestinationSelected
                ? _initialSheetChildSizeAfterDestination
                : 0.5,
            minChildSize: widget.isDestinationSelected
                ? _initialSheetChildSizeAfterDestination
                : 0.135,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: BorderRadius.only(
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
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
                  SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                      widget.selectedDestination["name"],
                      style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    ),
                    subtitle: Text(widget.selectedDestination["place"]),
                  ),
                  SizedBox(
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
        child: Icon(
          Icons.my_location,
          color: blackFont,
        ),
        backgroundColor: Colors.white,
        onPressed: () async {
          final locationService = LocationService();
          UserLocation userLocation =
              await locationService.getLocation().catchError((error) {
            debugPrint("ERROR:- $error");
          });

          if (userLocation == null) {
            return null;
          }
          debugPrint("${userLocation.latitude}  ${userLocation.longitude}");
          googleMapController.animateCamera(CameraUpdate.newLatLng(
              LatLng(userLocation.latitude, userLocation.longitude)));

          // mapPoint = LatLng(userLocation.latitude, userLocation.longitude);
          // if (mounted) setState(() {});
          // mapController.moveAndRotate(mapPoint, 19, 0);
        },
      ),
    );
  }

  Widget getSearchDestination({ScrollController scrollController}) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 20),
      child: ListView(
        controller: scrollController,
        children: [
          Text(
            "Where are you going?",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
          ),
          SizedBox(
            height: 12,
          ),
          getSearchTextField(),
          for (int i = 0; i < places.length; i++)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                places[i]["name"],
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              subtitle: Text(places[i]["place"]),
              onTap: () {
                widget.updateSelectedDestination(places[i]);
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget getSearchTextField() {
    return GestureDetector(
      onTap: () {
        widget.toggleAddressSelection(true);
      },
      child: SearchTextField(
        hintText: "Search",
        isDisabled: true,
        hintStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        onSubmit: () {},
        textEditingController: searchDestinationController,
      ),
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        widget.isDestinationSelected = false;
        Navigator.of(context).pushNamed("/select-ride-type",
            arguments: {"currentChild": TaxiDashboard()});
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Set destination location",
    );
  }

  @override
  void dispose() {
    searchDestinationController?.dispose();
    googleMapController?.dispose();
    super.dispose();
  }
}
