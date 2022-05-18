import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/slydo_app_icon_icons.dart';
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

  var filterValue = "Contacts";

  @override
  void initState() {
    if (widget.arguments != null) {
      currentIndex = widget.arguments["index"] ?? 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (filterValue == 'Connections') filterValue = "Contacts";

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
      leading: SizedBox.shrink(),
      leadingWidth: 22,
      title: Text(
        getTitle(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
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
      return "Contacts";
    } else if (currentIndex == 1) {
      return AppLocalization.of(context)!.requests;
    } else if (currentIndex == 2) {
      return AppLocalization.of(context)!.blocked;
    }
    return "";
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "My Contacts",
                style: TextStyle(
                  color: currentIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                AppLocalization.of(context)!.requests,
                style: TextStyle(
                  color: currentIndex == 1 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 2
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                AppLocalization.of(context)!.blocked,
                style: TextStyle(
                  color: currentIndex == 2 ? navyBlue : blackFont,
                  fontSize: 14,
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

  List<Widget> getActions() {
    List<Widget> list = [
      ///TODO:- To be enabled in future version
      // synchronizeContactBtn(),
      // SizedBox(
      //   width: 8
      // ),
      currentIndex == 0 ? createGroupBtn() : SizedBox.shrink(),
      SizedBox(width: 16),
    ];

    return list;
  }

  Widget createGroupBtn() {
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
