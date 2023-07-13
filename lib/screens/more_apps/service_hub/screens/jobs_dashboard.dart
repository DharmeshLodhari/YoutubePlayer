import 'dart:developer';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/utils/util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../widget/curved_btn.dart';
import '../../../../widget/customized_dropdown_field.dart';
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
  ScrollController _categoryScrollController = ScrollController();
  late UserBloc userBloc;

  List<String>? selectedCategory = [];
  List<String>? displayCategory = [];
  List<CategoryListData> categoriesList = [];
  List<CategoryListData> categoriesListCopy = [];

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
            .getListOfCategories(productNext, productPrevious);

        isCategoryLoading = false;
        setState(() {});

        if (result == null) {
          noJobsInList = true;

          isCategoryLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        log('message result.........${result.toJson()}');

        productCount = result.count;
        productNext = result.next;
        productPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isCategoryLoading = false;
            categoriesList.addAll(tempList!);
            categoriesListCopy = categoriesList;
          });
        }


        categoriesListCopy.forEach((element) {
          categoryCheckMark[element.name!] = false;
        });
      }
      if (categoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInList = true;
            isCategoryLoading = false;
          });
        }
      } else if (productNext == null && categoriesList.length > 6) {
        _jobScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
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

  void callGetCategoriesListLoop() async {
    while (productNext != null && productNext!.isNotEmpty) {
        getCategoriesList();
    }
  }


  @override
  initState() {
    getActiveJobListing();
    getCategoriesList();
    _jobsScrollController.addListener(() {
      if (_jobsScrollController.position.pixels ==
              _jobsScrollController.position.maxScrollExtent &&
          _jobsScrollController.position.pixels != 0) {
        getActiveJobListing();
      }
    });

    _categoryScrollController.addListener(() {
      if (_categoryScrollController.position.pixels ==
              _categoryScrollController.position.maxScrollExtent &&
          _categoryScrollController.position.pixels != 0) {
        getCategoriesList();
      }
    });

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
    if (selectedCategory!.isEmpty) {
      getActiveJobListing();
    } else {
      getActiveJobListing(category: selectedCategory!.join(','));
    }
    getCategoriesList();

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
                  fontFamily: "Open Sans",
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
            displayCategory!.isNotEmpty
                ? displayCategory!.join(',')
                : "select category",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: darkGrey.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    categoriesList = categoriesListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: Stack(children: [
              ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(
                    height: 3.4,
                  ),
                  Text(
                    "Select Category",
                    style: TextStyle(
                        color: black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  Divider(
                    color: darkGrey.withOpacity(.5),
                  ),
                  SizedBox(
                    // height: 400,
                    height: MediaQuery.of(context).size.height * 0.58,
                    child: Expanded(
                      child: NotificationListener<ScrollEndNotification>(
                        onNotification: (scrollEnd) {
                          final metrics = scrollEnd.metrics;
                          if (metrics.atEdge) {
                            bool isTop = metrics.pixels == 0;
                            if (!isTop) {
                              changeState(() {});
                            }
                          }
                          return true;
                        },
                        child: ListView.builder(
                          controller: _categoryScrollController,
                          shrinkWrap: true,
                          itemCount: categoriesList.length,
                          itemBuilder: (context, index) {
                            CategoryListData category = categoriesList[index];
                            return CheckboxListTile(
                              value: displayCategory!.contains(category.name)
                                  ? true
                                  : false,
                              onChanged: (isChecked) {
                                changeState(() {
                                  categoryCheckMark[category.name!] =
                                      isChecked!;
                                });
                                if (selectedCategory!.contains(category.slug)) {
                                  selectedCategory!.remove(category.slug);
                                  displayCategory!.remove(category.name);
                                } else {
                                  selectedCategory!.add(category.slug!);
                                  displayCategory!.add(category.name!);
                                }
                              },
                              title: Text(
                                category.name!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: blackFont,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // isCategoryLoading || isLoading
                  //     ? SpinKitRing(
                  //         size: 30,
                  //         lineWidth: 3,
                  //         color: darkGreyYarn,
                  //       )
                  //     : const SizedBox.shrink(),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CurvedButton(
                  text: 'Pick',
                  onPressed: () {
                    Navigator.pop(context);
                    _onRefresh();
                  },
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget getCategoryData(BuildContext context) {
    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }
    return categoryNext == "" && isCategoryLoading && isActiveListLoading
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
          fontFamily: "Open Sans",
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
