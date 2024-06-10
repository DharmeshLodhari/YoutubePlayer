import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/tile/user_post_tile.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPostList extends StatefulWidget {
  final CustomerProfile? user;
  final String? titleToSearch;
  final String? channelUserName;

  const UserPostList(
      {@required this.user, this.titleToSearch, this.channelUserName, Key? key})
      : super(key: key);

  @override
  _UserPostListState createState() => _UserPostListState();
}

class _UserPostListState extends State<UserPostList> {
  int? postCount = 0;
  String? postNext = "";
  String? postPrevious = "";
  bool isPostLoading = false;
  List<UserPost> postList = [];
  final ScrollController _postScrollController = ScrollController();

  bool isFirstTime = true;
  bool noPostInList = false;
  final GlobalKey<ScaffoldState> _postScaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    debugPrint('CUSTOMER PROFILE ---> ${widget.user!.toJson()}');
    getPostList();
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
    if (await checkConnection(context)) {
      postCount = 0;
      postNext = "";
      postPrevious = "";
      postList = [];
      isFirstTime = true;
      if (mounted) setState(() {});
      getPostList();
      _postRefreshController.refreshCompleted();
    } else {
      _postRefreshController.refreshCompleted();
    }
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
    Map<String, dynamic>? result;
    if (!isPostLoading) {
      if (postNext != null && !isPostLoading) {
        isPostLoading = true;
        if (mounted) setState(() {});

        try {
          result = await UserPostAuth().listUserPosts(
              next: postNext,
              userName: widget.user!.userName,
              channelUserName: widget.channelUserName);
        } catch (e) {
          isPostLoading = false;
          noPostInList = true;
          if (mounted) {
            setState(() {});
          }
          // showToast(
          //     message: 'Server error. Please refresh ::: ${e.toString()}');
          return;
        }

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
        final List tempList = result['results'] as List;

        final List<UserPost> posts = [];

        for (var element in tempList) {
          posts.add(UserPost.fromJson(element));
        }

        if (mounted) {
          setState(() {
            noPostInList = false;
            isPostLoading = false;
            postList.addAll(posts);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        duration: const Duration(milliseconds: 500),
      ));
    }
  }

  Widget _buildPostList() {
    return noPostInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noPosts,
          )
        : isPostLoading && postList.isEmpty
            ? buildLoadingIndicator(isLoading: isPostLoading)
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                    right: 16, left: 16, top: 8, bottom: 0),
                controller: _postScrollController,
                itemCount: postList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == postList.length) {
                    return buildJumpingLoadingIndicator(
                        isLoading: isPostLoading);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostTile(
                        post: postList[index],
                        showAuthorDetails: false,
                        onDeleteBlog: () {
                          debugPrint('DELETED FROM DETAILS PAGE');
                          _onPostRefresh();
                        },
                      ),
                    );
                  }
                },
              );
  }
}
