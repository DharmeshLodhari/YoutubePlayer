import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_wish_list.dart';
import 'property_dashboard_bloc.dart';
import 'property_explore_screen.dart';

class PropertyDashboard extends StatefulWidget {
  @override
  _PropertyDashboardState createState() => _PropertyDashboardState();
}

class _PropertyDashboardState extends State<PropertyDashboard> {
  PropertyDashboardBloc _propertyDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _propertyDashboardBloc = Provider.of<PropertyDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        _propertyDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        body: PageView(
          controller: _propertyDashboardBloc.pageController,
          onPageChanged: (index) {
            _propertyDashboardBloc.index = index;
          },
          children: <Widget>[
            PropertyExploreScreen(),
            MyWishList(),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        iconSize: 0,
        unselectedFontSize: 10,
        showSelectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 10,
        currentIndex: _propertyDashboardBloc.index,
        onTap: (index) {
          _propertyDashboardBloc.index = index;
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context).explore,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: "My wishlist",
          ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {IconData icon, String title}) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 50,
        width: 108,
        child: Icon(
          icon,
          color: blackFont,
          size: 16,
        ),
      ),
      label: "",
      activeIcon: activeIcon(icon: icon, title: title),
    );
  }

// How BottomNavigationBarItem will look when active
  Widget activeIcon({IconData icon, String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        width: 108,
        color: navyBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 4,
            ),
            Expanded(
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
