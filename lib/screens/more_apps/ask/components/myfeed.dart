import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../ask_auth.dart';
import '../ask_detail_screen.dart';
import '../models/Topics/YarnTopic.dart';
import 'ask_options.dart';
import 'ask_posts_view.dart';

class MyFeedView extends StatefulWidget {
  const MyFeedView({Key? key}) : super(key: key);

  @override
  State<MyFeedView> createState() => _MyFeedViewState();
}

class _MyFeedViewState extends State<MyFeedView> {


  bool isLoading = false;
  String next = "", previous = "";
  List<YarnTopic> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    getYarnTopic("my-topics", false);
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
            onRefresh: _onPostRefresh,
            child: !isLoading ? !noList ? ListView.builder(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 22),
              itemCount: yarnTopicList.length,
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
                    isImages: yarnTopicList[index].image != null ? true : false,
                    images: yarnTopicList[index].image != null ? yarnTopicList[index].image : [],
                    title: yarnTopicList[index].title,
                    body: yarnTopicList[index].body,
                    authorName: yarnTopicList[index].authorName,
                    authorAvatar: yarnTopicList[index].authorAvatar,
                    tags: yarnTopicList[index].tags != null ? yarnTopicList[index].tags : [],
                  ),
                );
              },
            ) : Center(child: Text("No Post"),) : Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: greyBorderColor,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
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

        getYarnTopic("my-topics", false);
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
