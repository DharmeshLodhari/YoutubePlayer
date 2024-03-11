import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  // MapController controller = MapController(
  //   initMapWithUserPosition: false,
  //   initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
  //   areaLimit: BoundingBox(
  //     east: 10.4922941,
  //     north: 47.8084648,
  //     south: 45.817995,
  //     west: 5.9559113,
  //   ),
  // );

  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      title: Text(
        'Map',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody() {
    return Container();
    // return OSMFlutter(
    //   key: UniqueKey(),
    //   controller: controller,
    //   trackMyPosition: false,
    //   initZoom: 12,
    //   minZoomLevel: 8,
    //   maxZoomLevel: 14,
    //   stepZoom: 1.0,
    //   userLocationMarker: UserLocationMaker(
    //     personMarker: MarkerIcon(
    //       icon: Icon(
    //         Icons.location_history_rounded,
    //         color: Colors.red,
    //         size: 48,
    //       ),
    //     ),
    //     directionArrowMarker: MarkerIcon(
    //       icon: Icon(
    //         Icons.double_arrow,
    //         size: 48,
    //       ),
    //     ),
    //   ),
    //   roadConfiguration: RoadConfiguration(
    //     startIcon: MarkerIcon(
    //       icon: Icon(
    //         Icons.person,
    //         size: 64,
    //         color: Colors.brown,
    //       ),
    //     ),
    //     roadColor: Colors.yellowAccent,
    //   ),
    //   markerOption: MarkerOption(
    //       defaultMarker: MarkerIcon(
    //     icon: Icon(
    //       Icons.person_pin_circle,
    //       color: Colors.blue,
    //       size: 56,
    //     ),
    //   )),
    // );
  }
}
