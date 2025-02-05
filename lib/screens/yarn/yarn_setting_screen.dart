import 'package:Slydo/main.dart';
import 'package:Slydo/screens/yarn/saved_yarn_screen.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/screens/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/yarn/yarn_list_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'yarn_customize_screen.dart';

class YarnSettingsScreen extends StatefulWidget {
  const YarnSettingsScreen({super.key});

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
      backgroundColor: lightGrey,
      appBar: _buildAppBar(context: context) as PreferredSizeWidget,
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar({required BuildContext context}) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(
        'Yarn Settings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        children: [
          _buildCategoryTile(context),
          _buildNotificationTile(),
          _buildSensitiveContentTile(),
          _buildAdultContentTile(),
          _buildSavedYarn(context),
        ],
      ),
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
            NavigationUtil.push(context, screen: const AskSCustomizeScreen());
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
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: yarnSettingsBloc.pushNotification,
                onChanged: (bool value) async {
                  yarnSettingsBloc.pushNotification = value;

                  await _yarnAuth.updateUserYarnSettings({
                    'allow_notification': yarnSettingsBloc.pushNotification
                  }).catchError((error) {
                    logger.e(error);
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
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
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: yarnSettingsBloc.sensitiveContent,
                onChanged: (bool value) async {
                  yarnSettingsBloc.sensitiveContent = value;
                  await _yarnAuth.updateUserYarnSettings({
                    'allow_sensitive_content': yarnSettingsBloc.sensitiveContent
                  }).catchError((error) {
                    logger.e(error);
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
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
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: yarnSettingsBloc.adultContent,
                onChanged: (bool value) async {
                  yarnSettingsBloc.adultContent = value;
                  await _yarnAuth.updateUserYarnSettings({
                    'allow_adult_content': yarnSettingsBloc.adultContent
                  }).catchError((error) {
                    logger.e(error);
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
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
