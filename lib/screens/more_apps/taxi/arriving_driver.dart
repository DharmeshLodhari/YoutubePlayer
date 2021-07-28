import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class ArrivingDriver extends StatefulWidget {
  @override
  _ArrivingDriverState createState() => _ArrivingDriverState();
}

class _ArrivingDriverState extends State<ArrivingDriver> {
  bool isSearchingForDriver = false;

  MapController mapController;

  LatLng mapPoint = LatLng(6.605874, 3.349149);

  bool isDriverStartedMoving = false;
  bool isDriverArrived = false;
  bool isTripStarted = false;
  bool isNavigationStarted = false;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5)).then((value) {
      isDriverStartedMoving = false;
      isDriverArrived = true;
      if (mounted) setState(() {});
      Future.delayed(Duration(seconds: 5)).then((value) {
        isDriverStartedMoving = false;
        isDriverArrived = false;
        isTripStarted = true;

        if (mounted) setState(() {});
        Future.delayed(Duration(seconds: 5)).then((value) {
          isDriverStartedMoving = false;
          isDriverArrived = false;
          isTripStarted = false;
          isNavigationStarted = true;
          if (mounted) setState(() {});
        });
      });
    });
    super.initState();
  }

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
            Image.asset(
              "assets/images/map.png",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            isDriverArrived
                ? Card(
                    shadowColor: dividerColor,
                    elevation: 5,
                    borderOnForeground: true,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Container(
                      // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white),
                      child: Row(
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: navyBlue),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Your ride has arrived",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            isNavigationStarted
                ? Container(
                    // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(color: blackFont),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "500 miles",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text("Head southwest on Madison St",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

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
          isNavigationStarted
              ? Icons.keyboard_arrow_left_sharp
              : isDriverStartedMoving
                  ? Icons.close_rounded
                  : Icons.menu_rounded,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          isDriverStartedMoving = !isDriverStartedMoving;
          setState(() {});
        },
      ),
      title: Text(
        isTripStarted || isNavigationStarted ? "On Trip" : "Arriving",
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: isNavigationStarted
                  ? getNavigationUI()
                  : Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        getDriverInfo(),
                        isDriverStartedMoving
                            ? Column(
                                children: [
                                  SizedBox(height: 10),
                                  getRideInfo(),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        getDriverActions(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ));
  }

  Widget getNavigationUI() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "18 mins / 2.2km",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "20, Pedro Street, Alausa,...",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: darkGrey),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/contact-driver");
                },
                child: ClipOval(
                  child: Container(
                      color: dividerColor,
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.alt_route)),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/payment-options");
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: mateRed, borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Exit",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getDriverInfo() {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: userBloc.user.avatar,
              height: 80,
              width: 80,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ahmad Aminoff",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: darkGrey.withOpacity(0.3)),
                  child: Text(
                    "KRD 770 CK",
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Volkswagen Jetta",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getDriverActions() {
    if (isTripStarted) {
      return getRateDriverBtn();
    }

    if (isDriverArrived) {
      return getContactDriverBtn();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getActionBtn(icon: Icons.call_outlined, onTap: () {}),
          getActionBtn(icon: Icons.message_outlined, onTap: () {}),
          getActionBtn(icon: Icons.close_sharp, onTap: () {}),
        ],
      ),
    );
  }

  Widget getContactDriverBtn() {
    return Row(
      children: [
        Expanded(
          child: CurvedButton(
            borderRadius: 10,
            backgroundColor: navyBlue,
            onPressed: () {},
            textColor: Colors.white,
            text: "Contact driver",
          ),
        ),
        SizedBox(
          width: 8,
        ),
        GestureDetector(
          onTap: () {},
          child: Card(
            elevation: 5,
            borderOnForeground: true,
            shadowColor: dividerColor.withAlpha(125),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 42,
              width: 42,
              child: Center(
                child: Icon(
                  Icons.close_sharp,
                  color: blackFont,
                  size: 28,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getRateDriverBtn() {
    return Row(
      children: [
        Expanded(
          child: CurvedButton(
            borderRadius: 10,
            backgroundColor: navyBlue,
            onPressed: () {},
            textColor: Colors.white,
            text: "Rate driver",
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: MaterialButton(
            color: Colors.white,
            height: 42,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {},
            textColor: blackFont,
            child: Text("Tip driver",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget getActionBtn({IconData icon, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        borderOnForeground: true,
        shadowColor: dividerColor.withAlpha(125),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          height: 70,
          width: 70,
          child: Center(
            child: Icon(
              icon,
              color: blackFont,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget getRideInfo() {
    return Card(
      elevation: 4,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: dividerColor.withAlpha(125),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                SizedBox(
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
            SizedBox(
              width: 12,
            ),
            Image.asset(
              "assets/images/taxi/route.png",
              height: 50,
            ),
            SizedBox(
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
                  SizedBox(
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
}
