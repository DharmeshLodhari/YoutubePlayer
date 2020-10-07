import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:flutter/material.dart';

class InternalApps extends StatefulWidget {
  @override
  _InternalAppsState createState() => _InternalAppsState();
}

class _InternalAppsState extends State<InternalApps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: foregroundScreen(),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: Column(
              children: <Widget>[
                appBar(),
                firstRowOfUserDashboardItem(),
                SizedBox(
                  height: 12,
                ),
                secondRowOfUserDashboardItem(),
                SizedBox(
                  height: 12,
                ),
                thirdRowOfUserDashboardItem(),
                SizedBox(
                  height: 12,
                ),
                forthRowOfUserDashboardItem(),
              ],
            ),
          ),
          flexibleSpace()
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "More Apps",
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

  Widget thirdRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.transport_category,
          title: "Bus",
          onTap: () {},
          iconColor: HexColor("#374677"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.cart,
          title: "Train",
          onTap: () {},
          iconColor: HexColor("#FFAB00"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.store,
          title: "Flight",
          onTap: () {},
          iconColor: HexColor("#46CE7C"),
        )),
      ],
    );
  }

  Widget secondRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.transactions,
          title: "Events",
          onTap: () {},
          iconColor: HexColor("#46CECE"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.holidays_category,
          title: "Hotels",
          onTap: () {},
          iconColor: HexColor("#3F61DB"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.family_category,
          title: "Property",
          onTap: () {},
          iconColor: HexColor("#F35B46"),
        )),
      ],
    );
  }

  Widget firstRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.entertainment_category,
          title: "Movies",
          onTap: () {},
          iconColor: HexColor("#FFAB00"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.general_category,
          title: "Music",
          onTap: () {},
          iconColor: HexColor("#EE78BF"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.general_category,
          title: "News",
          onTap: () {},
          iconColor: HexColor("#46CE7C"),
        )),
      ],
    );
  }

  Widget forthRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.shopping_category,
          title: "Shopping",
          onTap: () {},
          iconColor: HexColor("#F07097"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(child: Container()),
        SizedBox(
          width: 12,
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
