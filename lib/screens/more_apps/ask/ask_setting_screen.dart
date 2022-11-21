import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import 'ask_customize_screen.dart';

class AskSettingsScreen extends StatelessWidget {
  const AskSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar() {
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
          // Navigator.pop(context);
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
        _buildDivider(),
        _buildCategoryTile(context),
        _buildDivider(),
        _buildNotificationTile(),
        _buildDivider(),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context) {
    return _buildListTile(isTrailing: false, onTap: () {
      NavigationUtil.push(context, screen: AskSCustomizeScreen());
    });
  }

  Widget _buildNotificationTile() {
    return _buildListTile(isTrailing: true);
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: HexColor("#EBEDFC"),
    );
  }

  Widget _buildListTile({bool isTrailing = false, GestureTapCallback? onTap}) {
    if (!isTrailing) {
      return ListTile(
        onTap: onTap,
        visualDensity: VisualDensity(vertical: -3, horizontal: 0),
        title: Text(
          "Customize your interest",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      );
    }
    return ListTile(
      visualDensity: VisualDensity(vertical: -3, horizontal: 0),
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
    );
  }
}
