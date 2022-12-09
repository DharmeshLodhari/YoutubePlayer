import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/noItemInList.dart';
import '../models/Topics/YarnTopic.dart';
import '../tiles/yarn_list_tile.dart';
import '../yarn_auth.dart';
import '../yarn_detail_screen.dart';
import 'yarn_options.dart';

class MyFeedView extends StatefulWidget {
  String? selectedCategory;
  String? userName;
  MyFeedView({Key? key, this.selectedCategory, this.userName})
      : super(key: key);

  @override
  State<MyFeedView> createState() => MyFeedViewState(key: key);
}

class MyFeedViewState extends State<MyFeedView> {
  Key? key;
  MyFeedViewState({this.key});
  bool isLoading = false;
  String next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;

  @override
  void initState() {
    getYarnTopic(categoryId: widget.selectedCategory);
    super.initState();
  }

  void getYarnTopic(
      {String type = "my-topics",
      bool isType = false,
      String? categoryId}) async {
    debugPrint("USER NAME:- ${widget.userName}");
    if (categoryId != null) {
      selectedId = categoryId;
    }
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth().getAllYarn(
            next, previous,
            type: type,
            isType: isType,
            categoryId: categoryId,
            userName: widget.userName);

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
            child: _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (!noList) {
      return ListView.separated(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: yarnTopicList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == yarnTopicList.length) {
            return _buildLoadingIndicator();
          }
          return InkWell(
            onTap: () async {
              if (yarnTopicList[index].enableCommenting ??
                  false) {
                await NavigationUtil.push(
                  context,
                  screen: YarnDetailScreen(
                      yarn: yarnTopicList[index]),
                );
              }
              if (mounted) setState(() {});
            },
            child: YarnTile(
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
                      child: YarnOptions(
                        yarnTopic: yarnTopicList[index],
                      ),
                    );
                  },
                );
              },
              yarn: yarnTopicList[index],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                color: greySecondaryYarn,
              ),
            ],
          );
        },
      );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isLoading ? 1.0 : 00,
      child: isLoading ? YarnShimmer() : Container(),
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
