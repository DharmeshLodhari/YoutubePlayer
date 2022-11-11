import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'add_topic_screen.dart';
import 'ask_auth.dart';
import 'ask_by_category_screen.dart';
import 'ask_detail_screen.dart';
import 'ask_settings_screen.dart';
import 'ask_viewmodel.dart';
import 'components/ask_category_pick.dart';
import 'components/ask_options.dart';
import 'components/ask_posts_view.dart';
import 'components/category_chip.dart';
import 'models/Topics/YarnTopic.dart';
import 'models/ask_categories_model.dart';

class AskHomeScreen extends StatefulWidget {

  List<AskCategories>? askCategories;
  List<AskCategories>? selectedCategories;

  AskHomeScreen({this.askCategories, this.selectedCategories});

  @override
  State<AskHomeScreen> createState() => _AskHomeScreenState();
}

class _AskHomeScreenState extends State<AskHomeScreen> {
  late PageController _pageViewCtrl;
  int? currentAskTapOnHome = 0;

  bool isLoading = false;
  String next = "", previous = "";
  List<YarnTopic> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController = RefreshController(initialRefresh: false);
  RefreshController _postRefreshController1 = RefreshController(initialRefresh: false);
  RefreshController _postRefreshController2 = RefreshController(initialRefresh: false);

  List<Color> categoryColors = [
    Color(0xFFF07097),
    Color(0xFF030F36),
    Color(0xFF8829C1),
    Color(0xFF8B008B),
    Color(0xFF3F61DB),
    Color(0xFFB22727),
    Color(0xFFFFCC00),
    Color(0xFF8B008B),
    Color(0xFFFFA500),
    Color(0xFF46CE7C),
    Color(0xFF964B00),
    Color(0xFFF35B46),
    Color(0xFF243A73),
  ];

  @override
  void initState() {
    //Future.microtask(() => context.read<AskViewModel>().initialiseVM());
    getYarnTopic("topic", true);
    _pageViewCtrl = PageController(initialPage: 0);
    super.initState();
  }

