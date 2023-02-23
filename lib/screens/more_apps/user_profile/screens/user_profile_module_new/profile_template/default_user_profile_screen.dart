import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/get_app_bar_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:flutter/material.dart';

class DefaultUserProfileScreen extends StatefulWidget {
  CustomerProfile? searchedUser;
  String? searchedUserName;
  int currentIndex = 1;
  TabController? tabController;
  PageController? pageController;
  bool isOwner;
  bool isLoading;

  DefaultUserProfileScreen({
    Key? key,
    required this.searchedUser,
    required this.searchedUserName,
    required this.tabController,
    required this.currentIndex,
    required this.pageController,
    required this.isOwner,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<DefaultUserProfileScreen> createState() =>
      _DefaultUserProfileScreenState();
}

class _DefaultUserProfileScreenState extends State<DefaultUserProfileScreen>
    with TickerProviderStateMixin {
  UserTabView? _currentUser;
  String? searchedUserName;
  CustomerProfile? searchedUser;
  bool? isOwner;
  bool appBarStatus = true;
  ScrollController? scrollController;

  @override
  void initState() {
    searchedUserName = widget.searchedUserName!;
    searchedUser = widget.searchedUser!;
    isOwner = widget.isOwner;

    // Define the tabs and their corresponding data for each user
    UserTabView userView = UserTabView(
      name: "user",
      tabs: [
        UserTab(
          label: "Yarn",
          child: yarnTab(searchedUserName),
          apiCall: () async => await fetchYarnData(searchedUserName),
        ),
        UserTab(
          label: "Channel",
          child: channelTab(searchedUserName),
          apiCall: () async => await fetchChannelData(searchedUserName),
        ),
        UserTab(
          label: "Post",
          child: postTab(searchedUser),
          apiCall: () async => await fetchPostData(searchedUserName),
        ),
        UserTab(
          label: "Moment",
          child: momentTab(searchedUser),
          apiCall: () async => await fetchMomentData(searchedUserName),
        ),
      ],
    );

    // Set the current user here
    _currentUser = userView;

    widget.tabController = TabController(
      length: _currentUser!.tabs.where((tab) => tab.apiCall != null).length,
      vsync: this,
    );

    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);

    // isLoading = false;
    if (mounted) setState(() {});

    super.initState();
  }

  void _scrollListener() {
    if (isShrink != appBarStatus) {
      appBarStatus = isShrink;
      if (mounted) setState(() {});
    }
  }

  bool get isShrink {
    return (scrollController?.hasClients ?? false) &&
        (scrollController?.offset ?? 0) > (150 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
          return <Widget>[
            GetAppbarTile(
              searchedUser: searchedUser!,
              isLoading: widget.isLoading,
              isShrink: isShrink,
              scrollController: scrollController,
            ),
            SliverPersistentHeader(
              key: UniqueKey(),
              floating: true,
              pinned: true,
              delegate: SliverAppBarDelegate(
                TabBar(
                  controller: widget.tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(),
                  onTap: (int index) {
                    changeIndex(index);
                  },
                  tabs: getTabsWidget(),
                ),
              ),
            )
          ];
        },
        body: getTabViewLayout(),
      ),
    );
  }

  List<Widget> getTabsWidget() {
    return getTabs();
  }

  void changeIndex(int index) {
    widget.currentIndex = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageController!.hasClients) {
        widget.pageController!.animateToPage(widget.currentIndex!,
            duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
      }
    });

    setState(() {});
  }

  Widget getTabUI({String title = "", @required int? tabIndex}) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.tabController?.index == tabIndex ? 16 : 18,
            vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color:
              widget.tabController?.index == tabIndex ? navyBlue : Colors.white,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: widget.tabController?.index == tabIndex
                ? white
                : HexColor("#78797A"),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  getTabViewLayout() {
    return TabBarView(
      controller: widget.tabController,
      children: _currentUser!.tabs
          .map((tab) => FutureBuilder(
                future: tab.apiCall!(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // By default, show a loading spinner
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    List<dynamic>? data = snapshot.data as List?;

                    if (data!.isEmpty) {
                      return NoItemInList(
                        msg: AppLocalization.of(context)!.noResultFound,
                      );
                    } else {
                      return PageView(
                        children: List<Widget>.generate(
                          data!.length,
                          (index) {
                            index++;
                            return tab.child!;
                          },
                        ),
                        controller: widget.pageController,
                        onPageChanged: (int index) {
                          widget.tabController!.index = index;
                          widget.currentIndex = index;
                          if (mounted) setState(() {});
                        },
                      );
                    }
                  } else {
                    return NoItemInList(
                      msg: AppLocalization.of(context)!.noResultFound,
                    );
                  }
                },
              ))
          .toList(),
    );
  }

  List<Widget> getTabs() {
    List<Widget> tabs = [];
    int index = 0;

    _currentUser!.tabs.where((tab) => tab.apiCall != null).map((tab) {
      tabs.add(getTabUI(title: tab.label.toString(), tabIndex: index));
      index++;
    }).toList();

    return tabs;
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
          searchedUser = null;
          Navigator.pop(context);
        },
      ),
      title: widget.isLoading
          ? SizedBox.shrink()
          : userNameWithVerifiedIcon(
              name: searchedUser!.displayName()!,
              isVerified: searchedUser!.isVerified),
    );
  }
}
