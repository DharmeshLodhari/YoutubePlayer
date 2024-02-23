import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/screens/find_jobs_tab.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/screens/service_tab.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_tab_selection.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class RiderDashboard extends StatefulWidget {
  const RiderDashboard({Key? key}) : super(key: key);

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  GlobalKey<ServiceTabState> serviceViewStateKey = GlobalKey<ServiceTabState>();
  GlobalKey<FindJobsTabState> findJobViewStateKey =
      GlobalKey<FindJobsTabState>();

  late PageController _pageViewController;
  int currentIndex = 0;
  late AppLocalization appLocalization;
  bool _tabsVisible = true;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);

    super.initState();
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context)!;
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Jobs',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      actions: _buildAppBarActions(),
      elevation: 0.5,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _searchBtn(),
      const SizedBox(
        width: 10,
      ),
      _moreOptionsBtn(),
      const SizedBox(
        width: 6,
      ),
    ];
  }

  Widget _searchBtn() {
    return GestureDetector(
      child: Icon(
        SlydoAppIcon.search,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // currentIndex == 0
        //     ? Navigator.pushNamed(context, Routes.SEARCH_SERVICES)
        //     : Navigator.pushNamed(context, Routes.JOBS_SEARCH);
      },
    );
  }

  Widget _moreOptionsBtn() {
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      child: IconButton(
          onPressed: () {
            androidBottomSheet(
              context: context,
              child: StatefulBuilder(
                builder: (context, changeState) {
                  return SizedBox(
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // Navigator.pushNamed(context, Routes.JOBS_CREATE);
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Create Job',
                                  style: TextStyle(
                                      fontSize: 14.8,
                                      fontFamily: "Inter",
                                      color: black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // Navigator.pushNamed(context, Routes.MY_JOBS);
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'My Jobs',
                                  style: TextStyle(
                                      fontSize: 14.8,
                                      fontFamily: "Inter",
                                      color: black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          icon: Icon(
            Icons.more_vert,
            color: blackFont,
          )),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        _buildTabs(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        YarnTabSelection(
          onTap: (index) {
            currentIndex = index;
            _pageViewController.jumpToPage(currentIndex);
            _showTabs(true);
            if (mounted) setState(() {});
          },
          currentIndex: currentIndex,
          firstTab: 'Services',
          secondTab: 'Find Jobs',
        ),
        Divider(
          color: darkGrey.withOpacity(.5),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          ServiceTab(
            key: serviceViewStateKey,
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
          ),
          FindJobsTab(
            key: findJobViewStateKey,
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
          ),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentIndex = index;
    });
  }
}
