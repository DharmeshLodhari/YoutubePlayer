import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/get_app_bar_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';

import '../utils.dart';

class BusinessProfileScreen extends StatefulWidget {
  CustomerProfile? searchedUser;
  String? searchedUserName;
  bool isOwner;
  bool isLoading;

  BusinessProfileScreen({
    Key? key,
    required this.searchedUser,
    required this.searchedUserName,
    required this.isOwner,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with TickerProviderStateMixin {
  late UserTabView _currentUser;
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
  Map<String, dynamic> result = {};
  Map<String, dynamic> productServiceLabel = {};
  List<String> orderingList = [];
  String productLabel = "";
  String serviceLabel = "";
  List<ProductCategory> customCategories = [];
  dynamic selectedCategory;

  String flashTagString = "";
  List<FlashTagAlertModel> flashTagAlerts = [];
  String? flashTagNext = "";
  String? flashTagPrevious = "";
  int? flashTagCount = 0;
  bool isFlashTagLoading = false;
  late SharedPreferences _sharedPreferences;
  FlashTagAlertModel? flashTagAlertModel;

  @override
  void initState() {
    searchedUserName = widget.searchedUserName!;

    if (widget.searchedUser != null) {
      searchedUser = widget.searchedUser!;
      result = searchedUser!.profileMenu!.toJson();
      orderingList = searchedUser!.profileMenu!.ordering!;
      productLabel = searchedUser!.profileMenu!.productLabel!;
      serviceLabel = searchedUser!.profileMenu!.serviceLabel!;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _sharedPreferences = await SharedPreferences.getInstance();
    });

    getAlertTagData();

    isOwner = widget.isOwner;

    // Initialize a map to store boolean values
    var boolMap = <String, bool>{};

    // Initialize a list to store the keys in the desired order
    var orderedKeys = <String>[];

    // Iterate through the 'ordering' array and add keys that exist in boolMap to orderedKeys
    if (result is Map<String, dynamic>) {
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
    var remainingKeys =
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

    // Define the UserTabView using the created userTabs list
    UserTabView businessView = UserTabView(
      name: "business",
      tabs: userTabs,
    );

    _currentUser = businessView;

    _tabController = TabController(
      length: _currentUser.tabs.where((tab) => tab.apiCall != null).length,
      vsync: this,
    );

    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);

    _pageController = PageController(initialPage: _currentIndex);

    // Add a listener to the tab controller that updates the current index
    _tabController!.addListener(tabController);

    Future.delayed(Duration(seconds: 1), () {
      obtainCustomCategory(widget.searchedUser!.userName!);
    });

    if (mounted) setState(() {});

    super.initState();
  }

  Future<void> getAlertTagData() async {
    print("============================>");
    if (flashTagNext != null && !isFlashTagLoading) {
      isFlashTagLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic>? result = await ShoppingAuthService()
          .listOfFlashTags(
              flashTagNext, flashTagPrevious, widget.searchedUser?.userName);

      if (result == null) {
        isFlashTagLoading = false;

        if (mounted) {
          setState(() {});
        }
        return;
      }

      flashTagCount = result['count'];
      flashTagNext = result['next'];
      flashTagPrevious = result['previous'];
      var tempList = result['results'];

      isFlashTagLoading = false;
      flashTagAlerts.addAll(tempList);
      if (flashTagNext != null) {
        await getAlertTagData();
        return;
      }
    }

    if (flashTagAlerts.isNotEmpty) {
      flashTagString = flashTagAlerts
          .where((element) =>
              element.type?.toValue() != FlashTagCategory("Pop-up").toValue())
          .map((e) => e.message)
          .toList()
          .join(".                         ");
      try {
        flashTagAlertModel = flashTagAlerts
            .where((element) =>
                element.type?.toValue() == FlashTagCategory("Pop-up").toValue())
            .toList()
            .first;
        bool check = _sharedPreferences.getBool("showFlash") ?? false;
        if (!check) {
          showFlashTagAlertPopUp();
          _sharedPreferences.setBool("showFlash", true);
        }
      } catch (error) {
        debugPrint("No Pop-up Element");
      }
      if (mounted) setState(() {});
    }
  }

  void showFlashTagAlertPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 0.0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.highlight_off_rounded,
                        size: 24,
                        color: darkGrey,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flashTagAlertModel?.title?.trim() ?? "Important Info",
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: "Inter"),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          flashTagAlertModel?.message?.trim() ?? "description",
                          style: TextStyle(
                              color: blackFont,
                              fontFamily: "Inter",
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.6),
                        ),
                        SizedBox(
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void obtainCustomCategory(user) async {
    try {
      List<ProductCategory> result =
          await ShoppingAuthService().obtainCustomCategory(user!);
      List<ProductCategory> initial = [];
      initial.add(ProductCategory("Explore", id: "main"));
      initial.add(ProductCategory("All", id: "all"));

      initial.addAll(result);
      customCategories = initial;
      selectedCategory = customCategories.first.id;
    } catch (e) {
      customCategories = [];
    }

    // isLoading = false;
    if (mounted) setState(() {});
  }

  void addTab(String key, String label) {
    switch (key) {
      case "product":
        userTabs.add(UserTab(
          label: productLabel,
          name: key,
          child: productTab(widget.searchedUser, isOwner!, false),
          apiCall: () async => await fetchProductData(searchedUserName, false),
        ));
        break;
      case "service":
        userTabs.add(UserTab(
          label: serviceLabel,
          name: key,
          child: serviceTab(widget.searchedUser, isOwner!),
          apiCall: () async => await fetchServiceData(searchedUserName),
        ));
        break;
      case "yarn":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: yarnTab(searchedUserName, ''),
          apiCall: () async => await fetchYarnData(searchedUserName, ''),
        ));
        break;

      case "moment":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: momentTab(widget.searchedUser, ''),
          apiCall: () async => await fetchMomentData(searchedUserName, ''),
        ));
        break;
      case "blog":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: postTab(widget.searchedUser, ''),
          apiCall: () async => await fetchPostData(searchedUserName, ''),
        ));
        break;
      case "channels":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: channelTab(searchedUserName),
          apiCall: () async => await fetchChannelData(searchedUserName),
        ));
        break;

      case "reviews":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: reviewTab(widget.searchedUser),
          apiCall: () async => ['1'],
        ));
        break;
      case "opening_hours":
        userTabs.add(UserTab(
          label: label,
          name: key,
          child: hoursTab(widget.searchedUser),
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
            searchedUser: widget.searchedUser,
            isLoading: widget.isLoading,
            isShrink: isShrink,
            scrollController: scrollController,
            callback: (val) {
              refreshTabs(val);
            },
            callbackProductService: (val) {
              productServiceTabReload(val);
            },
          ),
          SliverToBoxAdapter(
            child: _buildCrawlingAlert(),
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
      body: _getTabViewLayout(),
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
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget customCategoryWidget() {
    return Container(
      color: white,
      child: Column(
        children: [
          SizedBox(height: 15),
          Container(
            height: 20,
            margin: EdgeInsets.only(right: 24, left: 10),
            alignment: Alignment.centerLeft,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...customCategories
                    .map((e) => InkWell(
                          onTap: () {
                            setState(() {
                              selectedCategory = e.id;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                            ),
                            child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    3, // This can be the space you need between text and underline
                              ),
                              decoration: selectedCategory == e.id
                                  ? BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: navyBlue,
                                          width:
                                              2.0, // This would be the width of the underline
                                        ),
                                      ),
                                    )
                                  : BoxDecoration(),
                              child: Text(
                                e.name.toTitleCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Inter",
                                  color: selectedCategory == e.id
                                      ? navyBlue
                                      : darkGrey,
                                  fontWeight: selectedCategory == e.id
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList()
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Divider(
                color: greySecondaryYarn.withOpacity(.6),
              )),
        ],
      ),
    );
  }

  // getData() async {
  //   Map<String, dynamic>? data;
  //   try {
  //     data = await ShoppingAuthService().listOfProduct(
  //         selectedCategory == "main"
  //             ? "https://api.slydo.co/api/v1/products/seller-products-by-custom-category/${widget.searchedUser!.userName}/"
  //             : "https://api.slydo.co/api/v1/products/by-seller/${widget.searchedUser!.userName}/?custom_category=$selectedCategory",
  //         "",
  //         "",
  //         false,
  //         userName: searchedUserName);
  //   } catch (error) {}
  //   if (data != null) {
  //     debugPrint('IS SHOW PRODUCT ---> $data');
  //     List<dynamic> result = data["results"];
  //     if (result.isNotEmpty) return result;
  //   }
  //   return [];
  // }

  Widget _getTabViewLayout() {
    return Column(
      children: [
        if (customCategories.isNotEmpty &&
            _currentUser.tabs[_currentIndex].name == "product")
          customCategoryWidget(),
        Expanded(
          child: (customCategories.isNotEmpty &&
                  _currentUser.tabs[_currentIndex].name == "product" &&
                  selectedCategory != "all")
              ? PageStorage(
                  key: PageStorageKey(selectedCategory),
                  bucket: _bucket,
                  child: productTab(widget.searchedUser, isOwner!, false,
                      next: selectedCategory == "main"
                          ? "https://api.slydo.co/api/v1/products/seller-products-by-custom-category/${widget.searchedUser!.userName}/"
                          : "https://api.slydo.co/api/v1/products/by-seller/${widget.searchedUser!.userName}/?custom_category=$selectedCategory",
                      type: selectedCategory == "main" ? "section" : null),
                  // child: FutureBuilder(
                  //   future: getData(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.hasData) {
                  //       return productTab(widget.searchedUser, isOwner!, false,
                  //           next: selectedCategory == "main"
                  //               ? "https://api.slydo.co/api/v1/products/seller-products-by-custom-category/${widget.searchedUser!.userName}/"
                  //               : "https://api.slydo.co/api/v1/products/by-seller/${widget.searchedUser!.userName}/?custom_category=$selectedCategory",
                  //           type:
                  //               selectedCategory == "main" ? "section" : null);
                  //     } else {
                  //       return Center(child: CircularProgressIndicator());
                  //     }
                  //   },
                  // ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _currentUser.tabs
                      .where((tab) => tab.apiCall != null)
                      .map((tab) {
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
                ),
        ),
      ],
    );
  }

  List<Widget> getTabs() {
    List<Widget> tabs = [];
    int index = 0;

    _currentUser.tabs.where((tab) => tab.apiCall != null).map((tab) {
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
              name: searchedUser?.displayName()!,
              isVerified: searchedUser?.isVerified),
    );
  }

  Future<void> dispose() async {
    super.dispose();
    scrollController?.dispose();
    _tabController?.dispose();
    _pageController?.dispose();

    scrollController?.removeListener(_scrollListener);
    _tabController?.removeListener(_scrollListener);
    _pageController?.removeListener(_scrollListener);
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
        if (value) {
          // Add the tab
          addTab(key, capitalizeAndRemoveUnderscores(key));
        }
      });

      // Define the UserTabView using the created userTabs list
      UserTabView businessView = UserTabView(
        name: "business",
        tabs: userTabs,
      );

      _currentUser = businessView;

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
      _tabController?.animateTo(0);
    }
  }

  productServiceTabReload(Map<String, dynamic> val) {
    productLabel = val['product_label'].toString();
    serviceLabel = val['service_label'].toString();
    if (mounted) setState(() {});

    //reload tab view
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
    UserTabView businessView = UserTabView(
      name: "business",
      tabs: userTabs,
    );

    _currentUser = businessView;

    _tabController = TabController(
      length: _currentUser.tabs.where((tab) => tab.apiCall != null).length,
      vsync: this,
    );

    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);

    // Add a listener to the tab controller that updates the current index
    _tabController?.addListener(tabController);

    if (mounted) setState(() {});
    _tabController?.animateTo(0);
  }

  Widget _buildCrawlingAlert() {
    if (flashTagString != "") {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14),
        child: TextScroll(
          flashTagString.length <= 90
              ? "$flashTagString".padRight(90, " ")
              : flashTagString,
          style: TextStyle(color: white, fontWeight: FontWeight.w600),
          mode: TextScrollMode.endless,
        ),
      );
    }
    return SizedBox.shrink();
  }
}
