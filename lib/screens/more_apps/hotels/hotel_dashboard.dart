import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hotel_dashboard_bloc.dart';
import 'hotel_explore_screen.dart';
import 'my_hotels_screen.dart';

class HotelDashboard extends StatefulWidget {
  @override
  _HotelDashboardState createState() => _HotelDashboardState();
}

class _HotelDashboardState extends State<HotelDashboard> {
  late HotelDashboardBloc _hotelDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _hotelDashboardBloc = Provider.of<HotelDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        _hotelDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        body: PageView(
          controller: _hotelDashboardBloc.pageController,
          onPageChanged: (index) {
            _hotelDashboardBloc.index = index;
          },
          children: <Widget>[
            HotelExploreScreen(),
            MyHotelsScreen(),
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
        currentIndex: _hotelDashboardBloc.index,
        onTap: (index) {
          _hotelDashboardBloc.index = index;
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context)!.explore,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: "My hotels",
          ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {IconData? icon, required String title}) {
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
  Widget activeIcon({IconData? icon, required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        width: 108,
        color: navyBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
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
