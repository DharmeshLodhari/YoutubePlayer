import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/screens/jobs_dashboard.dart';
import 'package:Slydo/screens/more_apps/service_hub/service_hub.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/util.dart';
import '../yarn/widgets/yarn_tab_selection.dart';

class ServiceHubDashboard extends StatefulWidget {
  const ServiceHubDashboard({Key? key}) : super(key: key);

  @override
  State<ServiceHubDashboard> createState() => _ServiceHubDashboardState();
}

class _ServiceHubDashboardState extends State<ServiceHubDashboard> {
  late BasketBloc basketBloc;
  int currentIndex = 0;
  late AppLocalization appLocalization;
  bool isSelected = false;
  String selected = "";

  bool _tabsVisible = true;

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
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
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _searchBtn(),
        const SizedBox(
          width: 20,
        ),
        if (currentIndex == 0) _cartBtn(),
        // if (currentIndex == 0) SizedBox(width: 10),
        _moreOptionsBtn(),
        const SizedBox(
          width: 4,
        ),
      ],
      bottom: tabBar() as PreferredSizeWidget,
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
                            onTap: () => Navigator.pushNamed(
                                context, Routes.JOBS_CREATE),
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
                                        "assets/images/Edit.svg")),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Create Job',
                                  style: TextStyle(
                                      fontSize: 14.8,
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
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.MY_JOBS),
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
                                        "assets/images/Document.svg")),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'My Job',
                                  style: TextStyle(
                                      fontSize: 14.8,
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

            // selected = v;
            // if (selected == 'Create Job') {
            //   Navigator.pushNamed(context, Routes.JOBS_CREATE);
            // } else if (selected == 'My Job') {
            //   Navigator.pushNamed(context, Routes.MY_JOBS);
            // }
            // setState(() {});
          },
          icon: Icon(
            Icons.more_vert,
            color: blackFont,
          )),
    );
  }

  PopupMenuItem<String> getCreateJobBtn() {
    return PopupMenuItem<String>(
      value: 'Create Job',
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/Edit.svg")),
        title: const Text('Create Job'),
      ),
      // onTap: () {},
    );
  }

  PopupMenuItem<String> getMyJobBtn() {
    return PopupMenuItem<String>(
      value: 'My Job',
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/Document.svg")),
        title: const Text('My Job'),
      ),
      // onTap: () {},
    );
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Column(
        children: [
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
          YarnTabSelection(
            onTap: (index) {
              currentIndex = index;
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

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: const TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'] as int;
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  Widget _cartBtn() {
    return GestureDetector(
      child: badges.Badge(
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: naturalGreen,
          padding: basketBloc.items.length == 0
              ? const EdgeInsets.all(0)
              : EdgeInsets.only(
                  left: getBadgeCount().length == 1 ? 6 : 8,
                  right: 6,
                  top: 6,
                  bottom: 4),
          elevation: 0,
        ),
        badgeAnimation: const badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(
            end: getBadgeCount().length == 1 ? -5 : -10, top: 0),
        child: Center(
          child: Icon(
            SlydoAppIcon.cart,
            size: 16,
            color: blackFont,
          ),
        ),
      ),
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

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: const [SuperHub(), JobsDashboard()],
    );
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
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
            appBar: appBar() as PreferredSizeWidget?,
            body: tabViews(),
          ),
        ),
      ),
    );
  }
}
