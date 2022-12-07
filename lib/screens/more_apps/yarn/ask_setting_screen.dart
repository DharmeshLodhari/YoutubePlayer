import 'package:flutter/material.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'ask_customize_screen.dart';

class AskSettingsScreen extends StatelessWidget {
  const AskSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context: context) as PreferredSizeWidget,
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar({required BuildContext context}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Settings",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: HexColor("#030F36")
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: [
        _buildCategoryTile(context),
        _buildNotificationTile(),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          onTap: () {
            NavigationUtil.push(context, screen: AskSCustomizeScreen());
          },
          visualDensity: VisualDensity(vertical: 0, horizontal: 0),
          title: Text(
            "Customize your interest",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_outlined,
            color: blackFont,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          visualDensity: VisualDensity(vertical: 0, horizontal: 0),
          title: Text(
            "Push Notification",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {},
            activeColor: HexColor("#3F61DB"),
            inactiveThumbColor: HexColor("#75818F"),
          ),
        ),
      ),
    );
  }
}
