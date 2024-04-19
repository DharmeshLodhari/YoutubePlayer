import 'dart:async';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class SearchingForRide extends StatefulWidget {
  @override
  _SearchingForRideState createState() => _SearchingForRideState();
}

class _SearchingForRideState extends State<SearchingForRide> {
  bool isSearchingForDriver = false;

  Timer? driverFindingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      navigateToArrivingDriver();
    });
  }

  void navigateToArrivingDriver() async {
    driverFindingTimer = Timer(const Duration(seconds: 5), () {
      final bool isDriverFound = true;
      if (isDriverFound) {
        Navigator.of(context).pushNamed("/driver-arriving");
      } else {
        Navigator.of(context).pushNamed("/no-vehicle-found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Image.asset(
              "assets/images/map.png",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            // FlutterMap(
            //   mapController: mapController,
            //   options: MapOptions(
            //       center: mapPoint, zoom: 18.0, minZoom: 5, maxZoom: 18),
            //   layers: [
            //     TileLayerOptions(
            //       urlTemplate:
            //           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
            getSearchingDriverUI(),
            getCloseButton(),
            getCancelBookingUI()
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
        "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getCloseButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: SafeArea(
        child: InkWell(
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 26,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget getCancelBookingUI() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                getRideInfo(),
                const SizedBox(
                  height: 20,
                ),
                getCancelBookingBtn(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }

  Widget getRideInfo() {
    return Card(
      shadowColor: dividerColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  "11:24",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "11:38",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Image.asset(
              "assets/images/taxi/route.png",
              height: 50,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "1 Bola Dada Avenue, Victoria Islan...",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Tafawa Balewa Square, Lagos Islan...",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCancelBookingBtn() {
    return CurvedButton(
      onPressed: () {
        if (driverFindingTimer?.isActive ?? false) {
          driverFindingTimer?.cancel();
        }
        Navigator.of(context).pushNamed("/cancel-booking");
      },
      borderRadius: 10,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Cancel Booking",
    );
  }

  Widget getSearchingDriverUI() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: blackFont.withAlpha(225),
      child: Column(
        children: [
          const Expanded(
            child: SizedBox(
              height: 10,
            ),
          ),
          Image.asset(
            "assets/images/taxi/car_loader.png",
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width / 1.5,
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            "Searching for a driver",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}
