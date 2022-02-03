import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/movies/movie_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/movies/movie_explore_screen.dart';
import 'package:Slydo/screens/more_apps/movies/my_movies_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieDashboard extends StatefulWidget {
  @override
  _MovieDashboardState createState() => _MovieDashboardState();
}

class _MovieDashboardState extends State<MovieDashboard> {
  late MovieDashboardBloc _movieDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _movieDashboardBloc = Provider.of<MovieDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        body: PageView(
          controller: _movieDashboardBloc.pageController,
          onPageChanged: (index) {
            _movieDashboardBloc.index = index;
          },
          children: <Widget>[
            MovieExploreScreen(),
            MyMoviesScreen(),
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
        currentIndex: _movieDashboardBloc.index,
        onTap: (index) {
          _movieDashboardBloc.index = index;
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context)!.explore,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: "My movies",
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
