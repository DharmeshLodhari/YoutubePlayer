import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/noItemInList.dart';
import '../ask_auth.dart';
import '../ask_detail_screen.dart';
import '../models/Topics/YarnTopic.dart';
import 'ask_loader.dart';
import 'ask_options.dart';
import 'ask_posts_view.dart';

class TopicView extends StatefulWidget {
  String? selectedCategory;
  TopicView({Key? key, this.selectedCategory}) : super(key: key);
  @override
  State<TopicView> createState() => TopicViewState(key: key);
}

class TopicViewState extends State<TopicView> {
  Key? key;
  TopicViewState({this.key});

  bool isLoading = false;
  String next = "", previous = "";
  List<YarnTopic> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController = RefreshController(initialRefresh: false);
  String? selectedId;

  @override
  void initState() {
    getYarnTopic(categoryId: widget.selectedCategory);
    super.initState();
  }

  void getYarnTopic({String type = "topic", bool isType = true, String? categoryId}) async {
    if (categoryId != null) {
      selectedId = categoryId;
    }
    debugPrint("NEXT URL1:- $next");
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth().getAllTopics(next, previous,type: type, isType: isType, categoryId: categoryId);

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
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _postRefreshController,
      onRefresh: onPostRefresh,
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    print("IS LOADING:- $isLoading");
    if (isLoading) {
      return AskLoader();
    }
    if (!noList) {
      return ListView.separated(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 22),
        itemCount: yarnTopicList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
              if(yarnTopicList[index].enableCommenting ?? false) {
                await NavigationUtil.push(
                  context,
                  screen: AskDetailScreen(yarnTopic: yarnTopicList[index]),
                );
              }
              if(mounted) setState(() {});
            },
            child: AskPosts(
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
              isImages: yarnTopicList[index].media != null && yarnTopicList[index].media!.isNotEmpty ? true : false,
              yarnTopic: yarnTopicList[index],
            ),
          );
        },
        separatorBuilder: (context, int) {
          return SizedBox(height: 8,);
        },
      );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
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
