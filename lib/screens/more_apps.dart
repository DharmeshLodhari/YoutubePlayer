import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:flutter/material.dart';

class MoreApps extends StatefulWidget {
  @override
  _MoreAppsState createState() => _MoreAppsState();
}

class _MoreAppsState extends State<MoreApps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: foregroundScreen(),
    );
  }

  Widget foregroundScreen() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(left: 16, right: 16),
              children: [
                SizedBox(
                  height: 12,
                ),
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
                SizedBox(
                  height: 12,
                ),
                fifthRowOfUserDashboardItem(),
              ],
            ),
          ),
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

  Widget firstRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.utility,
          title: "Utility",
          onTap: () {
            Navigator.pushNamed(context, "/utility-dashboard");
          },
          iconColor: HexColor("#FFAB00"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.music_moreapps,
          title: "Music",
          onTap: () {
            Navigator.of(context).pushNamed("/musics");
          },
          iconColor: HexColor("#FFAB00"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.news_moreapps,
          title: "News",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ),
            );
            Navigator.of(context).popAndPushNamed("/news");
          },
          iconColor: HexColor("#46CE7C"),
          height: 126,
        )),
      ],
    );
  }

  Widget secondRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.events_moreapps,
          title: "Events",
          onTap: () {
            Navigator.of(context).pushNamed("/events");
          },
          iconColor: HexColor("#46CECE"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.hotels_moreapps,
          title: "Hotels",
          onTap: () {
            Navigator.of(context).pushNamed("/hotels");
          },
          iconColor: HexColor("#F35B46"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.property_moreapps,
          title: "Property",
          onTap: () {
            Navigator.of(context).pushNamed("/property");
          },
          iconColor: HexColor("#3F61DB"),
          height: 126,
        )),
      ],
    );
  }

  Widget thirdRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.transport_category,
          title: "Bus",
          onTap: () {
            Navigator.of(context).pushNamed("/bus");
          },
          iconColor: HexColor("#374677"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.train_moreapps,
          title: "Train",
          onTap: () {
            Navigator.of(context).pushNamed("/train");
          },
          iconColor: HexColor("#46CE7C"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.flight_moreapps,
          title: "Flight",
          onTap: () {
            Navigator.of(context).pushNamed("/flight");
          },
          iconColor: HexColor("#F07097"),
          height: 126,
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
          onTap: () {
            Navigator.of(context).pushNamed("/shopping");
          },
          iconColor: HexColor("#5218E9"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.eatingout_category,
          title: "Eat out",
          onTap: () {},
          iconColor: HexColor("#F35B46"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.wealth_moreapps,
          title: "Wealth",
          onTap: () {},
          iconColor: HexColor("#FFC42E"),
          height: 126,
        )),
      ],
    );
  }

  Widget fifthRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.movies_moreapps,
          title: "Movies",
          onTap: () {
            Navigator.of(context).pushNamed("/movies");
          },
          iconColor: HexColor("#9B51E0"),
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: Container(
          height: 126,
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: Container(
          height: 126,
        )),
      ],
    );
  }
}
