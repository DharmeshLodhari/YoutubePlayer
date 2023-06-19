import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../tiles/jos_description_card.dart';

class JobsDashboard extends StatefulWidget {
  const JobsDashboard({Key? key}) : super(key: key);

  @override
  State<JobsDashboard> createState() => _JobsDashboardState();
}

class _JobsDashboardState extends State<JobsDashboard> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;
  // GlobalKey _jobScaffoldMessengerKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _jobScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController _jobsScrollController = ScrollController();
  late UserBloc userBloc;

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
  // late ListOfCategories categoriesList;

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

  void getCategoriesList() async {
    if (!isCategoryLoading) {
      if (productNext != null && !isCategoryLoading) {
        isCategoryLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService()
            .getListOfCategories(categoryNext, categoryPrevious);

        if (result == null) {
          noJobsInList = true;

          isCategoryLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        productCount = result.count;
        productNext = result.next;
        productPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isCategoryLoading = false;
            categoriesList.addAll(tempList!);
          });
        }
      }
      if (categoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInList = true;
          });
        }
      } else if (productNext == null && categoriesList.length > 6) {
        // _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
      }
    }
  }

  void getActiveJobListing() async {
    if (!isActiveListLoading) {
      if (productNext != null && !isActiveListLoading) {
        isActiveListLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService()
            .getActiveJobListing(activeListingNext, activeListingPrevious);

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
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  initState() {
    super.initState();
    print("initState Called");
    getActiveJobListing();
    getCategoriesList();
    _jobsScrollController.addListener(() {
      if (_jobsScrollController.position.pixels ==
              _jobsScrollController.position.maxScrollExtent &&
          _jobsScrollController.position.pixels != 0) {
        getActiveJobListing();
      }
    });
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
    getActiveJobListing();
    getCategoriesList();
    //todaysDealList = [];

    // getProductList();
    //getTodaysDealProducts();
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
                    SizedBox(
                      height: 15,
                    ),
                    getJobsListData(),
                    isCategoryLoading || isActiveListLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: greyBorderColor,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
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
                        : SizedBox.shrink(),
                    Visibility(
                      visible: !isCategoryLoading &&
                          !isActiveListLoading &&
                          activeListing.isEmpty &&
                          categoriesList.isEmpty,
                      child: Center(
                        child: Column(
                          children: [
                            Lottie.asset('assets/lottie/no_moment_lottie.json'),
                            SizedBox(height: 20),
                            Text('No items at the moment'),
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
      return SizedBox.shrink();
    }
    return activeListingNext == "" && isActiveListLoading && isCategoryLoading
        ? SizedBox.shrink()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jobs you might like",
                style: TextStyle(
                  color: Color(0xff030e36),
                  fontSize: 16,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  // controller: _jobsScrollController,
                  itemCount: activeListing.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                                  'listingId': activeListing[index].id
                                })
                              : Navigator.pushNamed(
                                  context, Routes.JOBS_PREVIEW_DETAIL,
                                  arguments: {
                                      'jobId': activeListing[index].job!.id,
                                      'listingId': activeListing[index].id
                                    });
                        },
                        child: JobDescriptionCard(
                          job: activeListing[index].job,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
  }

  Widget getCategoryData(BuildContext context) {
    if (categoriesList.isEmpty) {
      return SizedBox.shrink();
    }
    return categoryNext == "" && isCategoryLoading && isActiveListLoading
        ? SizedBox.shrink()
        : Column(
            children: [
              browseCategoryRow(),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    itemCount: categoriesList.length,
                    scrollDirection: Axis.horizontal,
                    // shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, Routes.CATEGORY_JOBS,
                              arguments: categoriesList[index].slug),
                          child: categoryCard(categoriesList[index].image,
                              categoriesList[index].name),
                        ),
                      );
                    }),
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
          fontFamily: "Open Sans",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Row browseCategoryRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Browse Category",
            style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        getViewMoreBtn()
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
              fontFamily: "Open Sans",
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
}
