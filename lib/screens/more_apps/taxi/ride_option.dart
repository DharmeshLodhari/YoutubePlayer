import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class RideOption extends StatefulWidget {
  @override
  _RideOptionState createState() => _RideOptionState();
}

class _RideOptionState extends State<RideOption> {
  Map<String, dynamic> selectedDestination;

  Map<String, dynamic> selectedRide;

  bool isRideSelected = false;
  bool toggleCarOption = false;

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
    }
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: Stack(
          children: [
            // Image.asset(
            //   "assets/images/map.png",
            //   height: double.infinity,
            //   width: double.infinity,
            //   fit: BoxFit.fill,
            // ),

            MapUI(),

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
            isRideSelected
                ? getBottomUI(bookingConfirmation())
                : toggleCarOption
                    ? getBottomUI(getCarSelectionListView())
                    : getBottomUI(getRideSelectionListView()),
          ],
        ),
      ),
    );
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        isRideSelected ? "Booking details" : "Ride Option",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getRideOptions() {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          // controller: scrollController,
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ));
  }

  Widget getBottomUI(Widget child) {
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
              child: child,
            ),
          ),
        ));
  }

  Widget bookingConfirmation() {
    return Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      selectedRide["image"],
                      height: 90,
                      width: 120,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      selectedRide["name"],
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
            submitButton(),
          ],
        ),
      ),
    );
  }

  Widget getRideSelectionListView() {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: rideOption.map((ride) {
            return Container(
              padding: EdgeInsets.only(right: 8, bottom: 8),
              child: GestureDetector(
                onTap: () {
                  if (ride["name"] == "Car") {
                    toggleCarOption = !toggleCarOption;
                    if (mounted) setState(() {});
                  } else {
                    isRideSelected = true;
                    selectedRide = ride;
                    if (mounted) setState(() {});
                  }
                },
                child: Card(
                  shadowColor: dividerColor,
                  elevation: 2,
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3.5,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        Image.asset(
                          ride["image"],
                          height: 50,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          ride["name"],
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
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
                              ride["price"],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                                color: darkGrey.withAlpha(100),
                                borderRadius: BorderRadius.circular(100)),
                            child: Text(
                              ride["time"],
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getCarSelectionListView() {
    return Container(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: carOption.map((car) {
          return Container(
            padding: EdgeInsets.only(right: 8, bottom: 8),
            child: GestureDetector(
              onTap: () {
                isRideSelected = !isRideSelected;
                selectedRide = car;
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
                        car["image"],
                        height: 50,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        car["name"],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
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
                            car["price"],
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
                            car["time"],
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        if (isRideSelected) {
          Navigator.of(context).pushNamed("/search-driver",
              arguments: {"currentChild": RideOption()});
        }
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: isRideSelected ? "Book Ride" : "Set destination location",
    );
  }
}
