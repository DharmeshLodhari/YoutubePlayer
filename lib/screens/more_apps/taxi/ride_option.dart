import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class RideOption extends StatefulWidget {
  @override
  _RideOptionState createState() => _RideOptionState();
}

class _RideOptionState extends State<RideOption> {
  Map<String, dynamic> selectedDestination;
  bool isDestinationSelected = false;

  bool isAddressSelection = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: ScaffoldBody(
          toggleAddressSelection: toggleAddressSelection,
          selectedDestination: selectedDestination,
          isDestinationSelected: isDestinationSelected,
          updateSelectedDestination: updateSelectedDestination,
        ),
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
        "Ride Option",
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

  ScaffoldBody(
      {this.selectedDestination,
      this.updateSelectedDestination,
      this.isDestinationSelected,
      this.toggleAddressSelection});
  @override
  _ScaffoldBodyState createState() => _ScaffoldBodyState();
}

class _ScaffoldBodyState extends State<ScaffoldBody> {
  double _initialSheetChildSize = 0.35;

  MapController mapController;

  LatLng mapPoint = LatLng(6.605874, 3.349149);
  bool toggleCarOption = false;
  bool isRideSelected = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image.asset(
        //   "assets/images/map.png",
        //   height: double.infinity,
        //   width: double.infinity,
        //   fit: BoxFit.fill,
        // ),
        FlutterMap(
          mapController: mapController,
          options:
              MapOptions(center: mapPoint, zoom: 18.0, minZoom: 5, maxZoom: 18),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              overrideTilesWhenUrlChanges: true,
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  point: mapPoint,
                  builder: (ctx) => Container(
                    child: Icon(
                      SlydoAppIcon.location,
                      color: blackFont,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (DraggableScrollableNotification notification) {
            return;
          },
          child: DraggableScrollableSheet(
            initialChildSize: _initialSheetChildSize,
            maxChildSize: _initialSheetChildSize,
            minChildSize: _initialSheetChildSize,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  color: Colors.white,
                  child: getRideOptions(scrollController: scrollController)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getRideOptions({ScrollController scrollController}) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          // controller: scrollController,
          children: [
            Expanded(
              child: isRideSelected
                  ? bookingConfirmation()
                  : toggleCarOption
                      ? getCardSelectionListView()
                      : getRideSelectionListView(),
            ),
            SizedBox(
              height: 20,
            ),
            submitButton(),
            SizedBox(
              height: 40,
            ),
          ],
        ));
  }

  List<Map<String, dynamic>> rideOption = [
    {
      "name": "Car",
      "price": "1200",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
    {
      "name": "Bike",
      "price": "600",
      "image": "assets/images/taxi/bike.png",
      "time": "3 mins"
    },
    {
      "name": "Tricycle",
      "price": "800",
      "image": "assets/images/taxi/tricycle.png",
      "time": "3 mins"
    },
    {
      "name": "Car",
      "price": "1200",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
    {
      "name": "Bike",
      "price": "600",
      "image": "assets/images/taxi/bike.png",
      "time": "3 mins"
    },
    {
      "name": "Tricycle",
      "price": "800",
      "image": "assets/images/taxi/tricycle.png",
      "time": "3 mins"
    },
  ];

  List<Map<String, dynamic>> carOption = [
    {
      "name": "Standard",
      "price": "500-600",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
    {
      "name": "Executive",
      "price": "700-800",
      "image": "assets/images/taxi/car_exec.png",
      "time": "3 mins"
    },
    {
      "name": "Van",
      "price": "800",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
    {
      "name": "Standard",
      "price": "500-600",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
    {
      "name": "Executive",
      "price": "700-800",
      "image": "assets/images/taxi/car_exec.png",
      "time": "3 mins"
    },
    {
      "name": "Van",
      "price": "800",
      "image": "assets/images/taxi/car.png",
      "time": "3 mins"
    },
  ];

  Widget bookingConfirmation() {
    return Container(
      child: Card(
        shadowColor: dividerColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    carOption[1]["image"],
                    height: 90,
                    fit: BoxFit.fill,
                  ),
                  Text(
                    "Standard",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: "roberto"),
                      ),
                      Text(
                        "1000 - 1200",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: blackFont),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                          color: darkGrey.withAlpha(100),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        "3 mins",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getRideSelectionListView() {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              toggleCarOption = !toggleCarOption;
              if (mounted) setState(() {});
            },
            child: Card(
              shadowColor: dividerColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: MediaQuery.of(context).size.width / 3.5,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    Image.asset(
                      rideOption[index]["image"],
                      height: 50,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      rideOption[index]["name"],
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₦",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: "roberto"),
                        ),
                        Text(
                          rideOption[index]["price"],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                            color: darkGrey.withAlpha(100),
                            borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          rideOption[index]["time"],
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        itemCount: rideOption.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget getCardSelectionListView() {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              isRideSelected = !isRideSelected;
              if (mounted) setState(() {});
            },
            child: Card(
              shadowColor: dividerColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: MediaQuery.of(context).size.width / 3.5,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    Image.asset(
                      carOption[index]["image"],
                      height: 50,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      carOption[index]["name"],
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₦",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: "roberto"),
                        ),
                        Text(
                          carOption[index]["price"],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                            color: darkGrey.withAlpha(100),
                            borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          carOption[index]["time"],
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        itemCount: carOption.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        if (isRideSelected) {
          Navigator.of(context).pushNamed("/search-driver",arguments: {"currentChild": RideOption()});
        }
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: isRideSelected ? "Book Ride" : "Set destination location",
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
