import 'dart:async';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/blog/user_post/models/user_post.dart';
import 'package:Slydo/screens/blog/user_post/tile/user_post_tile.dart';
import 'package:Slydo/screens/blog/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SuperBlog extends StatefulWidget {
  const SuperBlog({super.key});

  @override
  State<SuperBlog> createState() => _SuperBlogState();
}

class _SuperBlogState extends State<SuperBlog> {
  late PageController _pageViewCtrl;
  SlydoBlogsMenu _slydoBlogsMenu = SlydoBlogsMenu.All;

  Timer? typingTimer;
  String? lastInputValue;
  String? titleToSearch;
  int? postCount = 0;
  int currentPage = 1;
  bool noPostInList = false;
  String? postNext = "";
  String? postPrevious = "";
  bool isFirstTime = true;
  bool isPostLoading = false;
  List<UserPost> postList = [];
  final ScrollController _postScrollController = ScrollController();

  // final GlobalKey<ScaffoldState> _postScaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);

  void resetAndGetListOfBlogs(String value) {
    titleToSearch = value;
    postCount = 0;
    postNext = '';
    postList.clear();
    postPrevious = '';
    getListOfBlogs();
  }

  Future<void> getListOfBlogs() async {
    Map<String, dynamic>? result;
    if (!isPostLoading) {
      if (postNext != null && !isPostLoading) {
        isPostLoading = true;
        if (mounted) setState(() {});

        try {
          result = await UserPostAuth().listAllPosts(
              next: postNext,
              titleToSearch: titleToSearch,
              slydoBlogsMenu: SlydoBlogsMenu.All);
        } catch (e) {
          isPostLoading = false;
          if (mounted) {
            setState(() {});
          }
          showToast(
              message: 'Server error. Please refresh ::: ${e.toString()}');
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

        // debugPrint("getListOFBlogs :$titleToSearch ");

        if (mounted) {
          setState(() {
            noPostInList = false;
            isPostLoading = false;
            // debugPrint("postList :$postList");
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
    } else if (postNext == null && postList.length > 6) {
      showReachedToBottomSnackBar();
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (postNext == null &&
          _postScrollController.position.pixels ==
              _postScrollController.position.maxScrollExtent &&
          _postScrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
        ();
      }
    }
  }

  @override
  void initState() {
    _pageViewCtrl = PageController(initialPage: 0);
    getListOfBlogs();
    _postScrollController.addListener(() {
      if (_postScrollController.position.pixels ==
              _postScrollController.position.maxScrollExtent &&
          !isPostLoading) {
        getListOfBlogs();
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

      getListOfBlogs();
      _postRefreshController.refreshCompleted();
    } else {
      _postRefreshController.refreshCompleted();
    }
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)?.blogs ?? "",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.CREATE_BLOG);
        },
        backgroundColor: navyBlue,
        mini: false,
        heroTag: null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              50.0), // Set the border radius to create a circle
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            searchBox(),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  pageViewTabItem(
                      pageNum: 0,
                      title: 'All',
                      slydoBlogsMenu: SlydoBlogsMenu.All),
                  pageViewTabItem(
                      pageNum: 1,
                      title: 'Latest',
                      slydoBlogsMenu: SlydoBlogsMenu.Latest),
                  pageViewTabItem(
                      pageNum: 2,
                      title: 'Trending',
                      slydoBlogsMenu: SlydoBlogsMenu.Trending),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                onPageChanged: (currentPage) {
                  if (currentPage == 0) {
                    setState(() {
                      _slydoBlogsMenu = SlydoBlogsMenu.All;
                    });
                  } else if (currentPage == 1) {
                    setState(() {
                      _slydoBlogsMenu = SlydoBlogsMenu.Latest;
                    });
                  } else {
                    setState(() {
                      _slydoBlogsMenu = SlydoBlogsMenu.Trending;
                    });
                  }
                },
                controller: _pageViewCtrl,
                children: [
                  if (noPostInList)
                    NoItemInList(
                      msg: AppLocalization.of(context)!.noPosts,
                    )
                  else
                    isPostLoading && postList.isEmpty
                        ? buildLoadingIndicator(isLoading: isPostLoading)
                        : SmartRefresher(
                            enablePullDown: true,
                            header: WaterDropHeader(
                              complete: Container(),
                              waterDropColor: navyBlue,
                            ),
                            controller: _postRefreshController,
                            onRefresh: _onPostRefresh,
                            child: ListView.builder(
                              physics: const ScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                      showAuthorDetails: true,
                                      onDeleteBlog: () {
                                        _onPostRefresh();
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                  const SlydoBlogsList(slydoBlogsMenu: SlydoBlogsMenu.Latest),
                  const SlydoBlogsList(slydoBlogsMenu: SlydoBlogsMenu.Trending),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pageViewTabItem(
      {required int pageNum,
      required String title,
      required SlydoBlogsMenu slydoBlogsMenu}) {
    return InkWell(
      onTap: () {
        _pageViewCtrl.jumpToPage(pageNum);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: _slydoBlogsMenu == slydoBlogsMenu ? navyBlue : Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _slydoBlogsMenu == slydoBlogsMenu ? white : blackFont,
            fontSize: 14,
            fontWeight: _slydoBlogsMenu == slydoBlogsMenu
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          onChanged: _onChanged,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                SlydoAppIcon.search,
                color: darkGrey,
                size: 14,
              ),
              onPressed: () {},
            ),
            hintText: "Search",
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChanged(String value) {
    if (_pageViewCtrl.page != 0) {
      _pageViewCtrl.jumpToPage(0);
    }
    if (value.isNotEmpty && lastInputValue != value) {
      lastInputValue = value;
      const duration = Duration(seconds: 1);
      if (typingTimer != null) {
        setState(() => typingTimer!.cancel()); // clear timer
      }
      typingTimer = Timer(
        duration,
        () {
          resetAndGetListOfBlogs(value);
        },
      );
    } else {
      // debugPrint('VALUE IS EMPTY');
      resetAndGetListOfBlogs(value);
    }
  }
}

class SlydoBlogsList extends StatefulWidget {
  final SlydoBlogsMenu slydoBlogsMenu;
  const SlydoBlogsList({super.key, required this.slydoBlogsMenu});

  @override
  State<SlydoBlogsList> createState() => _SlydoBlogsListState();
}

class _SlydoBlogsListState extends State<SlydoBlogsList> {
  Timer? typingTimer;
  String? lastInputValue;
  String? titleToSearch;
  int? postCount = 0;
  bool noPostInList = false;
  String? postNext = "";
  String? postPrevious = "";
  bool isFirstTime = true;
  bool isPostLoading = false;
  List<UserPost> postList = [];
  final ScrollController _postScrollController = ScrollController();

  // final GlobalKey<ScaffoldState> _postScaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);

  void resetAndGetListOfBlogs(String value) {
    titleToSearch = value;
    postCount = 0;
    postNext = '';
    postList.clear();
    postPrevious = '';
    getListOfBlogs();
  }

  Future<void> getListOfBlogs() async {
    Map<String, dynamic>? result;
    if (!isPostLoading) {
      if (postNext != null && !isPostLoading) {
        if (mounted) {
          setState(() {
            isPostLoading = true;
          });
        }
        try {
          result = await UserPostAuth().listAllPosts(
              next: postNext,
              titleToSearch: titleToSearch,
              slydoBlogsMenu: widget.slydoBlogsMenu);
        } catch (e) {
          isPostLoading = false;
          if (mounted) {
            setState(() {});
          }
          showToast(
              message: 'Server error. Please refresh ::: ${e.toString()}');
          return;
        }

        if (result == null) {
          isPostLoading = false;
          if (mounted) setState(() {});
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

        // debugPrint("getListOFBlogs :$titleToSearch ");

        if (mounted) {
          setState(() {
            noPostInList = false;
            isPostLoading = false;
            // debugPrint("postList :$postList");
            postList.addAll(posts);
          });
        }
      }
    }
    if (isFirstTime && postNext != null && postNext != "") {
      isFirstTime = false;
      getListOfBlogs();
    }
    if (postList.isEmpty) {
      if (mounted) {
        setState(() {
          noPostInList = true;
        });
      }
    } else if (postNext == null && postList.length > 3) {
      showReachedToBottomSnackBar();
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (postNext == null &&
          _postScrollController.position.pixels ==
              _postScrollController.position.maxScrollExtent &&
          _postScrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void initState() {
    getListOfBlogs();
    _postScrollController.addListener(() {
      if (_postScrollController.position.pixels ==
              _postScrollController.position.maxScrollExtent &&
          !isPostLoading) {
        getListOfBlogs();
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

      getListOfBlogs();
      _postRefreshController.refreshCompleted();
    } else {
      _postRefreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Expanded(
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
      ],
    );
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
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
                        showAuthorDetails: true,
                        onDeleteBlog: () {
                          _onPostRefresh();
                        },
                      ),
                    );
                  }
                },
              );
  }
}

enum SlydoBlogsMenu {
  All,
  Latest,
  Trending,
}
