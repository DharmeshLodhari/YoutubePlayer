import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class NoVehicleFound extends StatefulWidget {
  const NoVehicleFound({super.key});

  @override
  State<NoVehicleFound> createState() => _NoVehicleFoundState();
}

class _NoVehicleFoundState extends State<NoVehicleFound> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
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
            driverDetailUI()
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
          Icons.keyboard_arrow_left_rounded,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget driverDetailUI() {
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
                    height: 30,
                  ),
                  Column(
                    children: [
                      getDriverInfo(),
                      const SizedBox(
                        height: 30,
                      ),
                      getPayButton(),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget getPayButton() {
    return CurvedButton(
        text: "Choose another location",
        textColor: Colors.white,
        onPressed: () {
          Navigator.of(context).popUntil(ModalRoute.withName("/taxi"));
        },
        borderRadius: 10,
        backgroundColor: navyBlue);
  }

  Widget getDriverInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("/terms-and-condition");
            },
            child: Container(
              decoration: BoxDecoration(
                color: mateRed.withAlpha(55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                  height: 60,
                  width: 60,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.info,
                    color: mateRed,
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Sorry, there are no vehicles in this area.",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
