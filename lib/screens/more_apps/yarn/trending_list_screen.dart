import 'package:Slydo/data/state_notifier.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/noItemInList.dart';
import 'models/Topics/yarn_model.dart';
import 'tiles/yarn_list_tile.dart';
import 'widgets/yarn_shimmer.dart';
import 'yarn_auth.dart';
import 'yarn_detail_screen.dart';

class TrendingListScreen extends StatefulWidget {
  final String? selectedCategory;
  Function(bool)? onPageRefresh;

  TrendingListScreen({Key? key, this.selectedCategory, this.onPageRefresh})
      : super(key: key);

  @override
  State<TrendingListScreen> createState() => TrendingListScreenState(key: key);
}

class TrendingListScreenState extends State<TrendingListScreen> {
  Key? key;

  TrendingListScreenState({this.key});

  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  List<Yarn> deleteYarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  ScrollController _trendingScrollController = new ScrollController();
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    getYarnTopic(categoryId: widget.selectedCategory);
    _trendingScrollController.addListener(() {
      if (_trendingScrollController.position.pixels ==
              _trendingScrollController.position.maxScrollExtent &&
          _trendingScrollController.position.pixels != 0) {
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

        String latestTrending = 'trending';

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
        // debugPrint("YARN TOPICS:- $yarnTopicList");
      }
    }
    if (yarnTopicList.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    /// check if yarn bottom navigation is clicked
    /// scroll back to the top of the page
    if (_dashboardBloc.topYarn == true) {
      _dashboardBloc.topYarn = false;
      if (_trendingScrollController.hasClients) {
        final position = _trendingScrollController.position.minScrollExtent;
        _trendingScrollController.animateTo(
          position,
          duration: Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    }

    /// check if scroll controller is at the top, send call back to
    /// yarn dashboard to set category as visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_trendingScrollController.position.pixels == 0) {
        // Scroll controller is at the top
        widget.onPageRefresh!(true);
        if (mounted) setState(() {});
      }
    });

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
    if (!noList) {
      return ListView.separated(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        controller: _trendingScrollController,
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
              reloadView: (bool val){
                if(val == true){
                  onPostRefresh();
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
