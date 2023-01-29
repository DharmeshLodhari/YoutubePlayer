import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
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

class SavedYarn extends StatefulWidget {
  final String? selectedCategory;
  SavedYarn({Key? key, this.selectedCategory}) : super(key: key);
  @override
  State<SavedYarn> createState() => SavedYarnState(key: key);
}

class SavedYarnState extends State<SavedYarn> {
  Key? key;
  SavedYarnState({this.key});

  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  ScrollController _scrollController = new ScrollController();
  late DashboardBloc _dashboardBloc;
  late UserBloc userBloc;

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
    debugPrint("NEXT URL1:- $next");
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth().getAllSavedYarn(
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
        if (mounted && tempList.isNotEmpty) {
          setState(() {
            noList = false;
            isLoading = false;

            yarnTopicList.addAll(tempList);
          });

          tempList.forEach((value) {});
        }

        for (var item in yarnTopicList) {
          // debugPrint("YARN TOPICS List:- ${item.viewersAvatars.toString()}");
          debugPrint("YARN TOPICS List body:::- ${item.body}");
        }
      }
    }
    if (yarnTopicList.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    } else if (next == null && yarnTopicList.length > 6) {}
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
          duration: Duration(seconds: 3),
          curve: Curves.easeOut,
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: yarnBlack,
        ),
        controller: refreshController,
        onRefresh: onRefresh,
        child: _buildListView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saved Yarn',
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: yarnBlack,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  NavigationUtil.push(
                    context,
                    screen: SearchScreen(
                        // askCategory: widget.askCategories,
                        ),
                  );
                },
                child: Icon(
                  Icons.search_rounded,
                  color: yarnBlack,
                  size: 26,
                ),
              ),
              SizedBox(width: 17),
            ],
          ),
        ],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: yarnBlack,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                  screen: YarnDetailScreen(yarn: yarnTopicList[index]),
                );
              }
              if (mounted) setState(() {});
            },
            child: YarnTile(
              yarn: yarnTopicList[index],
              onDeleteYarn: (Yarn yarn) {
                int index = yarnTopicList
                    .indexWhere((element) => element.id == yarn.id);
                if (index != -1) {
                  yarnTopicList.removeAt(index);
                  if (mounted) setState(() {});
                }
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
}
