import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/screens/find_jobs_tab.dart';
import 'package:Slydo/screens/more_apps/service_hub/screens/jobs_dashboard.dart';
import 'package:Slydo/screens/more_apps/service_hub/service_hub.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/cart_with_badge.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/util.dart';
import '../../../widget/tab_selection.dart';

class ServiceHubDashboard extends StatefulWidget {
  final dynamic arguments;

  ServiceHubDashboard({super.key, this.arguments});

  @override
  State<ServiceHubDashboard> createState() => _ServiceHubDashboardState();
}

class _ServiceHubDashboardState extends State<ServiceHubDashboard> {
  late BasketBloc basketBloc;
  late UserBloc userBloc;
  int currentIndex = 0;
  late AppLocalization appLocalization;
  bool isSelected = false;
  String selected = "";

  bool _tabsVisible = true;
  late PageController _pageViewController;

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  @override
  void initState() {
    _pageViewController =
        PageController(initialPage: widget.arguments['page'] ?? 0);

    currentIndex = widget.arguments['page'] ?? 0;

    super.initState();
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        "Service Hub",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _searchBtn(),
        if (currentIndex == 0) ...[
          const SizedBox(
            width: 15,
          ),
          _cartBtn(),
          const SizedBox(
            width: 20,
          ),
        ],
        if (currentIndex == 1) ...[
          const SizedBox(
            width: 15,
          ),
          _earningInfoBtn(),
          const SizedBox(
            width: 20,
          ),
        ],
      ],
      // bottom: tabBar() as PreferredSizeWidget,
    );
  }

  Widget _earningInfoBtn() {
    if (userBloc.user.rider != null &&
        userBloc.user.rider?.isStatusApproved() == true) {
      return GestureDetector(
        child: Icon(
          Icons.info_outline_rounded,
          size: 22,
          color: blackFont,
        ),
        onTap: () {
          Navigator.pushNamed(context, Routes.RIDER_DASHBOARD);
        },
      );
    } else {
      return _moreOptionsBtn();
    }
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
                      child: _buildOptionList(),
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

  Widget _buildOptionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.JOBS_CREATE);
          },
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Color(0xfffafbff),
                ),
                child: SvgPicture.asset(
                  "assets/images/Edit.svg",
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Create Job',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.MY_JOBS);
          },
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Color(0xfffafbff),
                ),
                child: SvgPicture.asset(
                  "assets/images/Document.svg",
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'My Jobs',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Column(
        children: [
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
          TabSelection(
            onTap: (index) {
              currentIndex = index;
              _pageViewController.jumpToPage(currentIndex);
              _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentIndex,
            firstTab: appLocalization.services,
            secondTab: appLocalization.findJobs,
          ),
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
        ],
      ),
    );
  }

  Widget _cartBtn() {
    return CartWithBadge(
      items: basketBloc.basketItems,
      height: 30,
      width: 30,
      backgroundColor: transparent,
      enableMargin: true,
      onTap: () {
        Navigator.pushNamed(context, Routes.SHOPPING_CART);
      },
    );
  }

  Widget _searchBtn() {
    return GestureDetector(
      child: Icon(
        SlydoAppIcon.search,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        currentIndex == 0
            ? Navigator.pushNamed(context, Routes.SEARCH_SERVICES)
            : Navigator.pushNamed(context, Routes.JOBS_SEARCH);
      },
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
          const SuperHub(),
          getJobList(),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentIndex = index;
    });
  }

  // Widget tabViews() {
  //   return IndexedStack(
  //     index: currentIndex,
  //     children: [SuperHub(), getJobList()],
  //   );
  // }

  Widget getJobList() {
    if (userBloc.user.rider != null &&
        userBloc.user.rider?.isStatusApproved() == true) {
      return FindJobsTab();
    } else {
      return const JobsDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTabs(),
                _buildPageView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