  void getYarnTopic(String type, bool isType) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth().getAllTopics(next, previous,type: type, isType: isType);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'] != null ? result['next'] : "";
        previous = result['previous'] != null ? result['previous'] : "";
        var tempList = result['results'];
        yarnTopicList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            yarnTopicList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $yarnTopicList");
      }
      if (yarnTopicList.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AskViewModel>(builder: (context, model, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _buildFloatingActionButton(),
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: _buildBody(),
      );
    });
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: blackFont,
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: AskCategoryPick(
                onCategoryPick: (c) {
                  // model.updateCategoryToAskOn(c: c);

                  NavigationUtil.pop(context);

                  NavigationUtil.push(
                    context,
                    screen: AddTopicScreen(),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            'YARN',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: blackFont,
            ),
          ),
        ],
      ),
      actions: [
        _buildAppBarActions()
      ],
      elevation: 0,
      leading: _buildIconButton(
        onTap: () {
          Navigator.pop(context);
        },
        icon: Icons.keyboard_arrow_left,
        iconColor: navyBlue,
      ),
    );
  }

  Widget _buildIconButton({GestureTapCallback? onTap, IconData? icon, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        color: iconColor,
        size: 26,
      ),
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        _buildIconButton(
          onTap: () {},
          icon: Icons.search_rounded,
          iconColor: blackFont,
        ),
        SizedBox(width: 10),
        _buildIconButton(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: AskSettingsScreen(),
            );
          },
          icon: Icons.settings,
          iconColor: blackFont
        ),
        SizedBox(width: 17),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          _buildCategoryAndTabs(),
          _buildPageView()
        ],
      ),
    );
  }

  Widget _buildCategoryAndTabs() {
    return Column(
      children: [
        _buildCategoryChip(),
        SizedBox(height: 17),
        _buildPageViewTabs(),
        SizedBox(height: 7),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            widget.askCategories!.length,
                (i) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CategoryChip(
                  onTap: () {},
                  title: widget.askCategories![i].name,
                  categoryColor: i <= categoryColors.length-1 ? categoryColors[i].withOpacity(0.1) : categoryColors[0].withOpacity(0.1),
                  selectedCategoryBorderColor: widget.selectedCategories!.contains(widget.askCategories![i]) ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.1),
                  selectedCategoryTextColor: i <= categoryColors.length-1 ? categoryColors[i] : categoryColors[0],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageViewTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        pageViewTabItem(
            onPageTap: () {
              updateCurrentAskTapOnHome(i: 0);
              _pageViewCtrl.jumpToPage(0);
              yarnTopicList = [];
              getYarnTopic("topic", true);
            },
            pageNum: 0,
            title: 'Yarns',
            currentTapIndex: currentAskTapOnHome
        ),
        pageViewTabItem(
            onPageTap: () {
             updateCurrentAskTapOnHome(i: 1);
              _pageViewCtrl.jumpToPage(1);
             yarnTopicList = [];
             getYarnTopic("question", true);
            },
            pageNum: 1,
            title: 'Questions',
            currentTapIndex: currentAskTapOnHome
        ),
        pageViewTabItem(
            onPageTap: () {
              updateCurrentAskTapOnHome(i: 2);
              _pageViewCtrl.jumpToPage(2);
              yarnTopicList = [];
              getYarnTopic("my-topics", false);
            },
            pageNum: 2,
            title: 'My Feeds',
            currentTapIndex: currentAskTapOnHome
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(i: currentPage);
        },
        controller: _pageViewCtrl,
        children: [
          askListView(yarnTopic: yarnTopicList),
          askListView(yarnTopic: yarnTopicList),
          askListView(yarnTopic: yarnTopicList)
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

  Widget askListView({required List<YarnTopic> yarnTopic}) {
    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: currentAskTapOnHome == 0 ? _postRefreshController : currentAskTapOnHome == 1 ? _postRefreshController1 : _postRefreshController2,
            onRefresh: _onPostRefresh,
            child: askLists(yarnTopic: yarnTopic),
          ),
        ),
      ],
    );
  }

  Widget askLists({required List<YarnTopic> yarnTopic}) {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 22),
      itemCount: yarnTopic.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: AskDetailScreen(),
            );
          },
          child: AskPosts(
            showTag: true,
            onOptionsAction: () {
              showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: AskOptions(),
                  );
                },
              );
            },
            isImages: yarnTopic[index].image != null ? true : false,
            images: yarnTopic[index].image != null ? yarnTopic[index].image : [],
            title: yarnTopic[index].title,
            body: yarnTopic[index].body,
            authorName: yarnTopic[index].authorName,
            authorAvatar: yarnTopic[index].authorAvatar,
            tags: yarnTopic[index].tags != null ? yarnTopic[index].tags : [],
          ),
        );
      },
    );
  }

  void updateCurrentAskTapOnHome({int? i}) {
    setState(() {
      currentAskTapOnHome = i;
    });
  }

  void _onPostRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        yarnTopicList = [];
        if (mounted) setState(() {});
        String? type;
        bool isType = false;
        if (currentAskTapOnHome == 0){
          type = "topic";
          isType = true;
        } else if (currentAskTapOnHome == 1) {
          type = "question";
          isType = true;
        } else if (currentAskTapOnHome == 2) {
          type = "my-topics";
          isType = false;
        }
        getYarnTopic(type!, isType);
       setState(() {
         _postRefreshController.refreshCompleted();
         _postRefreshController1.refreshCompleted();
         _postRefreshController2.refreshCompleted();
       });
      } else {
        showToast(
            message:
            AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          _postRefreshController.refreshCompleted();
          _postRefreshController1.refreshCompleted();
          _postRefreshController2.refreshCompleted();
        });
      }
    });
  }
}
