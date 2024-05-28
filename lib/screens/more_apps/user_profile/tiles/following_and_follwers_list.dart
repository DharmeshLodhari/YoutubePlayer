import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/widget/custom_slydo_usercard.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../utils/util.dart';
import '../../../moments/models/comment_model.dart';
import '../models/user.dart';
import '../user_auth.dart';

class FollowingAndFollowersList extends StatefulWidget {
  final String userName;
  final int index;
  const FollowingAndFollowersList(
      {Key? key, required this.userName, this.index = 0})
      : super(key: key);

  @override
  _FollowingAndFollowersListState createState() =>
      _FollowingAndFollowersListState();
}

class _FollowingAndFollowersListState extends State<FollowingAndFollowersList> {
  late int currentIndex;
  late AppLocalization appLocalization;

  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        getTitle(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar() as PreferredSizeWidget?,
    );
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.following,
                style: TextStyle(
                  color: currentIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.followers,
                style: TextStyle(
                  color: currentIndex == 1 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getTitle() {
    if (currentIndex == 0) {
      return AppLocalization.of(context)!.following;
    } else if (currentIndex == 1) {
      return AppLocalization.of(context)!.followers;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: tabViews(),
      ),
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        // GlobalListViewWidget(
        //   customWidget: (custom) {
        //     return CustomSlydoUserCard(user: custom);
        //   },
        //   apiFunc: getListOfFollowersL(),
        // ),
        FollowAndFollowersList(isFollowing: true, userName: widget.userName),
        FollowAndFollowersList(isFollowing: false, userName: widget.userName),
      ],
    );
  }
}

Future<BasePaginationModel<List>> getListOfFollowersL() async {
  return UserAuth().getFollowingOrFollowersList(
      nextUrl: '', username: '', isFollowingUser: true);
}

class FollowAndFollowersList extends StatefulWidget {
  final String userName;
  final bool isFollowing;
  const FollowAndFollowersList(
      {Key? key, required this.userName, required this.isFollowing})
      : super(key: key);

  @override
  _FollowAndFollowersListState createState() => _FollowAndFollowersListState();
}

class _FollowAndFollowersListState extends State<FollowAndFollowersList> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool isFirstTime = true;
  bool noItemInList = false;
  List<CustomerProfile> usersList = [];
  ScrollController _scrollCtrl = ScrollController();
  RefreshController _refreshCtrl = RefreshController(initialRefresh: false);
  BasePaginationModel<List<CustomerProfile>>? basePaginationModel;

  @override
  void initState() {
    super.initState();
    getListOfFollowers();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
          _scrollCtrl.position.pixels != 0) {
        getListOfFollowers();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void getListOfFollowers() {
    if (isFirstTime == false) {
      if (nextPageUrl == null || nextPageUrl!.isEmpty) return;
    }
    if (mounted) setState(() => _isLoading = true);

    UserAuth()
        .getFollowingOrFollowersList(
            nextUrl: nextPageUrl,
            username: widget.userName,
            isFollowingUser: widget.isFollowing)
        .then((value) {
      if (mounted) setState(() => _isLoading = false);

      basePaginationModel = value;
      usersList.addAll(value.result);
      nextPageUrl = basePaginationModel!.next;
      isFirstTime = false;

      if (usersList.isEmpty) {
        if (mounted) setState(() => noItemInList = true);
      }
    }).catchError((e) {
      if (mounted) setState(() => _isLoading = false);

      isFirstTime = false;

      showToast(message: e.toString());
      Navigator.pop(context);
    });
  }

  _onRefresh() {
    isFirstTime = true;
    usersList.clear();
    nextPageUrl = null;
    getListOfFollowers();
    _refreshCtrl.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return noItemInList
        ? NoItemInList(
            msg: widget.isFollowing
                ? AppLocalization.of(context)!.noFollowingUsers
                : AppLocalization.of(context)!.noFollowers,
          )
        : _isLoading && usersList.isEmpty
            ? buildLoadingIndicator(isLoading: _isLoading)
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshCtrl,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollCtrl,
                  itemCount: usersList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == usersList.length) {
                      return buildJumpingLoadingIndicator(
                          isLoading: _isLoading);
                    } else {
                      return CustomSlydoUserCard(user: usersList[index]);
                    }
                  },
                ),
              );
  }
}
