import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:flutter/material.dart';

import '../routes/route_constants.dart';

class MoreApps extends StatefulWidget {
  const MoreApps({super.key});

  @override
  State<MoreApps> createState() => _MoreAppsState();
}

class _MoreAppsState extends State<MoreApps> {
  List<Widget> dashboardItems = [];

  static const double GRID_ITEM_HEIGHT = 126;

  @override
  void initState() {
    initializeDashBoardItem();
    super.initState();
  }

  void initializeDashBoardItem() {
    dashboardItems.addAll([
      UserDashboardItemTile(
        icon: SlydoAppIcon.moviesMoreApps,
        title: "Movies",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.MOVIES);
        },
        iconColor: HexColor("#9B51E0"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.musicMoreApps,
        title: "Music",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.MUSICS);
        },
        iconColor: HexColor("#FFAB00"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.eventsMoreApps,
        title: "Events",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.EVENTS);
        },
        iconColor: HexColor("#46CECE"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.hotelsMoreApps,
        title: "Hotels",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.HOTELS);
        },
        iconColor: HexColor("#F35B46"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.propertyMoreApps,
        title: "Property",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.PROPERTY);
        },
        iconColor: HexColor("#3F61DB"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.transportCategory,
        title: "Bus",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.BUS);
        },
        iconColor: HexColor("#374677"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.trainMoreApps,
        title: "Train",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.TRAIN);
        },
        iconColor: HexColor("#46CE7C"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.flightMoreApps,
        title: "Flight",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.FLIGHT);
        },
        iconColor: HexColor("#F07097"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: Icons.directions_car_rounded,
        title: "Ride",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.TAXI);
        },
        iconColor: HexColor("#FFC42E"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.eatingoutCategory,
        title: "Eat out",
        onTap: () {},
        iconColor: HexColor("#F35B46"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.shoppingCategory,
        title: "Shopping",
        onTap: () {
          Navigator.of(context).pushNamed(Routes.SUPER_STORE);
        },
        iconColor: HexColor("#5218E9"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.newsMoreApps,
        title: "News",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ),
          );
          Navigator.of(context).popAndPushNamed(Routes.NEWS);
        },
        iconColor: HexColor("#46CE7C"),
        height: GRID_ITEM_HEIGHT,
      ),
      UserDashboardItemTile(
        icon: SlydoAppIcon.wealthMoreApps,
        title: "Wealth",
        onTap: () {},
        iconColor: HexColor("#FFC42E"),
        height: GRID_ITEM_HEIGHT,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar() as PreferredSizeWidget?,
      body: foregroundScreen(),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: SingleChildScrollView(
        child: Column(
          children: getUserDashboardItem(),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "More apps",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  List<Widget> getUserDashboardItem() {
    final List<Widget> items = [];

    for (int i = 0; i < dashboardItems.length; i = i + 3) {
      items.add(Column(
        children: [
          Row(
            children: [
              Expanded(child: dashboardItems[i]),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                  child: i + 1 < dashboardItems.length
                      ? dashboardItems[i + 1]
                      : Container(
                          height: GRID_ITEM_HEIGHT,
                        )),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                  child: i + 2 < dashboardItems.length
                      ? dashboardItems[i + 2]
                      : Container(
                          height: GRID_ITEM_HEIGHT,
                        )),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ));
    }
    return items;
  }
}
