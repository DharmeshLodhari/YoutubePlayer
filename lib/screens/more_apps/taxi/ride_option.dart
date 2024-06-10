import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/screens/more_apps/taxi/taxi_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RideOption extends StatefulWidget {
  @override
  _RideOptionState createState() => _RideOptionState();
}

class _RideOptionState extends State<RideOption> {
  Map<String, dynamic>? selectedRide;

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

  late TaxiBloc taxiBloc;

  bool isLoading = false;

  @override
  void initState() {
    final TaxiBloc taxiBloc =
        Provider.of(myGlobals.navigationKey.currentContext!, listen: false);
    if (taxiBloc.rideDetail != null) {
      isRideSelected = true;
      selectedRide = taxiBloc.rideDetail;
    }

    isLoading = true;
    if (mounted) setState(() {});

    TaxiAuth()
        .getDirections(
            origin: LatLng(taxiBloc.startingPoint!.geometry!.location!.lat!,
                taxiBloc.startingPoint!.geometry!.location!.lng!),
            destination: LatLng(
                taxiBloc.destinationPoint!.geometry!.location!.lat!,
                taxiBloc.destinationPoint!.geometry!.location!.lng!))
        .then((value) {
      taxiBloc.startingPointToDestinationDirections = value;
      isLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    taxiBloc = Provider.of<TaxiBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          taxiBloc.rideDetail = null;
          return;
        }
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
                showStartingPointToDestinationPolyline: true,
              ),
            if (isRideSelected)
              getBottomUI(bookingConfirmation())
            else
              toggleCarOption
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
          taxiBloc.rideDetail = null;
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: const Column(
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
              child: child,
            ),
          ),
        ));
  }

  Widget bookingConfirmation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    selectedRide!["image"],
                    height: 90,
                    width: 120,
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    selectedRide!["name"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter"),
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
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                          color: darkGrey.withAlpha(100),
                          borderRadius: BorderRadius.circular(100)),
                      child: const Text(
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
    );
  }

  Widget getRideSelectionListView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: rideOption.map((ride) {
          return Container(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: GestureDetector(
              onTap: () {
                if (ride["name"] == "Car") {
                  toggleCarOption = !toggleCarOption;
                  if (mounted) setState(() {});
                } else {
                  isRideSelected = true;
                  selectedRide = ride;
                  taxiBloc.rideDetail = ride;
                  if (mounted) setState(() {});
                }
              },
              child: Card(
                shadowColor: dividerColor,
                elevation: 1,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      Image.asset(
                        ride["image"],
                        height: 50,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        ride["name"],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "₦",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter"),
                          ),
                          Text(
                            ride["price"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                          decoration: BoxDecoration(
                              color: darkGrey.withAlpha(100),
                              borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            ride["time"],
                            style: const TextStyle(
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
    );
  }

  Widget getCarSelectionListView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: carOption.map((car) {
          return Container(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: GestureDetector(
              onTap: () {
                isRideSelected = !isRideSelected;
                selectedRide = car;
                taxiBloc.rideDetail = car;
                if (mounted) setState(() {});
              },
              child: Card(
                shadowColor: dividerColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      Image.asset(
                        car["image"],
                        height: 50,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        car["name"],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "₦",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter"),
                          ),
                          Text(
                            car["price"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                          decoration: BoxDecoration(
                              color: darkGrey.withAlpha(100),
                              borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            car["time"],
                            style: const TextStyle(
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
    );
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
