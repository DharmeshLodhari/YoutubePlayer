import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/no_item_in_list.dart';
import '../models/Topics/yarn_model.dart';
import '../tiles/yarn_list_tile.dart';
import '../yarn_auth.dart';
import '../yarn_detail_screen.dart';

class MyFeedView extends StatefulWidget {
  final String? selectedCategory;
  final String? userName;
  final String? isChannel;

  MyFeedView({Key? key, this.selectedCategory, this.userName, this.isChannel})
      : super(key: key);

  @override
  State<MyFeedView> createState() => MyFeedViewState(key: key);
}

class MyFeedViewState extends State<MyFeedView> {
  Key? key;

  MyFeedViewState({this.key});

  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  List<Yarn> deleteYarnTopicList = [];
  int count = 0;
  bool noList = false;
  final RefreshController _postRefreshController =
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

        final Map<String, dynamic>? result = await YarnAuth().getAllYarn(
            next, previous ?? "",
            type: type,
            isType: isType,
            categoryId: categoryId,
            userName: widget.userName,
            isChannel: widget.isChannel);

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
        final tempList = result['results'];

        ///check if refresh list doesn't contain deleted yarn

        if (tempList.isNotEmpty) {
          noList = false;
          isLoading = false;

          for (Yarn obj1 in tempList) {
            bool found = false;
            for (Yarn obj2 in deleteYarnTopicList) {
              if (obj1.id == obj2.id) {
                found = true;
                break;
              }
            }
            if (!found) {
              yarnTopicList.add(obj1);
            }
          }

          if (mounted) setState(() {});
        }
        // debugPrint("YARN TOPICS Feed:- $yarnTopicList");

        for (var item in yarnTopicList) {
          debugPrint("YARN TOPICS Feed:- ${item.viewersAvatars.toString()}");
          // debugPrint("YARN TOPICS Feed body:::- ${item.body}");
          // debugPrint("YARN TOPICS Feed :::- ${item}");
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
      //   _askCategoriesScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
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
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: yarnTopicList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == yarnTopicList.length) {
            return buildShimmerLoadingIndicator(isLoading: isLoading);
          }

          return InkWell(
            onTap: () async {
              if (yarnTopicList[index].enableCommenting ?? false) {
                await NavigationUtil.push(
                  context,
                  screen: YarnDetailScreen(
                    yarn: yarnTopicList[index],
                    onDeleteYarn: (Yarn yarn) {
                      deleteYarnTopicList.add(yarn);
                      yarnTopicList.removeWhere((item) => item.id == yarn.id);
                      if (mounted) setState(() {});
                    },
                  ),
                );
              }
              if (mounted) setState(() {});
            },
            child: YarnTile(
              yarn: yarnTopicList[index],
              onDeleteYarn: (Yarn yarn) {
                deleteYarnTopicList.add(yarn);
                yarnTopicList.removeWhere((item) => item.id == yarn.id);
                if (mounted) setState(() {});
              },
              onReYarn: (Yarn yarn) {
                yarnTopicList.insert(0, yarn);
                if (mounted) setState(() {});
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Column(
            children: [
              const SizedBox(
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

  void _onPostRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
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
