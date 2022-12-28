import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'ask_customize_screen.dart';

class YarnSettingsScreen extends StatefulWidget {
  YarnSettingsScreen({Key? key}) : super(key: key);

  @override
  State<YarnSettingsScreen> createState() => _YarnSettingsScreenState();
}

class _YarnSettingsScreenState extends State<YarnSettingsScreen> {
  final _yarnAuth = YarnAuth();

  late YarnDashboardBloc? yarnSettingsBloc;
  bool? isAdultSwitch;
  bool? isSensitiveSwitch;

  @override
  void initState() {
    yarnSettingsBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    isAdultSwitch = yarnSettingsBloc?.yarnSettings?.allowAdultContent ?? false;
    isSensitiveSwitch =
        yarnSettingsBloc?.yarnSettings?.allowSensitiveContent ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    yarnSettingsBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    isAdultSwitch = yarnSettingsBloc?.yarnSettings?.allowAdultContent ?? false;
    isSensitiveSwitch =
        yarnSettingsBloc?.yarnSettings?.allowSensitiveContent ?? false;
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
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.keyboard_arrow_left,
          color: Colors.black,
          size: 26,
        ),
      ),
      titleSpacing: 0,
      title: Text(
        "Yarn Settings",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: HexColor("#030F36")),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: [
        _buildCategoryTile(context),
        _buildNotificationTile(),
        _buildSensitiveContentTile(),
        _buildAdultContentTile()
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
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

  Widget _buildSensitiveContentTile() {
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
            "Sensitive Content",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: isSensitiveSwitch!,
            onChanged: (bool value) async{
              isSensitiveSwitch = value;

              var settings = await _yarnAuth.updateUserYarnSettings(
                  {'allow_sensitive_content': isSensitiveSwitch});

              setState(() {
                yarnSettingsBloc?.yarnSettings = settings;
              });
            },
            activeColor: HexColor("#3F61DB"),
            inactiveThumbColor: HexColor("#75818F"),
          ),
        ),
      ),
    );
  }

  Widget _buildAdultContentTile() {
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
            "Adult Content",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: isAdultSwitch!,
            onChanged: (bool value) async {
              isAdultSwitch = value;
              var settings = await _yarnAuth.updateUserYarnSettings(
                  {'allow_adult_content': isAdultSwitch});

              setState(() {
                yarnSettingsBloc?.yarnSettings = settings;
              });
            },
            activeColor: HexColor("#3F61DB"),
            inactiveThumbColor: HexColor("#75818F"),
          ),
        ),
      ),
    );
  }
}
