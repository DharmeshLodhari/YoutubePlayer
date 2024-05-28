import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/yarn/saved_yarn_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'yarn_customize_screen.dart';

class YarnSettingsScreen extends StatefulWidget {
  YarnSettingsScreen({Key? key}) : super(key: key);

  @override
  State<YarnSettingsScreen> createState() => _YarnSettingsScreenState();
}

class _YarnSettingsScreenState extends State<YarnSettingsScreen> {
  final _yarnAuth = YarnAuth();

  late YarnDashboardBloc yarnSettingsBloc;
  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    yarnSettingsBloc = Provider.of<YarnDashboardBloc>(context);
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
        child: const Icon(
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
        _buildAdultContentTile(),
        _buildSavedYarn(context),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          onTap: () {
            NavigationUtil.push(context, screen: AskSCustomizeScreen());
          },
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: const Text(
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: const Text(
            "Push Notification",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: yarnSettingsBloc.pushNotification,
            onChanged: (bool value) async {
              yarnSettingsBloc.pushNotification = value;

              await _yarnAuth.updateUserYarnSettings({
                'allow_notification': yarnSettingsBloc.pushNotification
              }).catchError((error) {
                logger.e(error);
              });
            },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: const Text(
            "Sensitive Content",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: yarnSettingsBloc.sensitiveContent,
            onChanged: (bool value) async {
              yarnSettingsBloc.sensitiveContent = value;
              await _yarnAuth.updateUserYarnSettings({
                'allow_sensitive_content': yarnSettingsBloc.sensitiveContent
              }).catchError((error) {
                logger.e(error);
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: const Text(
            "Adult Content",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Switch(
            value: yarnSettingsBloc.adultContent,
            onChanged: (bool value) async {
              yarnSettingsBloc.adultContent = value;
              await _yarnAuth.updateUserYarnSettings({
                'allow_adult_content': yarnSettingsBloc.adultContent
              }).catchError((error) {
                logger.e(error);
              });
            },
            activeColor: HexColor("#3F61DB"),
            inactiveThumbColor: HexColor("#75818F"),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedYarn(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          onTap: () {
            NavigationUtil.push(context,
                screen: SavedYarn(
                  key: topicViewStateKey,
                  selectedCategory: selectedCategoryId,
                ));
          },
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: const Text(
            "Saved Yarn",
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
}
