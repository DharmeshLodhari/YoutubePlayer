import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/get_app_bar_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class DefaultUserProfileScreen extends StatefulWidget {
  CustomerProfile? searchedUser;
  String? searchedUserName;
  bool isOwner;
  bool isLoading;

  DefaultUserProfileScreen({
    Key? key,
    required this.searchedUser,
    required this.searchedUserName,
    required this.isOwner,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<DefaultUserProfileScreen> createState() =>
      _DefaultUserProfileScreenState();
}

class _DefaultUserProfileScreenState extends State<DefaultUserProfileScreen>
    with SingleTickerProviderStateMixin {
  UserTabView? _currentUser;
  String? searchedUserName;
  CustomerProfile? searchedUser;
  bool? isOwner;
  bool appBarStatus = true;
  ScrollController? scrollController;

  TabController? _tabController;
  PageController? _pageController;
  int _currentIndex = 0;
  final PageStorageBucket _bucket = new PageStorageBucket();

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
          label: "Moment",
          child: momentTab(searchedUser!),
          apiCall: () async => await fetchMomentData(searchedUserName),
        ),
        UserTab(
          label: "Post",
          child: postTab(searchedUser!),
          apiCall: () async => await fetchPostData(searchedUserName),
        ),
        UserTab(
          label: "Channels",
          child: channelTab(searchedUserName),
          apiCall: () async => await fetchChannelData(searchedUserName),
        ),
      ],
    );

    // Set the current user here
    _currentUser = userView;

    _tabController = TabController(
      length: _currentUser!.tabs.where((tab) => tab.apiCall != null).length,
      vsync: this,
    );

    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);

    _pageController = PageController(initialPage: _currentIndex);

    // Add a listener to the tab controller that updates the current index
    _tabController!.addListener(tabController);

    if (mounted) setState(() {});

    super.initState();
  }

  void _scrollListener() {
    if (isShrink != appBarStatus) {
      appBarStatus = isShrink;
      if (mounted) setState(() {});
    }
  }

  void tabController() {
    _currentIndex = _tabController!.index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController!.hasClients) {
        _pageController!.animateToPage(_currentIndex,
            duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
      }
    });
    if (mounted) setState(() {});
  }

  bool get isShrink {
    return (scrollController?.hasClients ?? false) &&
        (scrollController?.offset ?? 0) > (150 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
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
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(),
                onTap: (int index) {
                  changeIndex(index);
                },
                tabs: getTabsWidget(),
              ),
            ),
          ),
        ];
      },
      body: getTabViewLayout(),
    );
  }

  List<Widget> getTabsWidget() {
    return getTabs();
  }

  void changeIndex(int index) {
    _currentIndex = index;

    if (mounted) setState(() {});
  }

  Widget getTabUI({String title = "", @required int? tabIndex}) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _tabController?.index == tabIndex ? 16 : 18,
            vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: _tabController?.index == tabIndex ? navyBlue : Colors.white,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color:
                _tabController?.index == tabIndex ? white : HexColor("#78797A"),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  getTabViewLayout() {
    return TabBarView(
      controller: _tabController,
      children:
          _currentUser!.tabs.where((tab) => tab.apiCall != null).map((tab) {
        return PageStorage(
          key: PageStorageKey(tab.label),
          bucket: _bucket,
          child: FutureBuilder(
            future: tab.apiCall!(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return tab.child!;
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      }).toList(),
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
          // searchedUser = null;
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

  Future<void> dispose() async {
    super.dispose();
    scrollController!.dispose();
    _tabController!.dispose();
    _pageController!.dispose();

    scrollController!.removeListener(_scrollListener);
    _tabController!.removeListener(_scrollListener);
    _pageController!.removeListener(_scrollListener);
  }
}
