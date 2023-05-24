import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
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
  Function(bool)? onPageRefresh;

  YarnListScreen({
    Key? key,
    this.selectedCategory,
    this.onPageRefresh,
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
  int count = 0;
  bool noList = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  ScrollController _scrollController = new ScrollController();
  late YarnDashboardBloc yarnDashboardBloc;
  late DashboardBloc _dashboardBloc;

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

          List<Yarn> createYarnTopicList =
              List.from(yarnDashboardBloc.createYarnTopicList);
          List<Yarn> deleteYarnTopicList =
              List.from(yarnDashboardBloc.deleteYarnTopicList);
          List<Yarn> reYarnTopicList =
              List.from(yarnDashboardBloc.reYarnTopicList);

          /// Get the common CreateYarnTopicList objects in both lists
          List<Yarn> commonCreateYarnTopicList = tempList
              .where((o1) => createYarnTopicList.any((o2) => o2.id == o1.id))
              .toList();

          /// Remove the common reYarnTopicList objects from the main list
          yarnDashboardBloc.createYarnTopicList.removeWhere(
              (o1) => commonCreateYarnTopicList.any((o2) => o2.id == o1.id));

          /// Get the common reYarnTopicList objects in both lists
          List<Yarn> commonReYarnTopicList = tempList
              .where((o1) => reYarnTopicList.any((o2) => o2.id == o1.id))
              .toList();

          /// Remove the common reYarnTopicList objects from the main list
          yarnDashboardBloc.reYarnTopicList.removeWhere(
              (o1) => commonReYarnTopicList.any((o2) => o2.id == o1.id));

          if (yarnDashboardBloc.createYarnTopicList.isNotEmpty) {
            ///add createYarnTopicList to tempList if any
            if (widget.selectedCategory != null) {
              // Filter the list of createYarnTopicList by id
              List<Yarn>? filteredListCreateYarnTopicList = yarnDashboardBloc
                  .createYarnTopicList
                  .where((item) => item.category!.id == widget.selectedCategory)
                  .toList();

              // Check if any matching createYarnTopicList
              if (filteredListCreateYarnTopicList.isNotEmpty) {
                filteredListCreateYarnTopicList.forEach((item) {
                  tempList.insert(0, item);
                });
              }
            } else {
              yarnDashboardBloc.createYarnTopicList.forEach((item) {
                tempList.insert(0, item);
              });
            }
          }

          if (yarnDashboardBloc.reYarnTopicList.isNotEmpty) {
            ///add reYarnTopicList to tempList if any

            if (widget.selectedCategory != null) {
              // Filter the list of reYarnTopicList by id
              List<Yarn>? filteredListReYarnTopicList = yarnDashboardBloc
                  .reYarnTopicList
                  .where((item) =>
                      item.reYarn!.category!.id == widget.selectedCategory)
                  .toList();

              // Check if any matching reYarnTopicList
              if (filteredListReYarnTopicList.isNotEmpty) {
                filteredListReYarnTopicList.forEach((item) {
                  tempList.insert(0, item);
                });
              }

              // List<Yarn>? filteredListTempList = tempList
              //     .where((item) =>
              //         item.reYarn!.category!.id == widget.selectedCategory)
              //     .toList();
              //
              // // Check if any matching tempList for reyarn
              // if (filteredListTempList!.isNotEmpty) {
              //   filteredListTempList.forEach((item) {
              //     tempList.insert(0, item);
              //   });
              // }
            } else {
              yarnDashboardBloc.reYarnTopicList.forEach((item) {
                tempList.insert(0, item);
              });
            }
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
                // debugPrint('Check category delete batch :::: ${obj1.id}');
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
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    /// check if yarn bottom navigation is clicked
    /// scroll back to the top of the page
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

    /// check if scroll controller is at the top, send call back to
    /// yarn dashboard to set category as visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.pixels == 0) {
        // Scroll controller is at the top
        widget.onPageRefresh!(true);
        if (mounted) setState(() {});
      }
    });

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
                      List<Yarn> tempList = [];
                      tempList.add(yarn);
                      yarnDashboardBloc.addDeleteYarnTopicList(tempList);
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
                List<Yarn> tempList = [];
                tempList.add(yarn);
                yarnDashboardBloc.addDeleteYarnTopicList(tempList);
                yarnTopicList.removeWhere((item) => item.id == yarn.id);
                if (mounted) setState(() {});
              },
              onReYarn: (Yarn yarn) {
                List<Yarn> tempList = [];
                tempList.add(yarn);
                yarnDashboardBloc.addReYarnTopicList(tempList);
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
              checkIfReyarned: yarnDashboardBloc.reYarnTopicList,
              reloadView: (bool val){
                if(val == true){
                  onRefresh();
                }
              },
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
    List<Yarn> tempList = [];
    tempList.add(yarnTopic!);
    yarnDashboardBloc.addCreateYarnTopicList(tempList);

    if (mounted) setState(() {});
  }
}
