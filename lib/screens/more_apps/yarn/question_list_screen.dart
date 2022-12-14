import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/noItemInList.dart';
import 'models/Topics/YarnTopic.dart';
import 'tiles/yarn_list_tile.dart';
import 'widgets/yarn_options.dart';
import 'widgets/yarn_shimmer.dart';
import 'yarn_auth.dart';
import 'yarn_detail_screen.dart';

class QuestionListScreen extends StatefulWidget {
  final String? selectedCategory;
  QuestionListScreen({Key? key, this.selectedCategory}) : super(key: key);

  @override
  State<QuestionListScreen> createState() => QuestionListScreenState(key: key);
}

class QuestionListScreenState extends State<QuestionListScreen> {
  Key? key;
  QuestionListScreenState({this.key});
  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  ScrollController _questionScrollController = new ScrollController();

  @override
  void initState() {
    getYarnTopic(categoryId: widget.selectedCategory);
    _questionScrollController.addListener(() {
      if (_questionScrollController.position.pixels ==
              _questionScrollController.position.maxScrollExtent &&
          _questionScrollController.position.pixels != 0) {
        getYarnTopic(categoryId: widget.selectedCategory);
      }
    });
    super.initState();
  }

  void getYarnTopic(
      {String type = "question",
      bool isType = true,
      String? categoryId}) async {
    if (categoryId != null) {
      selectedId = categoryId;
    }
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth().getAllYarn(
            next, previous ?? '',
            type: type, isType: isType, categoryId: categoryId);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        // yarnTopicList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            yarnTopicList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $yarnTopicList");
      }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _postRefreshController,
            onRefresh: onPostRefresh,
            child: _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    print("IS LOADING:- $isLoading");
    // if (isLoading) {
    //   return AskLoader();
    // }
    if (!noList) {
      return ListView.builder(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 22),
        controller: _questionScrollController,
        itemCount: yarnTopicList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == yarnTopicList.length) {
            return _buildReviewIndicator();
          }
          return InkWell(
            onTap: () async {
              if (yarnTopicList[index].enableCommenting ?? false) {
                await NavigationUtil.push(
                  context,
                  screen: YarnDetailScreen(yarn: yarnTopicList[index]),
                );
              }
              if (mounted) setState(() {});
            },
            child: YarnTile(
              yarn: yarnTopicList[index],
              onDeleteYarn: (Yarn yarn) {
                int index = yarnTopicList.indexWhere((element) => element.id == yarn.id);
                if (index != -1) {
                  yarnTopicList.removeAt(index);
                  if (mounted) setState(() {});
                }
              },
            ),
          );
        },
      );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
    );
  }

  Widget _buildReviewIndicator() {
    return new Opacity(
      opacity: isLoading ? 1.0 : 00,
      child: isLoading ? YarnShimmer() : Container(),
    );
  }

  void onPostRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        yarnTopicList = [];
        if (mounted) setState(() {});

        getYarnTopic(categoryId: selectedId);
        setState(() {
          _postRefreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          _postRefreshController.refreshCompleted();
        });
      }
    });
  }
}
