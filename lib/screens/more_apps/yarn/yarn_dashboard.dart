import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_category_selection.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_tab_selection.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_new_icons.dart';
import '../../../utils/util.dart';
import 'add_yarn_screen.dart';
import 'ask_search_screen.dart';
import 'models/ask_categories_model.dart';
import 'widgets/question_view.dart';
import 'widgets/topics_view.dart';
import 'yarn_dashboard_bloc.dart';
import 'yarn_setting_screen.dart';

class YarnDashboard extends StatefulWidget {
  final List<AskCategories>? askCategories;
  final List<AskCategories>? selectedCategories;

  YarnDashboard({this.askCategories, this.selectedCategories});

  @override
  State<YarnDashboard> createState() => _YarnDashboardState();
}

class _YarnDashboardState extends State<YarnDashboard> {
  GlobalKey<TopicViewState> topicViewStateKey = GlobalKey<TopicViewState>();
  GlobalKey<QuestionViewState> questionViewStateKey =
      GlobalKey<QuestionViewState>();

  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String? selectedCategoryId;
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    super.initState();
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

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      activeChild: Icon(
        Icons.close,
        color: yarnBlack,
      ),
      backgroundColor: yarnBlack,
      activeBackgroundColor: HexColor("#FFFFFF"),
      children: [
        _buildSpeedDialChild(
            title: "Ask Question",
            icon: SlydoAppIconNew.question,
            onTap: () async {
              await NavigationUtil.push(context,
                  screen: AddTopicScreen(
                    askCategories: yarnDashboardBloc.yarnCategories,
                    isYarn: false,
                  )).then((value) {
                debugPrint("THEN VALUE===$value");
                if (value != null) {
                  if (value == Types.Question) {
                    updateCurrentAskTapOnHome(index: 1);
                    _pageViewController.jumpToPage(1);
                    questionViewStateKey.currentState?.onPostRefresh();
                  }
                }
              });
            }),
        _buildSpeedDialChild(
            title: "Yarn",
            icon: SlydoAppIconNew.yarn,
            onTap: () async {
              await NavigationUtil.push(context,
                  screen: AddTopicScreen(
                    askCategories: yarnDashboardBloc.yarnCategories,
                    isYarn: true,
                  )).then((value) {
                debugPrint("THEN VALUE===$value");
                if (value != null) {
                  if (value == Types.Yarn) {
                    updateCurrentAskTapOnHome(index: 0);
                    _pageViewController.jumpToPage(0);
                    topicViewStateKey.currentState?.onPostRefresh();
                  }
                }
              });
            }),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return SpeedDialChild(
        onTap: onTap,
        backgroundColor: yarnBlack,
        labelBackgroundColor: HexColor("#FFFFFF"),
        labelWidget: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              title,
              style: TextStyle(
                  color: HexColor("#424242"),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ));
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Yarn',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
      shadowColor: greySecondaryYarn,
      actions: [_buildAppBarActions()],
      elevation: 0.5,
      leading: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: yarnBlack,
          size: 14,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        color: yarnBlack,
      ),
    );
  }

  Widget _buildIconButton(
      {GestureTapCallback? onTap,
      IconData? icon,
      Color? iconColor,
      double? iconSize}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize ?? 26,
        ),
      ),
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        _buildIconButton(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: SearchScreen(),
            );
          },
          icon: Icons.search_rounded,
          iconColor: blackFont,
        ),
        SizedBox(width: 10),
        _buildIconButton(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: YarnNotification(),
            );
          },
          icon: SlydoAppIconNew.notification,
          iconColor: blackFont,
          iconSize: 22,
        ),
        SizedBox(width: 10),
        _buildIconButton(
            onTap: () {
              NavigationUtil.push(
                context,
                screen: YarnSettingsScreen(),
              );
            },
            icon: Icons.settings,
            iconColor: blackFont),
        SizedBox(width: 10),
      ],
    );
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
        YarnTabSelection(
            onTap: (index) {
              currentAskTapOnHome = index;
              _pageViewController.jumpToPage(currentAskTapOnHome);
              if (mounted) setState(() {});
            },
            currentIndex: currentAskTapOnHome),
        SizedBox(
          height: 16,
        ),
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
          TopicView(
            key: topicViewStateKey,
            selectedCategory: selectedCategoryId,
          ),
          QuestionView(
            key: questionViewStateKey,
            selectedCategory: selectedCategoryId,
          ),
          // MyFeedView(key: myFeedViewStateKey, selectedCategory: selectedCategoryId,),
        ],
      ),
    );
  }

  Widget pageViewTabItem(
      {required int pageNum,
      required String title,
      int? currentTapIndex,
      Function? onPageTap}) {
    return InkWell(
      onTap: () => onPageTap!(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: currentTapIndex == pageNum
              ? navyBlue.withOpacity(0.1)
              : Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: currentTapIndex == pageNum ? navyBlue : blackFont,
            fontSize: 14,
            fontWeight:
                currentTapIndex == pageNum ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  void selectCategory(String categoryId) {
    setState(() {
      if (selectedCategoryId == categoryId) {
        selectedCategoryId = null;
      } else {
        selectedCategoryId = categoryId;
      }
      topicViewStateKey.currentState
          ?.getYarnTopic(categoryId: selectedCategoryId);
      questionViewStateKey.currentState
          ?.getYarnTopic(categoryId: selectedCategoryId);
    });
  }
}
