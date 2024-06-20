import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/Topics/yarn_model.dart';
import 'tiles/yarn_list_tile.dart';
import 'yarn_auth.dart';
import 'yarn_detail_screen.dart';

class SavedYarn extends StatefulWidget {
  final String? selectedCategory;

  SavedYarn({super.key, this.selectedCategory});

  @override
  State<SavedYarn> createState() => SavedYarnState(key: key);
}

class SavedYarnState extends State<SavedYarn> {
  Key? key;

  SavedYarnState({this.key});

  bool isLoading = false;
  String? next = "", previous = "";
  List<Yarn> yarnTopicList = [];
  List<Yarn> deleteYarnTopicList = [];
  int count = 0;
  bool noList = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String? selectedId;
  final ScrollController _scrollController = ScrollController();
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

        final Map<String, dynamic>? result = await YarnAuth().getAllSavedYarn(
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
        final tempList = result['results'];

        // if (mounted && tempList.isNotEmpty) {
        //   setState(() {
        //     noList = false;
        //     isLoading = false;
        //
        //     yarnTopicList.addAll(tempList);
        //   });
        //
        //   tempList.forEach((value) {});
        // }

        ///check if refresh list doesn't contain deleted yarn

        if (tempList.isNotEmpty) {
          noList = false;
          isLoading = false;
          // yarnTopicList.addAll(tempList);

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

          tempList.forEach((value) {});

          if (mounted) setState(() {});
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
    return Scaffold(
      backgroundColor: lightGrey,
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
      preferredSize: const Size.fromHeight(50.0),
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
                    screen: SearchScreen(),
                  );
                },
                child: Icon(
                  Icons.search_rounded,
                  color: yarnBlack,
                  size: 26,
                ),
              ),
              const SizedBox(width: 17),
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
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        controller: _scrollController,
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
              onUpdateYarn: (Yarn yarn) {
                final int index = yarnTopicList
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

  void onRefresh() async {
    if (await checkConnection(context)) {
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
      setState(() {
        refreshController.refreshCompleted();
      });
    }
  }
}
