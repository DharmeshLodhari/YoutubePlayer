import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_category_selection.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_notification_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../data/state_notifier.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_new_icons.dart';
import '../../../utils/util.dart';
import '../messaging/message_auth.dart';
import 'add_or_edit_yarn_screen.dart';
import 'ask_search_screen.dart';
import 'question_list_screen.dart';
import 'yarn_dashboard_bloc.dart';
import 'yarn_list_screen.dart';
import 'yarn_setting_screen.dart';

class YarnDashboard extends StatefulWidget {
  @override
  State<YarnDashboard> createState() => _YarnDashboardState();
}

class _YarnDashboardState extends State<YarnDashboard> {
  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();
  GlobalKey<QuestionListScreenState> questionViewStateKey =
      GlobalKey<QuestionListScreenState>();

  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String? selectedCategoryId;
  late YarnDashboardBloc yarnDashboardBloc;
  bool isQuestionMode = false;
  int count = 0;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    fetchMessageCount();
    super.initState();
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
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
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
      SizedBox(width: 30),
      RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Badge(
            badgeColor: naturalGreen,
            animationType: BadgeAnimationType.slide,
            badgeContent: getUnReadCount(count),
            padding: count == 0
                ? EdgeInsets.all(0)
                : EdgeInsets.only(
                    left: count.toString().length == 1 ? 6 : 8,
                    right: 6,
                    top: 4,
                    bottom: 4),
            position: BadgePosition(
                end: count.toString().length == 1 ? -5 : -10, top: 0),
            child: SvgPicture.asset(
              "yarn/notification".toSVG(),
              height: 16,
              width: 16,
              color: HexColor("#151515"),
            )),
        onTap: () {
          NavigationUtil.push(
            context,
            screen: YarnNotification(),
          );
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: true,
      ),
      SizedBox(width: 30),
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
          )
          // Icon(
          //   Icons.settings,
          //   color: yarnBlack,
          //   size: 26,
          // ),
          ),
      SizedBox(width: 30),
    ];
  }

  Widget _buildBody() {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        _buildCategoryAndTabs(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildCategoryAndTabs() {
    return Column(
      children: [
        YarnCategorySelection(),
        SizedBox(height: 14),
        Divider(
          height: 0,
          thickness: 0.5,
          color: greySecondaryYarn,
        )
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
          ),
          // QuestionListScreen(
          //   key: questionViewStateKey,
          //   selectedCategory: selectedCategoryId,
          // ),
          // MyFeedView(key: myFeedViewStateKey, selectedCategory: selectedCategoryId,),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      child: InkWell(
        onTap: () async {
          await NavigationUtil.push(context,
              screen: AddOrEditYarn(
                askCategories: yarnDashboardBloc.yarnCategories,
                shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
                isYarn: true,
              )).then((value) {
            debugPrint("THEN VALUE===$value");
            if (value != null) {
              if (value == Types.Yarn) {
                updateCurrentAskTapOnHome(index: 0);
                _pageViewController.jumpToPage(0);
                topicViewStateKey.currentState?.onRefresh();
              }
            }
          });
        },
        child: Icon(
          SlydoAppIconNew.dashboard_yarn,
          color: Colors.white,
        ),
      ),
      backgroundColor: yarnBlack,
      activeBackgroundColor: HexColor("#FFFFFF"),
    );
  }
}
