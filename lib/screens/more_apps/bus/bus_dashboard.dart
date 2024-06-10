import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/bus/bus_explore_screen.dart';
import 'package:Slydo/screens/more_apps/bus/my_bus_ticket_list.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusDashboard extends StatefulWidget {
  @override
  _BusDashboardState createState() => _BusDashboardState();
}

class _BusDashboardState extends State<BusDashboard> {
  late BusDashboardBloc _busDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _busDashboardBloc = Provider.of<BusDashboardBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          _busDashboardBloc.index = 0;
          return;
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _busDashboardBloc.pageController,
          onPageChanged: (index) {
            _busDashboardBloc.index = index;
          },
          children: <Widget>[
            BusExploreScreen(),
            MyBusTicketList(),
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
        currentIndex: _busDashboardBloc.index,
        onTap: (index) {
          _busDashboardBloc.index = index;
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context)!.explore,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: "My tickets",
          ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {IconData? icon, required String title}) {
    return BottomNavigationBarItem(
      icon: SizedBox(
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
