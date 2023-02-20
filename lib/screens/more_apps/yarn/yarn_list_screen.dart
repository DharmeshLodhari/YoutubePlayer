import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/noItemInList.dart';
import 'models/Topics/yarn_model.dart';
import 'tiles/yarn_list_tile.dart';
import 'widgets/yarn_shimmer.dart';
import 'yarn_auth.dart';
import 'yarn_detail_screen.dart';

class YarnListScreen extends StatefulWidget {
  final String? selectedCategory;

  YarnListScreen({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<YarnListScreen> createState() => YarnListScreenState(key: key);
}

class YarnListScreenState extends State<YarnListScreen> {
  Key? key;

  YarnListScreenState({this.key});

  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  List<Yarn> deleteYarnTopicList = [];
  List<Yarn> createYarnTopicList = [];
  List<Yarn> reYarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  ScrollController _scrollController = new ScrollController();
  late DashboardBloc _dashboardBloc;
  // bool? create = false;
  // Yarn? createYarn;

  @override
  void initState() {
    getYarnList(categoryId: widget.selectedCategory);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getYarnList(categoryId: widget.selectedCategory);
      }
    });

    super.initState();
  }

  void getYarnList(
      {String type = "topic", bool isType = true, String? categoryId}) async {
    if (categoryId != null) {
      selectedId = categoryId;
    }

    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        String latestTrending = 'latest';

        Map<String, dynamic>? result = await YarnAuth().getAllYarn(
            next, previous ?? '',
            type: type,
            isType: isType,
            categoryId: categoryId,
            latestTrending: latestTrending);

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

        if (tempList.isNotEmpty) {
          noList = false;
          isLoading = false;
          // yarnTopicList.addAll(tempList);

          for (var obj1 in tempList) {
            ///check if tempList id is same in reYarnTopicList id
            for (var reYarnTopic in reYarnTopicList) {
              if (obj1.id == reYarnTopic.id) {
                reYarnTopicList
                    .removeWhere((item) => item.id == reYarnTopic.id);
                if (mounted) setState(() {});
              }
            }

            ///check if tempList id is same in createYarnTopicList id
            for (var createYarnTopic in createYarnTopicList) {
              if (obj1.id == createYarnTopic.id) {
                createYarnTopicList.removeWhere((item) => item.id == obj1.id);
                if (mounted) setState(() {});
              }
            }
          }

          if (createYarnTopicList.isNotEmpty) {
            ///add createYarnTopicList to tempList if any
            for (var item in createYarnTopicList) {
              tempList.insert(0, item);
            }
            if (mounted) setState(() {});
          }

          if (reYarnTopicList.isNotEmpty) {
            ///add reYarnTopicList to tempList if any
            for (var item in reYarnTopicList) {
              tempList.insert(0, item);
            }
            if (mounted) setState(() {});
          }

          if (deleteYarnTopicList.isNotEmpty) {
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
                if (mounted) setState(() {});
              }
            }
          } else if (deleteYarnTopicList.isEmpty) {
            yarnTopicList.addAll(tempList);
          }

          if (mounted) setState(() {});
        }
      }
    }
    if (yarnTopicList.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    } else if (next == null && yarnTopicList.length > 6) {
      // _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //   content:
      //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //   duration: Duration(milliseconds: 500),
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    if (_dashboardBloc.topYarn == true) {
      _dashboardBloc.topYarn = false;
      if (_scrollController.hasClients) {
        final position = _scrollController.position.minScrollExtent;
        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    }

    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: yarnBlack,
      ),
      controller: refreshController,
      onRefresh: onRefresh,
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    if (!noList) {
      return ListView.separated(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        controller: _scrollController,
        itemCount: yarnTopicList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == yarnTopicList.length) {
            return _buildLoadingIndicator();
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
                reYarnTopicList.add(yarn);
                // yarnTopicList.insert(0, yarn);
                onRefresh();
                if (mounted) setState(() {});
              },
              onUpdateYarn: (Yarn yarn) {
                int index = yarnTopicList
                    .indexWhere((element) => element.id == yarn.id);
                yarnTopicList[index] = yarn;
                if (mounted) setState(() {});
              },
              navigateToReyarn: () {
                if (yarnTopicList[index].reYarn == null) return;
                NavigationUtil.push(
                  context,
                  screen: YarnDetailScreen(yarn: yarnTopicList[index].reYarn!),
                );
              },
              checkIfReyarned: reYarnTopicList,
            ),
          );
        },
        separatorBuilder: (context, int) {
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

  void onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        yarnTopicList = [];

        if (mounted) setState(() {});

        getYarnList(categoryId: selectedId);
        setState(() {
          refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          refreshController.refreshCompleted();
        });
      }
    });
  }

  void onCreateYarn(Yarn? yarnTopic) {
    createYarnTopicList.add(yarnTopic!);

    if (mounted) setState(() {});
  }
}
