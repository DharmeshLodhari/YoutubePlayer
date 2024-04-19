import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/screens/more_apps/taxi/taxi_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ArrivingDriver extends StatefulWidget {
  @override
  _ArrivingDriverState createState() => _ArrivingDriverState();
}

class _ArrivingDriverState extends State<ArrivingDriver> {
  bool isSearchingForDriver = false;

  bool isDriverStartedMoving = false;
  bool isDriverArrived = false;
  bool isTripStarted = false;
  bool isNavigationStarted = false;

  bool isLoading = false;

  bool startRide = false;

  Key key = const Key("map");

  @override
  void initState() {
    // getExistingMapStatus();

    // Future.delayed(Duration(seconds: 5)).then((value) {
    //   isDriverStartedMoving = false;
    //   isDriverArrived = true;
    //   if (mounted) setState(() {});
    //   Future.delayed(Duration(seconds: 5)).then((value) {
    //     isDriverStartedMoving = false;
    //     isDriverArrived = false;
    //     isTripStarted = true;
    //
    //     if (mounted) setState(() {});
    //     Future.delayed(Duration(seconds: 5)).then((value) {
    //       isDriverStartedMoving = false;
    //       isDriverArrived = false;
    //       isTripStarted = false;
    //       isNavigationStarted = true;
    //       if (mounted) setState(() {});
    //     });
    //   });
    // });
    Future.delayed(const Duration(seconds: 5)).then((value) {
      isDriverStartedMoving = false;
      isDriverArrived = false;
      isTripStarted = false;
      isNavigationStarted = true;
      startRide = true;
      if (mounted) setState(() {});
      debugPrint("startRide :- $startRide");
    });

    super.initState();
  }

  void getExistingMapStatus() {
    final TaxiBloc taxiBloc =
        Provider.of(myGlobals.navigationKey.currentContext!, listen: false);
    TaxiAuth()
        .getDirections(
      origin: LatLng(taxiBloc.startingPoint!.geometry!.location!.lat! - 0.0015,
          taxiBloc.startingPoint!.geometry!.location!.lng!),
      destination: LatLng(taxiBloc.startingPoint!.geometry!.location!.lat!,
          taxiBloc.startingPoint!.geometry!.location!.lng!),
    )
        .then((value) {
      taxiBloc.driverToStartingPointDirections = value;
      isLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
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
        appBar: appBar() as PreferredSizeWidget?,
        body: Stack(
          children: [
            if (isLoading)
              Center(child: CircularLoadingIndicator())
            else
              MapUI(
                key: UniqueKey(),
                showRideToStartingPointPolyline: false,
                showStartingPointToDestinationPolyline: true,
                startRide: startRide,
              ),
            if (isDriverArrived)
              Card(
                shadowColor: dividerColor,
                elevation: 5,
                borderOnForeground: true,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        "Your ride has arrived",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(),

            if (isNavigationStarted)
              Container(
                // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: blackFont),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            "500 miles",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text("Head southwest on Madison St",
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
            else
              Container(),

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
          isDriverStartedMoving
              ? Icons.close_rounded
              : Icons.keyboard_arrow_left_sharp,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          isDriverStartedMoving = !isDriverStartedMoving;
          setState(() {});
          Navigator.of(context).pop();
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
              child: isNavigationStarted
                  ? getNavigationUI()
                  : Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        getDriverInfo(),
                        if (isDriverStartedMoving)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              getRideInfo(),
                            ],
                          )
                        else
                          Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        getDriverActions(),
                        const SizedBox(
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
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
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.alt_route)),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/payment-options");
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: mateRed, borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: const Text(
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
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: userBloc.user.avatar!,
              height: 80,
              width: 80,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
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
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                const SizedBox(
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
        const SizedBox(
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
        const SizedBox(
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

  Widget getActionBtn({IconData? icon, Function? onTap}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
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
}
