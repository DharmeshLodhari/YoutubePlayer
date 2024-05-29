import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/screens/more_apps/taxi/model/PlaceModal.dart';
import 'package:Slydo/screens/more_apps/taxi/taxi_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SelectAddressScreen extends StatefulWidget {
  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  TextEditingController? chooseDestinationPointController;
  TextEditingController? chooseStartingPointController;

  List<PlaceModal> searchedPlaces = [];
  bool isLoading = false;

  List<PlaceModal> recentPlaces = [];

  FocusNode startingLocation = FocusNode();
  FocusNode destinationLocation = FocusNode();

  late TaxiBloc taxiBloc;

  @override
  void initState() {
    super.initState();
    recentPlaces = TaxiAuth().getFakePlaces();
    chooseDestinationPointController = TextEditingController();
    chooseStartingPointController = TextEditingController();
  }

  void searchPlaces({String? query}) async {
    isLoading = true;
    if (mounted) setState(() {});

    TaxiAuth().searchPlaces(place: query).then((value) {
      searchedPlaces = value as List<PlaceModal>;
      isLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("ERROR:- $error");
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    taxiBloc = Provider.of<TaxiBloc>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: Stack(
          children: [MapUI(), getBottomUI(getSearchDestination())],
        ),
      ),
    );
  }

  Widget getSearchDestination() {
    return Container(
        // padding: EdgeInsets.only(left: 16, right: 16, top: 8),
        constraints: BoxConstraints(maxHeight: 80.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              width: 12.0.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: blackFont.withOpacity(0.08),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            getDestination(),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Image.asset(
                  "assets/images/location_pin.png",
                  height: 40,
                  width: 40,
                ),
                Text(
                  "Show on a map",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: navyBlue),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              searchedPlaces.isEmpty ? "Recent" : "Result",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...getSearchedResult()],
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> getSearchedResult() {
    final List<Widget> items = [];

    if (isLoading) {
      items.add(SizedBox(
        height: 20.0.h,
        child: Center(
          child: CircularLoadingIndicator(),
        ),
      ));
      return items;
    }

    if (searchedPlaces.isEmpty) {
      for (int i = 0; i < recentPlaces.length; i++) {
        items.add(getPlaceTile(place: recentPlaces[i]));
      }
    } else {
      for (int i = 0; i < searchedPlaces.length; i++) {
        items.add(getPlaceTile(place: searchedPlaces[i]));
      }
    }

    return items;
  }

  Widget getPlaceTile({required PlaceModal place}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
        place.name!,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.w400, fontSize: 16),
      ),
      subtitle: Text(place.formattedAddress!),
      onTap: () {
        if (taxiBloc.startingPoint == null) {
          taxiBloc.startingPoint = place;

          if (mounted) setState(() {});

          chooseStartingPointController!.text = place.name!;
          startingLocation.unfocus();
          // destinationLocation.requestFocus();
        } else {
          taxiBloc.destinationPoint = place;
          Navigator.pop(context);
        }
      },
    );
  }

  Widget getDestination() {
    return Card(
      shadowColor: dividerColor,
      borderOnForeground: true,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.asset(
                  "assets/images/taxi/route.png",
                  height: 100,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Choose starting point",
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: darkGrey,
                              fontWeight: FontWeight.w400)),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                      controller: chooseStartingPointController,
                      focusNode: startingLocation,
                      onChanged: (value) {
                        searchPlaces(query: value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Choose destination",
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: darkGrey,
                              fontWeight: FontWeight.w400)),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                      controller: chooseDestinationPointController,
                      focusNode: destinationLocation,
                      onChanged: (value) {
                        searchPlaces(query: value);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            ],
          ),
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
        "Select address",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getRideOptions() {
    return Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          // controller: scrollController,
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
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

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/search-driver",
            arguments: {"currentChild": SelectAddressScreen()});
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Set destination location",
    );
  }

  @override
  void dispose() {
    chooseStartingPointController?.dispose();
    chooseDestinationPointController?.dispose();
    super.dispose();
  }
}
