import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';

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

  //popupmenu variables
  PopupMenu popUpMenuWidget;
  GlobalKey popupMenuBtnKeyForMenu = GlobalKey();
  var filterValue = "Connections";

  void popUpMenu() {
    popUpMenuWidget = PopupMenu(
      context: context,
      items: getMenuItems(),
      onClickMenu: onClickMenu,
      onDismiss: onDismiss,
      maxColumn: 4,
    );
    popUpMenuWidget.show(widgetKey: popupMenuBtnKeyForMenu);
  }

  List<MenuItem> getMenuItems() {
    var menuItems = [
      MenuItem(
        textStyle: filterValue == "Connections"
            ? TextStyle(color: lightBlue(), fontSize: 10)
            : TextStyle(color: Colors.white, fontSize: 10),
        title: "Connections",
        image: Icon(
          Icons.group,
          color: filterValue == "Connections" ? lightBlue() : Colors.white,
        ),
      ),
    ];

    menuItems.add(
      MenuItem(
          textStyle: filterValue == AppLocalization.of(context).requests
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: AppLocalization.of(context).requests,
          image: Icon(
            Icons.group_add,
            color: filterValue == AppLocalization.of(context).requests
                ? lightBlue()
                : Colors.white,
          )),
    );
    menuItems.add(
      MenuItem(
          textStyle: filterValue == AppLocalization.of(context).blocked
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
          title: AppLocalization.of(context).blocked,
          image: Stack(children: <Widget>[
            Center(
              child: Icon(
                Icons.group,
                color: filterValue == AppLocalization.of(context).blocked
                    ? lightBlue()
                    : Colors.grey[100],
              ),
            ),
            Center(
              child: Icon(
                Icons.block,
                color: Colors.red,
              ),
            ),
          ])),
    );

    return menuItems;
  }

  void stateChanged(bool isShow) {
    debugPrint('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    setState(() {
      filterValue = item.menuTitle;
      if (filterValue == "Connections") {
        currentIndex = 0;
      } else if (filterValue == AppLocalization.of(context).requests) {
        currentIndex = 1;
      } else if (filterValue == AppLocalization.of(context).blocked) {
        currentIndex = 2;
      }
    });
  }

  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
    if (filterValue == 'Connections') filterValue = "Connections";

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          titleSpacing: 0,
          title: Text(
            filterValue,
            maxLines: 1,
          ),
          actions: <Widget>[
            IconButton(
              key: popupMenuBtnKeyForMenu,
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
                popUpMenu();
              },
            )
          ],
        ),
        body: tabViews(),
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
