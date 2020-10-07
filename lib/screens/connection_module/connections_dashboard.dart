import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import 'block_list.dart';
import 'connection_request_list.dart';
import 'connections_list.dart';

class ConnectionDashboard extends StatefulWidget {
  @override
  _ConnectionDashboardState createState() => _ConnectionDashboardState();
}

class _ConnectionDashboardState extends State<ConnectionDashboard> {
  int currentIndex = 0;

  var filterValue = "Connections";

  @override
  Widget build(BuildContext context) {
    if (filterValue == 'Connections') filterValue = "Connections";

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: appBar(),
          body: tabViews(),
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
      title: Text(
        getTitle(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar(),
    );
  }

  String getTitle() {
    if (currentIndex == 0) {
      return "Connections";
    } else if (currentIndex == 1) {
      return AppLocalization.of(context).requests;
    }
    return AppLocalization.of(context).blocked;
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
                "Connections",
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
                AppLocalization.of(context).requests,
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
                AppLocalization.of(context).blocked,
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

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        ConnectionList(),
        ConnectionRequestList(),
        BlockList(),
      ],
    );
  }
}
