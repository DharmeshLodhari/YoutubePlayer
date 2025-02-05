import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/user_profile/tiles/get_app_bar_tile.dart';
import 'package:Slydo/screens/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class ChannelProfileScreen extends StatefulWidget {
  final CustomerProfile? searchedUser;
  final String? searchedUserName;
  final Map<String, dynamic>? channelDetail;
  final bool isOwner;
  final bool isLoading;
  // Map<String, dynamic>? result = {};

  const ChannelProfileScreen({
    super.key,
    this.searchedUser,
    this.channelDetail,
    required this.searchedUserName,
    required this.isOwner,
    required this.isLoading,
    // required this.result,
  });

  @override
  State<ChannelProfileScreen> createState() => _ChannelProfileScreenState();
}

class _ChannelProfileScreenState extends State<ChannelProfileScreen>
    with TickerProviderStateMixin {
  late UserTabView _currentUser;
  String? channelUserName;
  late CustomerProfile channelOwner;
  bool? isOwner;
  bool appBarStatus = true;
  ScrollController? scrollController;

  TabController? _tabController;
  PageController? _pageController;
  int _currentIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();
  Map<String, dynamic>? channelDetail;
  // Define a list to store the UserTab objects
  List<UserTab> userTabs = [];
  Map<String, bool> reorderedBoolMap = {};
  Map<String, dynamic> result = {};
  List<dynamic> orderingList = [];

  @override
  void initState() {
    channelDetail = widget.channelDetail!;

    channelOwner = widget.searchedUser!;

    channelUserName = getGroupUsername(
        channelDetail!['username'] ?? channelDetail!['group_name']);

    channelUserName = channelUserName!.replaceAll(' ', '');

    isOwner = widget.isOwner;

    result = channelDetail!['owner']['profile_menu'];

    // Initialize a map to store boolean values
    final boolMap = <String, bool>{};

    // Initialize a list to store the keys in the desired order
    final orderedKeys = <String>[];

    // Iterate through the 'ordering' array and add keys that exist in boolMap to orderedKeys
    if (result.isNotEmpty) {
      orderingList = channelDetail!['owner']['profile_menu']['ordering'];
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
    final remainingKeys =
        boolMap.keys.where((key) => !orderedKeys.contains(key)).toList();

    // Add the remaining keys to orderedKeys to ensure they are at the end
    orderedKeys.addAll(remainingKeys);

    // Create a new map with the ordered keys
    reorderedBoolMap =
        Map.fromEntries(orderedKeys.map((key) => MapEntry(key, boolMap[key]!)));

    // Iterate through the JSON object and add tabs for boolean values that are true
    reorderedBoolMap.forEach((key, value) {
      if (value) {
        // Add the tab
        addTab(key, capitalizeAndRemoveUnderscores(key));
      }
    });

    addTab('event', capitalizeAndRemoveUnderscores('event'));

    // Define the UserTabView using the created userTabs list
    final UserTabView channelView = UserTabView(
      name: "channel",
      tabs: userTabs,
    );

    _currentUser = channelView;

    _tabController = TabController(
      length: _currentUser.tabs.where((tab) => tab.apiCall != null).length,
      vsync: this,
    );

    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);

    _pageController = PageController(initialPage: _currentIndex);

    // Add a listener to the tab controller that updates the current index
    _tabController!.addListener(tabController);

    // isLoading = false;
    if (mounted) setState(() {});

    super.initState();
  }

  void addTab(String key, String label) {
    switch (key) {
      case "product":
        userTabs.add(UserTab(
          label: 'Merchandise',
          child: productTab(channelOwner, isOwner!, true),
          apiCall: () async => await fetchProductData(channelUserName, true),
        ));
        break;

      case "yarn":
        userTabs.add(UserTab(
          label: label,
          child: yarnTab(channelUserName, 'channel'),
          apiCall: () async => await fetchYarnData(channelUserName, 'channel'),
        ));
        break;

      case "moment":
        userTabs.add(UserTab(
          label: label,
          child: momentTab(channelOwner, channelUserName!),
          apiCall: () async =>
              await fetchMomentData(channelUserName, channelUserName),
        ));
        break;
      case "blog":
        userTabs.add(UserTab(
          label: label,
          child: postTab(channelOwner, channelUserName!),
          apiCall: () async =>
              await fetchPostData(channelUserName, channelUserName),
        ));
        break;

      case "event":
        userTabs.add(UserTab(
          label: 'Event',
          child: eventTab(widget.searchedUser),
          apiCall: () async => ['1'],
        ));
        break;

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
            duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
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
    const String userType = 'channel';
    return NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
        return <Widget>[
          GetAppbarTile(
              searchedUser: channelOwner,
              isLoading: widget.isLoading,
              isShrink: isShrink,
              scrollController: scrollController,
              userType: userType,
              channelDetail: channelDetail),
          if (channelDetail!['is_member'] == true)
            SliverPersistentHeader(
              key: UniqueKey(),
              floating: true,
              pinned: true,
              delegate: SliverAppBarDelegate(
                TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                  controller: _tabController,
                  isScrollable: true,
                  indicator: const BoxDecoration(),
                  onTap: (int index) {
                    changeIndex(index);
                  },
                  tabs: getTabsWidget(),
                ),
              ),
            )
          else
            emptyView(),
        ];
      },
      body: channelDetail!['is_member'] == true
          ? getTabViewLayout()
          : Container(),
    );
  }

  Widget emptyView() {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width, // Full width of the screen
        height: MediaQuery.of(context).size.height, // Full height of the screen
        color: Colors.transparent,
        child: Column(
          children: [
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 50,
            ),
            Image.asset('assets/images/lock_channel.png'),
            const SizedBox(
              height: 20,
            ),
            Text(
              'This account is private',
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

  Widget getTabViewLayout() {
    return TabBarView(
      controller: _tabController,
      children:
          _currentUser.tabs.where((tab) => tab.apiCall != null).map((tab) {
        return PageStorage(
          key: PageStorageKey(tab.label),
          bucket: _bucket,
          child: FutureBuilder(
            future: tab.apiCall!(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return tab.child!;
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      }).toList(),
    );
  }

  List<Widget> getTabs() {
    final List<Widget> tabs = [];
    int index = 0;

    _currentUser.tabs.where((tab) => tab.apiCall != null).map((tab) {
      tabs.add(getTabUI(title: tab.label.toString(), tabIndex: index));
      index++;
    }).toList();

    return tabs;
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
          ? const SizedBox.shrink()
          : userNameWithVerifiedIcon(
              name: channelOwner.displayName()!,
              isVerified: channelOwner.isVerified),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    scrollController!.dispose();
    _tabController!.dispose();
    _pageController!.dispose();

    scrollController!.removeListener(_scrollListener);
    _tabController!.removeListener(_scrollListener);
    _pageController!.removeListener(_scrollListener);
  }

  void refreshTabs(Map<String, bool> val) {
    if (compareMaps(reorderedBoolMap, val)) {
      debugPrint('The maps are equal.');
    } else {
      debugPrint('The maps are not equal.');

      // Step 1: Clear the existing tabs
      userTabs.clear();
      // Iterate through the JSON object and add tabs for boolean values that are true
      val.forEach((key, value) {
        if (value) {
          // Add the tab
          addTab(key, capitalizeAndRemoveUnderscores(key));
        }
      });
      addTab('event', capitalizeAndRemoveUnderscores('event'));

      // Define the UserTabView using the created userTabs list
      final UserTabView channelView = UserTabView(
        name: "channel",
        tabs: userTabs,
      );

      _currentUser = channelView;

      _tabController = TabController(
        length: _currentUser.tabs.where((tab) => tab.apiCall != null).length,
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
