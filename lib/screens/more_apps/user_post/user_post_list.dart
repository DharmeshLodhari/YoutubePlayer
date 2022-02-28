import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/tile/user_post_tile.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPostList extends StatefulWidget {
  CustomerProfile? user;
  UserPostList({@required this.user, Key? key}) : super(key: key);
  @override
  _UserPostListState createState() => _UserPostListState();
}

class _UserPostListState extends State<UserPostList> {
  int? postCount = 0;
  String? postNext = "";
  String? postPrevious = "";
  bool isPostLoading = false;
  List<UserPost> postList = [];
  ScrollController _postScrollController = new ScrollController();

  bool noPostInList = false;
  GlobalKey<ScaffoldState> _postScaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    this.getPostList();
    _postScrollController.addListener(() {
      if (_postScrollController.position.pixels ==
              _postScrollController.position.maxScrollExtent &&
          _postScrollController.position.pixels != 0) {
        getPostList();
      }
    });

    super.initState();
  }

  void _onPostRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        postCount = 0;
        postNext = "";
        postPrevious = "";
        postList = [];
        debugPrint("Refresh called on posts!!  ");
        getPostList();
        _postRefreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _postRefreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _postScaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        color: lightGrey,
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _postRefreshController,
          onRefresh: _onPostRefresh,
          child: _buildPostList(),
        ),
      ),
    );
  }

  Future<void> getPostList() async {
    if (!isPostLoading) {
      if (postNext != null && !isPostLoading) {
        isPostLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result =
            await UserPostAuth().listUserPosts(userName: widget.user!.userName);

        if (result == null) {
          isPostLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        postCount = result['count'];
        postNext = result['next'];
        postPrevious = result['previous'];
        List tempList = result['results'] as List;

        List<UserPost> reviews = [];
        tempList.forEach((element) {
          reviews.add(UserPost.fromJson(element));
        });
        if (mounted) {
          setState(() {
            noPostInList = false;
            isPostLoading = false;
            postList.addAll(reviews);
          });
        }
      }
    }
    if (postList.isEmpty) {
      if (mounted) {
        setState(() {
          noPostInList = true;
        });
      }
    } else if (postNext == null && postList.length > 15) {
      _postScaffoldKey.currentState!.showSnackBar(SnackBar(
        content:
            Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        duration: Duration(milliseconds: 500),
      ));
    }
  }

  Widget _buildPostList() {
    return noPostInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noPosts,
          )
        : ListView.builder(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            controller: _postScrollController,
            itemCount: postList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == postList.length) {
                return _buildReviewIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostTile(
                    post: postList[index],
                    postOfUser: widget.user,
                  ),
                );
              }
            },
          );
  }

  Widget _buildReviewIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPostLoading ? 1.0 : 00,
          child: isPostLoading ? CircularLoadingIndicator() : Container(),
        ),
      ),
    );
  }
}
