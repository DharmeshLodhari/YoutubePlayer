import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class SelectAddressForTaxi extends StatefulWidget {
  void Function(Map<String, dynamic> place) updateSelectedDestination;
  void Function(bool selectAddress) toggleAddressSelection;

  SelectAddressForTaxi(
      {this.updateSelectedDestination, this.toggleAddressSelection});

  @override
  _SelectAddressForTaxiState createState() => _SelectAddressForTaxiState();
}

class _SelectAddressForTaxiState extends State<SelectAddressForTaxi> {
  double _initialSheetChildSize = 0.9;

  TextEditingController searchDestinationController;

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

  MapController mapController;

  LatLng mapPoint = LatLng(6.605874, 3.349149);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    searchDestinationController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                  child:
                      getSearchDestination(scrollController: scrollController)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getSearchDestination({ScrollController scrollController}) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20),
        child: ListView(
          controller: scrollController,
          children: [
            getDestination(),
            SizedBox(
              height: 36,
            ),
            Row(
              children: [
                Icon(
                  Icons.pin_drop_outlined,
                  color: navyBlue,
                  size: 28,
                ),
                SizedBox(
                  width: 8,
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
            SizedBox(
              height: 24,
            ),
            Text(
              "Recent",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
            ),
            for (int i = 0; i < places.length; i++)
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                  widget.updateSelectedDestination(places[i]);
                  widget.toggleAddressSelection(false);
                },
              ),
          ],
        ));
  }

  Widget getDestination() {
    return Card(
      shadowColor: lightGrey,
      child: Container(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Choose starting point",
                          hintStyle: TextStyle(fontSize: 14, color: darkGrey)),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Choose destination",
                          hintStyle: TextStyle(fontSize: 14, color: darkGrey)),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                    SizedBox(
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
    searchDestinationController?.dispose();
    super.dispose();
  }
}
