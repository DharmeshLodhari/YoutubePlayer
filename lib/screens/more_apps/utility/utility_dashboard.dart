import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/utility/select_provider_screen.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/utility_dashboard_item_tile.dart';
import 'package:flutter/material.dart';

class UtilityDashboard extends StatefulWidget {
  @override
  _UtilityDashboardState createState() => _UtilityDashboardState();
}

class _UtilityDashboardState extends State<UtilityDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
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
                SizedBox(height: 10),
                firstRowItems(),
                secondRowItems(),
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
        "Utility",
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
      actions: [
        utilityHistoryBtn(),
        SizedBox(
          width: 16,
        )
      ],
    );
  }

  Widget utilityHistoryBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.utility_history,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.UTILITY_HISTORY);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget firstRowItems() {
    return Row(
      children: [
        Expanded(
            child: UtilityDashboardItemTile(
          icon: SlydoAppIcon.utility_airtime,
          title: "Airtime",
          providersEnum: UtilitiesProvidersEnum.airtime,
          iconColor: HexColor("#3F61DB"),
          height: 126,
        )),
        SizedBox(width: 12),
        Expanded(
          child: UtilityDashboardItemTile(
            icon: SlydoAppIcon.utility_svg,
            title: "Cable",
            providersEnum: UtilitiesProvidersEnum.cable,
            iconColor: HexColor("#F07097"),
            height: 126,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UtilityDashboardItemTile(
            icon: SlydoAppIcon.utility_electricity,
            title: "Electricity",
            providersEnum: UtilitiesProvidersEnum.electricity,
            iconColor: HexColor("#FFAB00"),
            height: 126,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UtilityDashboardItemTile(
            icon: Icons.tap_and_play_outlined,
            title: "Data",
            providersEnum: UtilitiesProvidersEnum.mobile_data,
            iconColor: navyBlue,
            height: 126,
            titleFontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget secondRowItems() {
    return Row(
      children: [
        Expanded(
            child: UtilityDashboardItemTile(
          icon: SlydoAppIcon.utility_tax,
          title: "Tax",
          providersEnum: UtilitiesProvidersEnum.tax,
          iconColor: HexColor("#46CECE"),
          height: 126,
        )),
        SizedBox(width: 12),
        Expanded(
          child: UtilityDashboardItemTile(
            icon: SlydoAppIcon.utility_betting,
            title: "Betting",
            providersEnum: UtilitiesProvidersEnum.betting,
            iconColor: HexColor("#46CE7C"),
            height: 126,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UtilityDashboardItemTile(
            icon: SlydoAppIcon.utility_toll,
            title: "Toll",
            providersEnum: UtilitiesProvidersEnum.toll,
            iconColor: HexColor("#F35B46"),
            height: 126,
          ),
        ),
        SizedBox(width: 12),
        Expanded(child: Container()),
      ],
    );
  }
}
