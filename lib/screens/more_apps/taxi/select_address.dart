import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SelectAddressForTaxi extends StatefulWidget {
  final void Function(Map<String, dynamic> place)? updateSelectedDestination;
  final void Function(bool selectAddress)? toggleAddressSelection;

  SelectAddressForTaxi(
      {this.updateSelectedDestination, this.toggleAddressSelection});

  @override
  _SelectAddressForTaxiState createState() => _SelectAddressForTaxiState();
}

class _SelectAddressForTaxiState extends State<SelectAddressForTaxi> {
  final double _initialSheetChildSize = 0.9;

  TextEditingController? chooseDestinationPointController;
  TextEditingController? chooseStartingPointController;

  List<Map<String, dynamic>> places = [
    {"name": "Agege Post Office, Agege,", "place": "Lagos"},
    {"name": "101, Lagos-Ikorodu Expressway,", "place": "Lagos"},
    {"name": "67, Mobolaji Bank Anthony Way,", "place": "Ikeja"},
    {"name": "Ikeja City Mall, Alausa", "place": "Ikeja"},
    {"name": "101, Lagos-Ikorodu Expressway,", "place": "Lagos"},
    {"name": "67, Mobolaji Bank Anthony Way,", "place": "Ikeja"},
    {"name": "Agege Post Office, Agege,", "place": "Lagos"},
    {"name": "101, Lagos-Ikorodu Expressway,", "place": "Lagos"},
    {"name": "67, Mobolaji Bank Anthony Way,", "place": "Ikeja"},
  ];

  @override
  void initState() {
    super.initState();
    chooseDestinationPointController = TextEditingController();
    chooseStartingPointController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/map.png",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        // MapUI(),
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (DraggableScrollableNotification notification) {
            return;
          } as bool Function(DraggableScrollableNotification)?,
          child: DraggableScrollableSheet(
            initialChildSize: _initialSheetChildSize,
            maxChildSize: _initialSheetChildSize,
            minChildSize: _initialSheetChildSize,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  color: Colors.white,
                  child:
                      getSearchDestination(scrollController: scrollController)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getSearchDestination({ScrollController? scrollController}) {
    return Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
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
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
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
                    "Recent",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: darkGrey),
                  ),
                  for (int i = 0; i < places.length; i++)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
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
                        widget.updateSelectedDestination!(places[i]);
                        widget.toggleAddressSelection!(false);
                      },
                    ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget getDestination() {
    return Card(
      shadowColor: dividerColor,
      borderOnForeground: true,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
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

  @override
  void dispose() {
    chooseDestinationPointController?.dispose();
    super.dispose();
  }
}
