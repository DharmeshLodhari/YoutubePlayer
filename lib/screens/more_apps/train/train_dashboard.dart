import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/train/my_train_ticket_list.dart';
import 'package:Slydo/screens/more_apps/train/train_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/train/train_explore_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrainDashboard extends StatefulWidget {
  const TrainDashboard({super.key});

  @override
  State<TrainDashboard> createState() => _TrainDashboardState();
}

class _TrainDashboardState extends State<TrainDashboard> {
  late TrainDashboardBloc _trainDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _trainDashboardBloc = Provider.of<TrainDashboardBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _trainDashboardBloc.index = 0;
          return;
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _trainDashboardBloc.pageController,
          onPageChanged: (index) {
            _trainDashboardBloc.index = index;
          },
          children: const <Widget>[
            TrainExploreScreen(),
            MyTrainTicketList(),
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
        currentIndex: _trainDashboardBloc.index,
        onTap: (index) {
          _trainDashboardBloc.index = index;
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
