import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/debouncer_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../widget/customized_dropdown_field.dart';
import '../../../../widget/no_item_in_list.dart';
import '../tiles/jos_description_card.dart';

class JobsDashboard extends StatefulWidget {
  const JobsDashboard({Key? key}) : super(key: key);

  @override
  State<JobsDashboard> createState() => _JobsDashboardState();
}

class _JobsDashboardState extends State<JobsDashboard> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;
  final GlobalKey<ScaffoldMessengerState> _jobScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController _jobsScrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();
  late UserBloc userBloc;

  String selectedCategory = "";
  List<CategoryListData> categoriesList = [];

  List<ActiveListingData> activeListing = [];

  bool isCategoryLoading = false;
  bool isActiveListLoading = false;
  bool noJobsInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? todayDealPrevious = "";
  String? productPrevious = "";
  String? categoryNext = "";
  String? categoryPrevious = "";
  int? activeListingCount = 0;
  String? activeListingNext = "";
  String? activeListingPrevious = "";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List status = ['Active', 'Closed', 'Pending'];

  Map<String, bool> categoryCheckMark = {};
  String? search;

  bool isItemLoading = false;
  int? categoryCount = 0;
  final ScrollController _scrollController = new ScrollController();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController? searchItemTextController;
  GlobalKey searchItemTextFormField = GlobalKey();
  int bottomSheetSearchIndex = 0;
  bool noSearchedItem = false;

  List searchedCategoryList = [];
  StateSetter? bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;

  final _debouncer = Debouncer(milliseconds: 500);

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void getActiveJobListing({category}) async {
    if (!isActiveListLoading) {
      if (productNext != null && !isActiveListLoading) {
        isActiveListLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService().getActiveJobListing(
            activeListingNext, activeListingPrevious,
            category: category);

        if (result == null) {
          noJobsInList = true;

          isActiveListLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        activeListingCount = result.count;
        activeListingNext = result.next;
        activeListingPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isActiveListLoading = false;
            activeListing.addAll(tempList!);
          });
        }
      }
      if (activeListing.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInList = true;
          });
        }
      } else if (activeListingNext == null && activeListing.length > 6) {
        _jobScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  initState() {
    getActiveJobListing();
    _jobsScrollController.addListener(() {
      if (_jobsScrollController.position.pixels ==
              _jobsScrollController.position.maxScrollExtent &&
          _jobsScrollController.position.pixels != 0) {
        getActiveJobListing();
      }
    });

    searchItemTextController = TextEditingController();

    super.initState();
  }

  _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isCategoryLoading = false;
    categoriesList = [];
    activeListing = [];

    todayDealNext = "";
    todayDealPrevious = "";
    isTodayDealLoading = false;
    categoryNext = "";
    categoryPrevious = "";
    activeListingCount = 0;
    activeListingNext = "";
    activeListingPrevious = "";
    if (selectedCategory.isEmpty) {
      getActiveJobListing();
    } else {
      getActiveJobListing(category: selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return ScaffoldMessenger(
      key: _jobScaffoldMessengerKey,
      child: Scaffold(
        body: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            onRefresh: _onRefresh,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              color: lightGrey,
              child: SingleChildScrollView(
                controller: _jobsScrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getCategoryData(context),
                    const SizedBox(
                      height: 15,
                    ),
                    getJobsListData(),
                    isCategoryLoading || isActiveListLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: greyBorderColor,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisSpacing: 14,
                                mainAxisExtent: 180,
                                crossAxisSpacing: 15,
                                maxCrossAxisExtent: 200,
                              ),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                    Visibility(
                      visible: !isCategoryLoading &&
                          !isActiveListLoading &&
                          activeListing.isEmpty &&
                          categoriesList.isEmpty,
                      child: Center(
                        child: Column(
                          children: [
                            Lottie.asset('assets/lottie/no_moment_lottie.json'),
                            const SizedBox(height: 20),
                            const Text('No items at the moment'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getJobsListData() {
    if (activeListing.isEmpty) {
      return const SizedBox.shrink();
    }
    return activeListingNext == "" && isActiveListLoading && isCategoryLoading
        ? const SizedBox.shrink()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Jobs you might like",
                style: TextStyle(
                  color: Color(0xff030e36),
                  fontSize: 16,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                // controller: _jobsScrollController,
                itemCount: activeListing.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        userBloc.user.userName ==
                                activeListing[index].job!.owner
                            ? Navigator.pushNamed(
                                context, Routes.MY_JOB_DETAILS, arguments: {
                                'jobId': activeListing[index].job!.id,
                                'listingId': activeListing[index].id,
                                'job': activeListing[index].job
                              })
                            : Navigator.pushNamed(
                                context, Routes.JOBS_PREVIEW_DETAIL,
                                arguments: {
                                    'jobId': activeListing[index].job!.id,
                                    'listingId': activeListing[index].id,
                                    'job': activeListing[index].job
                                  });
                      },
                      child: JobDescriptionCard(
                        job: activeListing[index].job,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: '',
      titleColor: blackFont,
      fontWeight: FontWeight.bold,
      child: ListTile(
        dense: true,
        title: SizedBox(
          width: 300,
          child: Text(
            selectedCategory.isNotEmpty ? selectedCategory : "select category",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: selectedCategory.isNotEmpty
                    ? blackFont
                    : darkGrey.withOpacity(0.9),
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600),
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          clearSearchedListItems();
          showSearchProductAndServiceBottomSheet();
        },
      ),
    );
  }

  Widget getCategoryData(BuildContext context) {
    return isActiveListLoading
        ? const SizedBox.shrink()
        : Column(
            children: [
              browseCategoryRow(),
              const SizedBox(
                height: 10,
              ),
              getCategoryField(),
              const SizedBox(
                height: 15,
              ),
            ],
          );
  }

  Widget categoryCard(String? imageUrl, String? title) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // color: Color(0x7f000000),
        image: DecorationImage(
          image: NetworkImage(imageUrl!),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), BlendMode.srcOver),
          fit: BoxFit.cover,
        ),
      ),
      child: Text(
        title!,
        style: TextStyle(
          color: white,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Row browseCategoryRow() {
    return Row(
      children: [
        Text(
          "Browse Category",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        SvgPicture.asset("assets/images/thunder.svg")
      ],
    );
  }

  GestureDetector getViewMoreBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.CATEGORIES_LIST);
      },
      child: Row(
        children: [
          Text(
            "view more",
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: navyBlue,
            size: 12,
          ),
        ],
      ),
    );
  }

  void showSearchProductAndServiceBottomSheet() async {
    var result = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, StateSetter bottomSheetStateSetter) {
            bottomSheetStateSetterGlobal = bottomSheetStateSetter;
            bottomSheetMounted = true;

            searchItemTextController!.addListener(() {
              if (searchItemTextController!.text.length >= 2) {
                _debouncer.run(() {
                  onRefresh();
                });
              } else if (searchItemTextController!.text.isEmpty) {
                _debouncer.run(() {
                  onRefresh();
                });
              }
            });

            return Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: searchBox()),
                      SizedBox(height: 8),
                      Expanded(child: bottomSheetTabBar())
                    ],
                  ),
                ));
          });
        });
    bottomSheetMounted = false;
    if (result == null) {}
  }

  Widget searchBox() {
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData().copyWith(selectionHandleColor: navyBlue),
        ),
        child: TextFormField(
          key: searchItemTextFormField,
          controller: searchItemTextController,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintText: 'Search Category',
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            suffixIcon: searchIcon(),
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
          onFieldSubmitted: (val) {
            if (mounted) setState(() {});
            FocusScope.of(context).unfocus();
            onRefresh();
          },
        ),
      ),
    );
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        searchCategory();
      },
    );
  }

  void searchCategory() {
    clearSearchedListItems();
    getCategorySearchedList();
  }

  void clearSearchedListItems() {
    searchedCategoryList.clear();
    searchItemTextController!.clear();
    categoryCount = 0;
    categoryNext = "";
    categoryPrevious = "";
    if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
      // bottomSheetStateSetterGlobal!(() {});
    }
    if (mounted) setState(() {});
  }

  void getCategorySearchedList() async {
    if (!isItemLoading) {
      if (categoryNext != null && !isItemLoading) {
        isItemLoading = true;

        if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ServiceHubAuthService()
            .getSearchCategoryList(
                categoryNext, categoryPrevious, searchItemTextController!.text);
        if (result == null) {
          isItemLoading = false;
          return;
        }
        categoryCount = result['count'];
        categoryNext = result['next'];
        categoryPrevious = result['previous'];
        List tempList = result['results'];

        isItemLoading = false;
        searchedCategoryList.clear();

        if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        if (mounted) setState(() {});

        tempList.forEach((item) {
          searchedCategoryList.add(CategoryListData.fromJson(item));
        });
      }
      if (searchedCategoryList.isEmpty) {
        noSearchedItem = true;
      } else {
        noSearchedItem = false;
      }
      if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
        bottomSheetStateSetterGlobal!(() {});
      }
      if (mounted) setState(() {});
    }
  }

  Widget bottomSheetTabBar() {
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Expanded(child: bottomSheetTabViews())
      ],
    );
  }

  // Widget bottomSheetTabBars() {
  //   return PreferredSize(
  //       preferredSize: Size.fromHeight(50.0),
  //       child: Row(
  //         children: [
  //           GestureDetector(
  //             onTap: () {
  //               bottomSheetSearchIndex = 0;
  //               clearSearchedListItems();
  //               bottomSheetStateSetterGlobal!(() {});
  //               setState(() {});
  //               searchCategory();
  //             },
  //             child: Container(
  //               padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 shape: BoxShape.rectangle,
  //                 color: bottomSheetSearchIndex == 0
  //                     ? navyBlue.withOpacity(0.1)
  //                     : Colors.white,
  //               ),
  //               child: Text(
  //                 "From partner",
  //                 style: TextStyle(
  //                   color: bottomSheetSearchIndex == 0 ? navyBlue : blackFont,
  //                   fontSize: 14,
  //                   fontFamily: "Inter",
  //                   fontWeight: bottomSheetSearchIndex == 0
  //                       ? FontWeight.w600
  //                       : FontWeight.w400,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           GestureDetector(
  //             onTap: () {
  //               bottomSheetSearchIndex = 1;
  //               clearSearchedListItems();
  //               bottomSheetStateSetterGlobal!(() {});
  //               setState(() {});
  //               searchCategory();
  //             },
  //             child: Container(
  //               padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 shape: BoxShape.rectangle,
  //                 color: bottomSheetSearchIndex == 1
  //                     ? navyBlue.withOpacity(0.1)
  //                     : Colors.white,
  //               ),
  //               child: Text(
  //                 "From Mine",
  //                 style: TextStyle(
  //                   color: bottomSheetSearchIndex == 1 ? navyBlue : blackFont,
  //                   fontSize: 14,
  //                   fontFamily: "Inter",
  //                   fontWeight: bottomSheetSearchIndex == 1
  //                       ? FontWeight.w600
  //                       : FontWeight.w400,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ));
  // }

  Widget bottomSheetTabViews() {
    return pullToRefresh();
  }

  void onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        categoryCount = 0;
        categoryNext = "";
        categoryPrevious = "";
        searchedCategoryList = [];
        isItemLoading = false;
        noSearchedItem = false;
        getCategorySearchedList();
        refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        refreshController.refreshCompleted();
      }
    });
  }

  Widget pullToRefresh() {
    return searchItemTextController!.text.isEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: refreshController,
            onRefresh: onRefresh,
            child: buildSearchCategoryList(),
          );
  }

  Widget buildSearchCategoryList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: searchedCategoryList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == searchedCategoryList.length) {
                return _buildIndicatorForSearchCategory();
              } else {
                return GestureDetector(
                    onTap: () {
                      // get selected category
                      CategoryListData picked = searchedCategoryList[index];
                      selectedCategory = picked.name!;

                      //refresh the active job listing with selected category
                      // _refreshPage();
                      if (mounted) setState(() {});
                      Navigator.pop(context);

                      FocusScope.of(context).requestFocus();
                    },
                    child: getResultTile(searchedCategoryList[index]));
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicatorForSearchCategory() {
    return Center(
      child: isItemLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            )
          : Container(),
    );
  }

  Widget getResultTile(var result) {
    if (result is CategoryListData) {
      return categoryViewCard(result);
    }
    return Container();
  }

  Widget categoryViewCard(CategoryListData category) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  title: Text(
                    category.name!,
                    maxLines: 1,
                    style: TextStyle(
                      color: blackFont,
                      fontSize: 12,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
