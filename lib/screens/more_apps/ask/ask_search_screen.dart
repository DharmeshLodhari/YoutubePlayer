import 'package:Slydo/screens/more_apps/ask/components/ask_posts_view.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/slydo_app_icon_new_icons.dart';
import '../../../widget/customized_popup_menu.dart';
import 'ask_auth.dart';
import 'components/ask_options.dart';
import 'models/Topics/YarnTopic.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();
  GlobalKey _key = LabeledGlobalKey("messageListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  String? filterValue;
  bool isPopMenuOpen = false;
  bool isLoading = false;
  String next = "", previous = "";
  List<YarnTopic> yarnTopicList = [];
  int count = 0;
  bool noList = false;

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    filterValue = value;
    getYarnTopic();
    setState(() {});
    // _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  void getYarnTopic() async {
    bool isQuestion = false;
    if (filterValue == "question") {
      isQuestion = false;
    } else {
      isQuestion = true;
    }
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth().getSearchYarns(next, previous, isQuestion: isQuestion, searchText: searchController.text);

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

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "Question", value: "question"),
        CustomizedPopUpMenuItem(
            title: "Yarn", value: "yarn"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.isTitleShow = true;
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left
        ),
        color: navyBlue,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Column(
        children: [
          _buildSearchBox(),
          _buildPostList(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Row(
      children: [
        _buildSearchField(),
        _buildFilterIconButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextFormField(
        controller: searchController,
        onFieldSubmitted: (val) {
          if (mounted) {
            setState(() {
              count = 0;
              next = "";
              previous = "";
              yarnTopicList.clear();
              noList = false;
            });
            getYarnTopic();
          }
        },
        //autofocus: true,
        style: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w600,
        ),
        cursorWidth: 1.5,
        cursorColor: navyBlue,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkGrey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              SlydoAppIconNew.search,
              color: HexColor("#75818F"),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                yarnTopicList.clear();
                noList = false;
              });
              getYarnTopic();
            },
          ),
          hintText: "Search anything",
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefix: Padding(
            padding: EdgeInsets.only(left: 16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("#EBEDFC"),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("#EBEDFC"),
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("#EBEDFC"),
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("#EBEDFC"),
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterIconButton() {
    return SizedBox(
      key: _key,
      //height: 34,
      width: 34,
      child: Card(
        // color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: IconButton(
          icon: Icon(
            SlydoAppIconNew.filter,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return Expanded(
      child: ListView.builder(
        itemCount: yarnTopicList.length,
        itemBuilder: (context, index) {
          return AskPosts(
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
            isImages: yarnTopicList[index].image != null ? true : false,
            images: yarnTopicList[index].image != null ? yarnTopicList[index].image : [],
            title: yarnTopicList[index].title,
            body: yarnTopicList[index].body,
            authorName: yarnTopicList[index].authorName,
            authorAvatar: yarnTopicList[index].authorAvatar,
            tags: yarnTopicList[index].tags,
          );
        },
      ),
    );
  }

}
