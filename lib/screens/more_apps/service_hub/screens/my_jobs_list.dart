import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/tiles/applied_my_jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/tiles/posted_my_jobs.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import '../../../../widget/tab_selection.dart';

class JobsMyJobsList extends StatefulWidget {
  const JobsMyJobsList({super.key});

  @override
  State<JobsMyJobsList> createState() => _JobsMyJobsListState();
}

class _JobsMyJobsListState extends State<JobsMyJobsList> {
  int currentIndex = 0;
  late AppLocalization appLocalization;

  late UserBloc userBloc;

  bool _tabsVisible = true;

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: const [PostedMyJobs(), AppliedMyJobs()],
    );
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
        body: IndexedStack(
          index: currentIndex,
          children: const [PostedMyJobs(), AppliedMyJobs()],
        ),
      ),
    );
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
        appLocalization.myJobs,
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
      bottom: tabBar() as PreferredSizeWidget,
      actions: [_searchBtn()],
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
          TabSelection(
            onTap: (index) {
              currentIndex = index;
              _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentIndex,
            firstTab: appLocalization.posted,
            secondTab: appLocalization.applied,
          ),
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
        ],
      ),
    );
  }

  Widget _searchBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Icon(
          SlydoAppIcon.search,
          size: 16,
          color: blackFont,
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.SEARCH_MY_JOBS);
      },
      // backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }
}
