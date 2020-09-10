import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/user_profile_module/user_info.dart';
import 'package:Slydo/screens/user_profile_module/user_product_list.dart';
import 'package:Slydo/screens/user_profile_module/user_service_list.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

// ignore: must_be_immutable
class UserProfile extends StatefulWidget {
  var arguments;
  UserProfile({@required this.arguments});
  @override
  _UserProfileState createState() => _UserProfileState(arguments: arguments);
}

class _UserProfileState extends State<UserProfile> {
  var arguments;
  _UserProfileState({this.arguments});
  int currentIndex = 0;
  CustomerProfile searchedUser;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;
  double top;

  //popupmenu variables
  PopupMenu popUpMenuWidget;
  GlobalKey popupMenuBtnKeyForMenu = GlobalKey();
  var filterValue = "Info";

  @override
  void initState() {
    searchedUser = arguments['searchedUser'];
    if (mounted) {
      setState(() {
        currentIndex = arguments['index'] ?? 0;
        if (currentIndex == 0) {
          filterValue = "Info";
        } else if (currentIndex == 1) {
          filterValue = "Products";
        } else if (currentIndex == 2) {
          filterValue = "Services";
        }
      });
    }

    super.initState();
  }

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
          textStyle: filterValue == 'Info'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: AppLocalization.of(context).info,
          image: Icon(
            Icons.computer,
            color: filterValue == 'Info' ? lightBlue() : Colors.white,
          )),
    ];

    menuItems.add(
      MenuItem(
          textStyle: filterValue == 'Products'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: AppLocalization.of(context).products,
          image: Icon(
            Icons.computer,
            color: filterValue == 'Products' ? lightBlue() : Colors.white,
          )),
    );

    if (userBloc.user.setting.enableService) {
      menuItems.add(
        MenuItem(
            textStyle: filterValue == 'Services'
                ? TextStyle(color: lightBlue(), fontSize: 10)
                : TextStyle(color: Colors.white, fontSize: 10),
            title: AppLocalization.of(context).services,
            image: Icon(
              Icons.burst_mode,
              color: filterValue == 'Services' ? lightBlue() : Colors.white,
            )),
      );
    }

    return menuItems;
  }

  void stateChanged(bool isShow) {
    debugPrint('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    if (mounted) {
      setState(() {
        filterValue = item.menuTitle;
        if (filterValue == "Info") {
          currentIndex = 0;
        } else if (filterValue == "Products") {
          currentIndex = 1;
        } else if (filterValue == "Services") {
          currentIndex = 2;
        }
      });
    }
  }

  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    if (userBloc.user.userName == searchedUser.userName) {
      isOwner = true;
    }

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
          searchedUser = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        searchedUser.fullName,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar(),
      actions: <Widget>[
        IconButton(
          key: popupMenuBtnKeyForMenu,
          icon: Icon(
            Icons.more_vert,
            color: navyBlue,
          ),
          onPressed: () {
            popUpMenu();
          },
        ),
        SizedBox(
          width: 8,
        ),
        shareProfileIcon(),
        SizedBox(
          width: 16,
        ),
      ],
    );
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
                "Information",
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
                "Products",
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
                "Services",
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

  Widget shareProfileIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        var shareBody = "${searchedUser.fullName}\n" +
            "http://slydo.co/user/" +
            searchedUser.userName;
        Share.share(shareBody, subject: "${searchedUser.fullName}");
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  List<Widget> actionButtons() {
    return [
      !isOwner
          ? IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          : Container(),
      !isOwner
          ? IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/compose_message', arguments: {
                  'recipient': searchedUser.userName,
                  'subject': "",
                });
              },
            )
          : Container()
    ];
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        UserInfo(user: searchedUser),
        UserProductList(
          user: searchedUser,
          isOwner: isOwner,
        ),
        UserServiceList(
          user: searchedUser,
          isOwner: isOwner,
        ),

        // productsList(),
        // servicesList(),
      ],
    );
  }
}
