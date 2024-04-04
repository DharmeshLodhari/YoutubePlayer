import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/slydo_app_icon_icons.dart';
import '../../widget/bottom_sheet_item.dart';
import 'block_list.dart';
import 'connection_request_list.dart';
import 'connections_list.dart';

class ConnectionDashboard extends StatefulWidget {
  final arguments;

  ConnectionDashboard({this.arguments});

  @override
  _ConnectionDashboardState createState() => _ConnectionDashboardState();
}

class _ConnectionDashboardState extends State<ConnectionDashboard> {
  int currentIndex = 0;

  var filterValue = "Friends";
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    if (widget.arguments != null) {
      currentIndex = widget.arguments["index"] ?? 0;
    }

    getConnectionRequest();

    super.initState();
  }

  void getConnectionRequest() async {
    final Map<String, dynamic>? result =
        await UserAuth().listContactRequests('', '').catchError((error) {
      debugPrint("ERROR:- $error");
      //  return;
    });

    if (result == null) return;
    final List connectionRequest = result['results'] as List;

    Provider.of<ConnectionRequestListBloc>(context, listen: false)
        .setHasConnectionRequests = connectionRequest.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (filterValue == 'Connections') filterValue = "Friends";
    appLocalization = AppLocalization.of(context)!;
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar() as PreferredSizeWidget?,
            body: tabViews(),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 22,
      title: Text(
        getTitle(),
        style: TextStyle(
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      actions: getActions(),
      bottom: tabBar() as PreferredSizeWidget?,
    );
  }

  // ignore: missing_return
  String getTitle() {
    if (currentIndex == 0) {
      return AppLocalization.of(context)!.friends;
    } else if (currentIndex == 1) {
      return AppLocalization.of(context)!.requests;
    } else if (currentIndex == 2) {
      return AppLocalization.of(context)!.blocked;
    }
    return "";
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.friends,
                style: TextStyle(
                  color: currentIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight:
                      currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appLocalization.requests,
                    style: TextStyle(
                      color: currentIndex == 1 ? navyBlue : blackFont,
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight:
                          currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (Provider.of<ConnectionRequestListBloc>(context)
                      .hasConnectionRequests)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.only(),
                        child: badges.Badge(
                          badgeContent: const Center(
                            child: Text(
                              '++',
                              style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 12,
                                  color: Colors.white),
                            ),
                          ),
                          position: badges.BadgePosition.topEnd(end: 0, top: 0),
                          badgeAnimation: const badges.BadgeAnimation.rotation(
                            animationDuration: Duration(seconds: 1),
                            colorChangeAnimationDuration: Duration(seconds: 1),
                            loopAnimation: false,
                            curve: Curves.fastOutSlowIn,
                            colorChangeAnimationCurve: Curves.easeInCubic,
                          ),
                          badgeStyle: badges.BadgeStyle(
                            shape: badges.BadgeShape.circle,
                            badgeColor: naturalGreen,
                            padding: const EdgeInsets.all(2),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink()
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 2
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.blocked,
                style: TextStyle(
                  color: currentIndex == 2 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight:
                      currentIndex == 2 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showUserProfileActionsSheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

    list.add(bottomSheetItem(
      title: "Create Group",
      iconData: SlydoAppIcon.add_group,
      onTap: () async {
        Navigator.pop(context);
        if (appConfigurationModel != null &&
            appConfigurationModel!.enableGroupChat == true) {
          Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
              arguments: {"create": "group"});
        }
      },
    ));

    list.add(
      bottomSheetItem(
        title: "Create Channel",
        iconData: SlydoAppIcon.add_channel,
        onTap: () async {
          Navigator.pop(context);
          if (appConfigurationModel != null &&
              appConfigurationModel!.enableGroupChat == true) {
            Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
                arguments: {"create": "channel"});
          }
        },
      ),
    );

    return list;
  }

  List<Widget> getActions() {
    final List<Widget> list = [
      ///TODO:- To be enabled in future version
      // synchronizeContactBtn(),
      // SizedBox(
      //   width: 8
      // ),
      if (currentIndex == 0) menuBtn() else const SizedBox.shrink(),
      // currentIndex == 0 ? createGroupBtn() : SizedBox.shrink(),
      const SizedBox(width: 16),
    ];

    return list;
  }

  Widget createGroupBtn() {
    if (appConfigurationModel != null &&
        appConfigurationModel!.enableGroupChat == true) {
      return RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          Icons.group_add,
          size: 20,
          color: blackFont,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP);
        },
        backgroundColor: lightGrey,
        enableMargin: true,
      );
    }

    return const SizedBox.shrink();
  }

  Widget synchronizeContactBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        Icons.sync,
        size: 24,
        color: blackFont,
      ),
      onTap: () async {
        await ChatMessageSynchronizer().syncMessages(fetchFresh: true);
      },
      backgroundColor: lightGrey,
      enableMargin: true,
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        ConnectionList(),
        ConnectionRequestList(),
        BlockedList(),
      ],
    );
  }
}
