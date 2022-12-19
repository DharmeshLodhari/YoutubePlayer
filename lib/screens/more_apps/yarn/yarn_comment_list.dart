import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_comment_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:flutter/material.dart';

class YarnCommentList extends StatefulWidget {
  const YarnCommentList(
      {required this.yarn, required this.commentScrollController, Key? key})
      : super(key: key);
  final Yarn yarn;
  final ScrollController commentScrollController;

  @override
  State<YarnCommentList> createState() => _YarnCommentListState();
}

class _YarnCommentListState extends State<YarnCommentList> {
  /// Variables for Sorting POPUP MENU
  GlobalKey _key = LabeledGlobalKey("yarnCommentListSort");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  /// variables for commentList
  bool isLoading = false;
  String next = "", previous = "";
  int count = 0;
  bool noList = false;
  List<YarnComment> yarnComments = [];
  String? filterValue;

  @override
  void initState() {
    getAllComments();
    super.initState();
  }

  void addScrollControllerListener() {
    widget.commentScrollController.addListener(() {
      if (widget.commentScrollController.position.pixels ==
              widget.commentScrollController.position.maxScrollExtent &&
          widget.commentScrollController.position.pixels != 0) {
        getAllComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "Latest", value: "-created_at"),
        CustomizedPopUpMenuItem(title: "Older", value: "created_at"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.isTitleShow = true;
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return _buildCommentView();
  }

  Widget _buildCommentView() {
    return SingleChildScrollView(
      controller: widget.commentScrollController,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopActionButton(),
          Divider(
            thickness: 1,
            height: 0,
            color: greyBackground,
          ),
          _buildCommentList(),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    return isLoading
        ? YarnShimmer()
        : Column(
            children: yarnComments
                .map((yarnComment) => Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: YarnCommentTile(
                            yarn: widget.yarn,
                            yarnComment: yarnComment,
                            openReply: false,
                            onDeleteComment: (YarnComment yarnCmt) {
                              int index = yarnComments.indexWhere((element) => element.id == yarnCmt.id);
                              if (index != -1) {
                                yarnComments.removeAt(index);
                              }
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          height: 0,
                          thickness: 0.5,
                          color: greySecondaryYarn,
                        ),
                      ],
                    ))
                .toList(),
          );
  }

  Widget _buildTopActionButton() {
    return SizedBox(
      key: _key,
      width: 108,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
        child: InkWell(
          onTap: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
          child: Row(
            children: [
              Text(
                "Top Comments",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_outlined,
              )
            ],
          ),
        ),
      ),
    );
  }

  void getAllComments() async {
    String selectFilter;
    if (filterValue == null || filterValue == '-created_at') {
      selectFilter = '-created_at';
    } else {
      selectFilter = 'created_at';
    }
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth().getAllComments(
            next, previous, widget.yarn.id!,
            sortBy: selectFilter);

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
        yarnComments = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            yarnComments.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $widget.commentDetailsList");
      }
      if (yarnComments.isEmpty) {
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

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    filterValue = value;
    getAllComments();
    if (mounted) setState(() {});
    // _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }
}
