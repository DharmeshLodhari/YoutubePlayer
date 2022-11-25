import 'package:Slydo/screens/more_apps/ask/ask_by_category_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_new_icons.dart';
import '../../../utils/util.dart';
import 'add_topic_screen.dart';
import 'ask_auth.dart';
import 'ask_search_screen.dart';
import 'ask_setting_screen.dart';
import 'ask_viewmodel.dart';
import 'components/category_chip.dart';
import 'components/myfeed.dart';
import 'components/question_view.dart';
import 'components/topics_view.dart';
import 'models/ask_categories_model.dart';

class AskHomeScreen extends StatefulWidget {

  List<AskCategories>? askCategories;
  List<AskCategories>? selectedCategories;

  AskHomeScreen({this.askCategories, this.selectedCategories});

  @override
  State<AskHomeScreen> createState() => _AskHomeScreenState();
}

class _AskHomeScreenState extends State<AskHomeScreen> {
  GlobalKey<TopicViewState> topicViewStateKey = GlobalKey<TopicViewState>();
  GlobalKey<TopicViewState> questionViewStateKey = GlobalKey<TopicViewState>();
  GlobalKey<MyFeedViewState> myFeedViewStateKey = GlobalKey<MyFeedViewState>();

  late PageController _pageViewCtrl;
  int? currentAskTapOnHome = 0;
  bool isAskCategoriesLoading = false;
  String? categoriesNext = "";
  String? categoriesPrevious = "";
  bool noCategoriesList = false;
  int? categoryCount = 0;
  String? selectedCategoryId;
  late AskViewModel askViewModel;

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
    // Future.microtask(() => context.read<AskViewModel>().init());
    _pageViewCtrl = PageController(initialPage: 0);
    getAskCategoriesList();
    super.initState();
  }

  void getAskCategoriesList() async {
    if (!isAskCategoriesLoading) {
      if (categoriesNext != null && !isAskCategoriesLoading) {
        isAskCategoriesLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllCategories(categoriesNext, categoriesPrevious!);

        if (result == null) {
          noCategoriesList = true;

          isAskCategoriesLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        categoryCount = result['count'];
        categoriesNext = result['next'];
        categoriesPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          noCategoriesList = false;
          isAskCategoriesLoading = false;
          askViewModel.askCategories = tempList;
        }
      }
      if (askViewModel.askCategories.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
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
    askViewModel = Provider.of<AskViewModel>(context, listen: false);
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
        color: HexColor("#3F61DB"),
      ),
      backgroundColor: HexColor("#3F61DB"),
      activeBackgroundColor: HexColor("#FFFFFF"),
      children: [
        _buildSpeedDialChild(
          title: "Ask Question",
          icon: SlydoAppIconNew.question,
          onTap: () {
            NavigationUtil.push(context, screen: AddTopicScreen(askCategories: askViewModel.askCategories, isYarn: false,)).then((value) {
              topicViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
              questionViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
              myFeedViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
            });
          }
        ),
        _buildSpeedDialChild(
          title: "Yarn",
          icon: SlydoAppIconNew.yarn,
          onTap: () {
            NavigationUtil.push(context, screen: AddTopicScreen(askCategories: askViewModel.askCategories, isYarn: true,)).then((value) {
              topicViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
              questionViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
              myFeedViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
            });
          }
        ),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild({required String title, required IconData icon, required VoidCallback onTap}) {
    return SpeedDialChild(
        onTap: onTap,
        backgroundColor: HexColor("#3F61DB"),
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
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        )
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'YARN',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      titleSpacing: 0,
      actions: [
        _buildAppBarActions()
      ],
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.keyboard_arrow_left,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        color: navyBlue,
      )
    );
  }

  Widget _buildIconButton({GestureTapCallback? onTap, IconData? icon, Color? iconColor, double? iconSize}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: Color(0xFFFBFBFF),
          borderRadius: BorderRadius.circular(3)
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
              screen: AskSettingsScreen(),
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
                screen: AskSettingsScreen(),
              );
            },
            icon: Icons.settings,
            iconColor: blackFont
        ),
        SizedBox(width: 10),
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
          SizedBox(
            width: 7,
          ),
          ...List.generate(
            askViewModel.askCategories.length,
                (i) {
              return Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  CategoryChip(
                    onTap: () {
                      NavigationUtil.push(context, screen: AskByCategoryScreen(askCategories: askViewModel.askCategories[i],));
                    },
                    title: askViewModel.askCategories[i].name,
                    categoryColor: HexColor(askViewModel.askCategories[i].color!).withOpacity(0.1),
                    selectedCategoryTextColor: HexColor(askViewModel.askCategories[i].color!),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageViewTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          pageViewTabItem(
              onPageTap: () {
                updateCurrentAskTapOnHome(i: 0);
                _pageViewCtrl.jumpToPage(0);
              },
              pageNum: 0,
              title: 'Yarns',
              currentTapIndex: currentAskTapOnHome
          ),
          pageViewTabItem(
              onPageTap: () {
               updateCurrentAskTapOnHome(i: 1);
                _pageViewCtrl.jumpToPage(1);
              },
              pageNum: 1,
              title: 'Questions',
              currentTapIndex: currentAskTapOnHome
          ),
          // pageViewTabItem(
          //     onPageTap: () {
          //       updateCurrentAskTapOnHome(i: 2);
          //       _pageViewCtrl.jumpToPage(2);
          //     },
          //     pageNum: 2,
          //     title: 'My Feeds',
          //     currentTapIndex: currentAskTapOnHome
          // ),
        ],
      ),
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
          TopicView(key: topicViewStateKey, selectedCategory: selectedCategoryId,),
          QuestionView(key: questionViewStateKey, selectedCategory: selectedCategoryId,),
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

  void updateCurrentAskTapOnHome({int? i}) {
    setState(() {
      currentAskTapOnHome = i;
    });
  }

  void selectCategory(String categoryId) {
    setState(() {
      if (selectedCategoryId == categoryId) {
        selectedCategoryId = null;
      } else {
        selectedCategoryId =  categoryId;
      }
      topicViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
      questionViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
      myFeedViewStateKey.currentState?.getYarnTopic(categoryId: selectedCategoryId);
    });
  }
}
