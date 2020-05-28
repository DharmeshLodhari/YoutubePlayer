//TODO: APP LOCALIZATION
import 'package:Slydo/screens/friends_module/block_list.dart';
import 'package:Slydo/screens/friends_module/contact_request_list.dart';
import 'package:Slydo/screens/friends_module/contacts_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';

import '../colors.dart';

class ContactsDashboard extends StatefulWidget {
  @override
  _ContactsDashboardState createState() => _ContactsDashboardState();
}

class _ContactsDashboardState extends State<ContactsDashboard> {
  int currentIndex = 0;

  //popupmenu variables
  PopupMenu popUpMenuWidget;
  GlobalKey popupMenuBtnKeyForMenu = GlobalKey();
  var filterValue = "Contacts";

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
        textStyle: filterValue == 'Contacts'
            ? TextStyle(color: lightBlue(), fontSize: 10)
            : TextStyle(color: Colors.white, fontSize: 10),
        title: "Contacts",
        image: Icon(
          Icons.group,
          color: filterValue == 'Contacts' ? lightBlue() : Colors.white,
        ),
      ),
    ];

    menuItems.add(
      MenuItem(
          textStyle: filterValue == 'Requests'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: "Requests",
          image: Icon(
            Icons.group_add,
            color: filterValue == 'Requests' ? lightBlue() : Colors.white,
          )),
    );
    menuItems.add(
      MenuItem(
          textStyle: filterValue == 'Blocked'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
          title: "Blocked",
          image: Stack(children: <Widget>[
            Center(
              child: Icon(
                Icons.group,
                color:
                    filterValue == 'Blocked' ? lightBlue() : Colors.grey[100],
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
      if (filterValue == "Contacts") {
        currentIndex = 0;
      } else if (filterValue == "Requests") {
        currentIndex = 1;
      } else if (filterValue == "Blocked") {
        currentIndex = 2;
      }
    });
  }

  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
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
        ContactsList(),
        ContactRequestList(),
        BlockList(),
      ],
    );
  }
}
