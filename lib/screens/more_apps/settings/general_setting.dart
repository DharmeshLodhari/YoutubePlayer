import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_message_settings.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class GeneralSettingScreen extends StatefulWidget {
  @override
  _GeneralSettingScreenState createState() => _GeneralSettingScreenState();
}

class _GeneralSettingScreenState extends State<GeneralSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldGeneralSettingKey =
      new GlobalKey<ScaffoldState>();

  bool isLoading = false;

  UserBloc userBloc;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @protected
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      key: _scaffoldGeneralSettingKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getChatSettingTitle(),
                SizedBox(
                  height: 8,
                ),
                getIncomingSoundTile(),
                getOutGoingSoundTile(),
              ],
            ),
          ),
        )),
        _infoTile(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget getChatSettingTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Chat Settings",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _infoTile() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalization.of(context).appVersion +
                ': ' +
                _packageInfo.version +
                " (${_packageInfo.buildNumber})",
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
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
      centerTitle: false,
      title: Text(
        "Settings",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getIncomingSoundTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Incoming Message Sound",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: userBloc.chatMessageSettings.playIncomingMessageSound,
              onChanged: (value) {
                ChatMessageSettings chatMessageSettings = ChatMessageSettings();
                chatMessageSettings.playOutgoingMessageSound =
                    userBloc.chatMessageSettings.playOutgoingMessageSound;
                chatMessageSettings.playIncomingMessageSound = value;
                userBloc.chatMessageSettings = chatMessageSettings;
                DatabaseHelper()
                    .updateGeneralSettings(chatMessageSettings.toDBJson());
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getOutGoingSoundTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Outgoing Message Sound",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: userBloc.chatMessageSettings.playOutgoingMessageSound,
              onChanged: (value) {
                ChatMessageSettings chatMessageSettings = ChatMessageSettings();
                chatMessageSettings.playIncomingMessageSound =
                    userBloc.chatMessageSettings.playIncomingMessageSound;
                chatMessageSettings.playOutgoingMessageSound = value;
                userBloc.chatMessageSettings = chatMessageSettings;
                DatabaseHelper()
                    .updateGeneralSettings(chatMessageSettings.toDBJson());
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
