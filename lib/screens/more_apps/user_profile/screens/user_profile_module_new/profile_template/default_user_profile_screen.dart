import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/get_app_bar_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

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
    with TickerProviderStateMixin {
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
  // Define a list to store the UserTab objects
  List<UserTab> userTabs = [];
  Map<String, bool> reorderedBoolMap = {};
  List<String> orderingList = [];

  @override
  void initState() {
    searchedUserName = widget.searchedUserName!;
    searchedUser = widget.searchedUser!;
    isOwner = widget.isOwner;

    Map<String, dynamic>? result = searchedUser!.profileMenu!.toJson();

    // Initialize a map to store boolean values
    var boolMap = <String, bool>{};

    // Initialize a list to store the keys in the desired order
    var orderedKeys = <String>[];

    // Iterate through the 'ordering' array and add keys that exist in boolMap to orderedKeys
    if (result != null && result is Map<String, dynamic>) {
      orderingList = searchedUser!.profileMenu!.ordering!;
      // Iterate through the JSON object and filter boolean values
      result.forEach((key, value) {
        if (value is bool) {
          boolMap[key] = value;
        }
      });

      // Iterate through the JSON object and add tabs for boolean values that are true
      for (var key in orderingList) {
        if (boolMap.containsKey(key)) {
          orderedKeys.add(key);
        }
      }
    }


    // Create a list of keys not in 'ordering'
    var remainingKeys = boolMap.keys.where((key) => !orderedKeys.contains(key)).toList();

    // Add the remaining keys to orderedKeys to ensure they are at the end
    orderedKeys.addAll(remainingKeys);

    // Create a new map with the ordered keys
    reorderedBoolMap = Map.fromEntries(orderedKeys.map((key) => MapEntry(key, boolMap[key]!)));

    // Iterate through the JSON object and add tabs for boolean values that are true
    reorderedBoolMap.forEach((key, value) {
      if (value is bool && value) {
        // Add the tab
        addTab(key, capitalizeAndRemoveUnderscores(key));
      }
    });

    // Define the UserTabView using the created userTabs list
    UserTabView userView = UserTabView(
      name: "user",
      tabs: userTabs,
    );

    //Define the tabs and their corresponding data for each user
    // UserTabView userView = UserTabView(
    //   name: "user",
    //   tabs: [
    //     UserTab(
    //       label: "Yarn",
    //       child: yarnTab(searchedUserName),
    //       apiCall: () async => await fetchYarnData(searchedUserName),
    //     ),
    //     UserTab(
    //       label: "Moment",
    //       child: momentTab(searchedUser!),
    //       apiCall: () async => await fetchMomentData(searchedUserName),
    //     ),
    //     UserTab(
    //       label: "Post",
    //       child: postTab(searchedUser!),
    //       apiCall: () async => await fetchPostData(searchedUserName),
    //     ),
    //     UserTab(
    //       label: "Channels",
    //       child: channelTab(searchedUserName),
    //       apiCall: () async => await fetchChannelData(searchedUserName),
    //     ),
    //   ],
    // );

    //Set the current user here
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

  void addTab(String key, String label) {
    switch (key) {
      // case "product":
      //   userTabs.add(UserTab(
      //     label: label,
      //     child: productTab(widget.searchedUser, isOwner!),
      //     apiCall: () async => await fetchProductData(searchedUserName),
      //   ));
      //   break;
      // case "service":
      //   userTabs.add(UserTab(
      //     label: label,
      //     child: serviceTab(widget.searchedUser, isOwner!),
      //     apiCall: () async => await fetchServiceData(searchedUserName),
      //   ));
      //   break;
      case "yarn":
        userTabs.add(UserTab(
          label: label,
          child: yarnTab(searchedUserName),
          apiCall: () async => await fetchYarnData(searchedUserName, ''),
        ));
        break;

      case "moment":
        userTabs.add(UserTab(
          label: label,
          child: momentTab(widget.searchedUser),
          apiCall: () async => await fetchMomentData(searchedUserName, ''),
        ));
        break;
      case "blog":
        userTabs.add(UserTab(
          label: label,
          child: postTab(widget.searchedUser),
          apiCall: () async => await fetchPostData(searchedUserName, ''),
        ));
        break;
      case "channels":
        userTabs.add(UserTab(
          label: label,
          child: channelTab(searchedUserName),
          apiCall: () async => await fetchChannelData(searchedUserName),
        ));
        break;

      // case "reviews":
      //   userTabs.add(UserTab(
      //     label: label,
      //     child: reviewTab(widget.searchedUser),
      //     apiCall: () async => ['1'],
      //   ));
      //   break;
      // case "opening_hours":
      //   userTabs.add(UserTab(
      //     label: label,
      //     child: hoursTab(widget.searchedUser),
      //     apiCall: () async => ['1'],
      //   ));
      //   break;
      default:
        break;
    }
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
            callback: (val){
                refreshTabs(val);
            },
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

  Future<void> dispose() async {
    super.dispose();
    scrollController!.dispose();
    _tabController!.dispose();
    _pageController!.dispose();

    scrollController!.removeListener(_scrollListener);
    _tabController!.removeListener(_scrollListener);
    _pageController!.removeListener(_scrollListener);
  }

  refreshTabs(Map<String, bool> val) {

    if (compareMaps(reorderedBoolMap, val)) {
      debugPrint('The maps are equal.');
    } else {
      debugPrint('The maps are not equal.');

      // Step 1: Clear the existing tabs
      userTabs.clear();
      // Iterate through the JSON object and add tabs for boolean values that are true
      val.forEach((key, value) {
        if (value is bool && value) {
          // Add the tab
          addTab(key, capitalizeAndRemoveUnderscores(key));
        }
      });

      // Define the UserTabView using the created userTabs list
      UserTabView userView = UserTabView(
        name: "user",
        tabs: userTabs,
      );

      _currentUser = userView;

      _tabController = TabController(
        length: _currentUser!.tabs.where((tab) => tab.apiCall != null).length,
        vsync: this,
      );

      scrollController = ScrollController();
      scrollController?.addListener(_scrollListener);

      // Add a listener to the tab controller that updates the current index
      _tabController!.addListener(tabController);

      //clear map and reassign
      reorderedBoolMap = {};
      reorderedBoolMap = val;

      if (mounted) setState(() {});
      _tabController!.animateTo(0);

    }

  }
}
