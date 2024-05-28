import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_category_selection.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_notification_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_new_icons.dart';
import '../../../utils/util.dart';
import '../messaging/message_auth.dart';
import 'add_or_edit_yarn_screen.dart';
import 'trending_list_screen.dart';
import 'yarn_dashboard_bloc.dart';
import 'yarn_list_screen.dart';
import 'yarn_search_screen.dart';
import 'yarn_setting_screen.dart';

class YarnDashboard extends StatefulWidget {
  @override
  State<YarnDashboard> createState() => _YarnDashboardState();
}

class _YarnDashboardState extends State<YarnDashboard> {
  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();
  GlobalKey<TrendingListScreenState> latestViewStateKey =
      GlobalKey<TrendingListScreenState>();

  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String? selectedCategoryId;
  late YarnDashboardBloc yarnDashboardBloc;
  late UserBloc userBloc;
  bool isQuestionMode = false;
  int count = 0;
  Yarn? yarnTopic;

  bool _tabsVisible = true;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    fetchMessageCount();

    final scheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(seconds: 60),
      name: 'count-notify',
      timeout: const Duration(seconds: 5),
      task: () async {
        fetchMessageCount();
      },
      minCycle: const Duration(seconds: 5),
    );
    scheduler.start();

    super.initState();
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  void fetchMessageCount() async {
    try {
      count = await MessageAuth().getUnreadNotificationCount();
      if (mounted) setState(() {});
    } catch (error) {
      count = 0;
    }
  }

  Widget? getUnReadCount(int count) {
    if (count == 0) {
      return null;
    }
    return Text(
      count.toString(),
      style: const TextStyle(
          fontFamily: "Inter",
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context, listen: false);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildFloatingActionButton(),
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Yarn',
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
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            NavigationUtil.push(
              context,
              screen: SearchScreen(),
            );
          },
          height: 20,
          width: 20,
          icon: SvgPicture.asset(
            "yarn/search".toSVG(),
            height: 12,
            width: 12,
          )),
      const SizedBox(width: 20),
      RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: badges.Badge(
            badgeContent: getUnReadCount(count),
            position: badges.BadgePosition.topEnd(
                end: count.toString().length == 1 ? -5 : 0, top: 0),
            badgeAnimation: const badges.BadgeAnimation.rotation(
              animationDuration: Duration(seconds: 1),
              colorChangeAnimationDuration: Duration(seconds: 1),
              loopAnimation: false,
              curve: Curves.fastOutSlowIn,
              colorChangeAnimationCurve: Curves.easeInCubic,
            ),
            badgeStyle: badges.BadgeStyle(
              shape: badges.BadgeShape.circle,
              badgeColor: naturalGreen,
              padding: count == 0
                  ? const EdgeInsets.all(0)
                  : EdgeInsets.only(
                      left: count.toString().length == 1 ? 6 : 8,
                      right: 6,
                      top: 4,
                      bottom: 4),
              elevation: 0,
            ),
            child: Center(
              child: SvgPicture.asset(
                "yarn/notification".toSVG(),
                height: 16,
                width: 16,
                color: HexColor("#151515"),
              ),
            )),
        onTap: () {
          NavigationUtil.push(
            context,
            screen: YarnNotification(onDeleteNotification: (bool) {
              fetchMessageCount();
            }),
          );
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: true,
      ),
      const SizedBox(width: 20),
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            NavigationUtil.push(
              context,
              screen: YarnSettingsScreen(),
            );
          },
          height: 20,
          width: 20,
          icon: SvgPicture.asset(
            "yarn/setting".toSVG(),
            height: 12,
            width: 12,
          )),
      const SizedBox(width: 30),
    ];
  }

  Widget _buildBody() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        /// Check if the scroll direction is horizontal
        if (scrollNotification is ScrollNotification &&
            scrollNotification.metrics.axis == Axis.horizontal) {
          // Disable horizontal scrolling
          return true;
        }

        if (scrollNotification is ScrollUpdateNotification) {
          if (scrollNotification.scrollDelta! > 0 && _tabsVisible) {
            // Scrolling down
            _showTabs(false);
          } else if (scrollNotification.scrollDelta! < 0 && !_tabsVisible) {
            // Scrolling up
            _showTabs(true);
          }
        }

        return true;
      },
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          _buildCategoryAndTabs(),
          _buildPageView(),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTabs() {
    return Column(
      children: [
        if (_tabsVisible) ...[
          const YarnCategorySelection(),
          const SizedBox(height: 14),
          Divider(
            height: 0,
            thickness: 0.5,
            color: greySecondaryYarn,
          ),
          const SizedBox(height: 8),
        ],
        if (_tabsVisible) ...[
          TabSelection(
            onTap: (index) {
              currentAskTapOnHome = index;
              _pageViewController.jumpToPage(currentAskTapOnHome);
              _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentAskTapOnHome,
            firstTab: 'Latest',
            secondTab: 'Trending',
          ),
          const SizedBox(
            height: 16,
          ),
        ],
        // YarnCategorySelection(),
        // SizedBox(height: 14),
        // Divider(
        //   height: 0,
        //   thickness: 0.5,
        //   color: greySecondaryYarn,
        // ),
        // SizedBox(height: 8),
        // YarnTabSelection(
        //   onTap: (index) {
        //     currentAskTapOnHome = index;
        //     _pageViewController.jumpToPage(currentAskTapOnHome);
        //     _showTabs(true);
        //     if (mounted) setState(() {});
        //   },
        //   currentIndex: currentAskTapOnHome,
        // ),
        // SizedBox(
        //   height: 16,
        // ),
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
          YarnListScreen(
            key: topicViewStateKey,
            selectedCategory: selectedCategoryId,
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
          ),
          TrendingListScreen(
            key: latestViewStateKey,
            selectedCategory: selectedCategoryId,
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

  bool isPageViewAtTop() {
    return _pageViewController.page == 0;
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      backgroundColor: yarnBlack,
      activeBackgroundColor: HexColor("#FFFFFF"),
      child: InkWell(
        onTap: () async {
          PermissionType? hasPermission =
              userBloc.user.hasWritePermission(ProtectionPermission.moment);
          if (hasPermission == PermissionType.WRITE) {
            await NavigationUtil.push(context,
                screen: AddOrEditYarn(
                  askCategories: yarnDashboardBloc.yarnCategories,
                  shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
                  isYarn: true,
                  passedCategory: '',
                  onUpdateYarn: (Yarn yarn) {
                    yarnTopic = yarn;

                    if (mounted) setState(() {});
                  },
                )).then((value) {
              if (value != null) {
                if (value == Types.Yarn) {
                  updateCurrentAskTapOnHome(index: 0);
                  _pageViewController.jumpToPage(0);
                  topicViewStateKey.currentState?.onCreateYarn(yarnTopic);
                  topicViewStateKey.currentState?.onRefresh();
                }
              }
            });
          } else {
            showSnackbar(context,
                message: AppLocalization.of(context)?.doNotPermission ?? "");
          }
        },
        child: const Icon(
          SlydoAppIconNew.dashboard_yarn,
          color: Colors.white,
        ),
      ),
    );
  }
}
