import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/my_job_list_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class JobsMyJobsList extends StatefulWidget {
  const JobsMyJobsList({Key? key}) : super(key: key);

  @override
  State<JobsMyJobsList> createState() => _JobsMyJobsListState();
}

class _JobsMyJobsListState extends State<JobsMyJobsList> {
  bool isLoading = false;
  bool isAppliedLoading = false;
  String? listNext = "";
  String? appliedListNext = "";
  String? listPrevious = "";
  String? appliedListPrevious = "";
  bool noJobsInPostedList = false;
  bool noJobsInAppliedList = false;

  int? listCount = 0;
  int? appliedListCount = 0;
  int currentIndex = 0;
  late AppLocalization appLocalization;
  List<JobModel> postedMyJobListing = [];
  List<JobModel> appliedMyJobListing = [];
  late UserBloc userBloc;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _posetedScrollController = ScrollController();
  ScrollController _appliedScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _myJobsScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void getPostedMyJobListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService().getMyJobListing(
            listNext, listPrevious,
            myJobType: 'posted', userId: userBloc.user.userName);

        if (result == null) {
          noJobsInPostedList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        listCount = result.count;
        listNext = result.next;
        listPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInPostedList = false;
            isLoading = false;
            postedMyJobListing.addAll(tempList!);
          });
        }
      }
      if (postedMyJobListing.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInPostedList = true;
          });
        }
      } else if (listNext == null && postedMyJobListing.length > 6) {
        _myJobsScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getAppliedMyJobsListing() async {
    if (!isAppliedLoading) {
      if (appliedListNext != null && !isAppliedLoading) {
        isAppliedLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService().getMyJobListing(
            appliedListNext, appliedListPrevious,
            myJobType: 'applied', userId: userBloc.user.userName);

        if (result == null) {
          noJobsInAppliedList = true;

          isAppliedLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        appliedListCount = result.count;
        appliedListNext = result.next;
        appliedListPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInAppliedList = false;
            isAppliedLoading = false;
            appliedMyJobListing.addAll(tempList!);
          });
        }
      }
      if (appliedMyJobListing.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInPostedList = true;
          });
        }
      } else if (appliedListNext == null && appliedMyJobListing.length > 6) {
        _myJobsScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [getPostedMyJobs(), getAppliedMyJobs()],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // args = ModalRoute.of(context)!.settings.arguments;
    userBloc = Provider.of<UserBloc>(context, listen: false);
    getPostedMyJobListing();
    getAppliedMyJobsListing();
    _posetedScrollController.addListener(() {
      if (_posetedScrollController.position.pixels ==
              _posetedScrollController.position.maxScrollExtent &&
          _posetedScrollController.position.pixels != 0) {
        getPostedMyJobListing();
      }
    });
    _appliedScrollController.addListener(() {
      if (_appliedScrollController.position.pixels ==
              _appliedScrollController.position.maxScrollExtent &&
          _appliedScrollController.position.pixels != 0) {
        getAppliedMyJobsListing();
      }
    });
  }

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

  _refreshPage() {
    listNext = "";
    appliedListNext = "";
    listPrevious = "";
    appliedListPrevious = "";
    listCount = 0;
    appliedListCount = 0;
    currentIndex = 0;
    isLoading = false;
    isAppliedLoading = false;
    postedMyJobListing = [];
    appliedMyJobListing = [];
    getPostedMyJobListing();
    getAppliedMyJobsListing();
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context)!;
    return DefaultTabController(
      length: 2,
      child: ScaffoldMessenger(
        key: _myJobsScaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: appBar(),
          body: SmartRefresher(
            controller: _refreshController,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            onRefresh: _onRefresh,
            child:
                TabBarView(children: [getPostedMyJobs(), getAppliedMyJobs()]),
          ),
        ),
      ),
    );
  }

  Widget getPostedMyJobs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: SingleChildScrollView(
        controller: _posetedScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getPostedJobsList(),
            // !isLoading && myJobListing.isNotEmpty
            //     ?
            //     : SizedBox.shrink(),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
              visible: !isLoading && postedMyJobListing.isEmpty,
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
    );
  }

  Widget getPostedJobsList() {
    if (postedMyJobListing.isEmpty) {
      return SizedBox.shrink();
    }
    return listNext == "" && isLoading
        ? SizedBox.shrink()
        : Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                itemCount: postedMyJobListing.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print('${postedMyJobListing.length} my job length');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.MY_JOB_DETAILS, arguments: {
                        'jobId': postedMyJobListing[index].id,
                        'listingId': ''
                      }),
                      child: JobDescriptionCard(
                        // currency: postedMyJobListing[index].currency,
                        // creationDate:
                        //     postedMyJobListing[index].creationDate.toString(),
                        // description: postedMyJobListing[index].description,
                        // location: postedMyJobListing[index].location,
                        // price: postedMyJobListing[index].pay.toString(),
                        // status: postedMyJobListing[index].status,
                        // title: postedMyJobListing[index].title,
                        job: postedMyJobListing[index],
                      ),
                    ),
                  );
                }),
          );
  }

  Widget getAppliedMyJobs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: SingleChildScrollView(
        controller: _appliedScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getAppliedJobList(),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
              visible: !isLoading && appliedMyJobListing.isEmpty,
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
            // !isLoading && postedMyJobListing.isNotEmpty
            //     ? Flexible(
            //         fit: FlexFit.loose,
            //         child: ListView.builder(
            //             itemCount: postedMyJobListing.length,
            //             shrinkWrap: true,
            //             physics: NeverScrollableScrollPhysics(),
            //             itemBuilder: (context, index) {
            //               return Padding(
            //                 padding: const EdgeInsets.only(bottom: 10.0),
            //                 child: GestureDetector(
            //                   onTap: () => Navigator.pushNamed(
            //                       context, Routes.JOB_DETAILS),
            //                   child: JobDescriptionCard(
            //                     creationDate: postedMyJobListing[index]
            //                         .creationDate
            //                         .toString(),
            //                     description:
            //                         postedMyJobListing[index].description,
            //                     location: postedMyJobListing[index].location,
            //                     price: postedMyJobListing[index].pay.toString(),
            //                     status: postedMyJobListing[index].status,
            //                     title: postedMyJobListing[index].title,
            //                   ),
            //                 ),
            //               );
            //             }),
            //       )
            //     : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget getAppliedJobList() {
    print('${appliedMyJobListing.length} my applied job length');
    if (appliedMyJobListing.isEmpty) {
      return SizedBox.shrink();
    }
    return appliedListNext == "" && isLoading
        ? SizedBox.shrink()
        : Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                itemCount: appliedMyJobListing.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.MY_JOB_DETAILS, arguments: {
                        'jobId': appliedMyJobListing[index].id,
                        'listingId': ''
                      }),
                      child: JobDescriptionCard(
                        job: appliedMyJobListing[index],
                      ),
                    ),
                  );
                }),
          );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        "My Job",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      // actions: [
      //   _filterBtn(),
      //   SizedBox(
      //     width: 12,
      //   )
      // ],
      bottom: tabBar() as PreferredSizeWidget,
    );
  }

  Widget tabBar() {
    return PreferredSize(
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.posted,
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                appLocalization.applied,
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
      preferredSize: Size.fromHeight(50),
    );
  }

  Widget _filterBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.filter,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // Navigator.pushNamed(context, Routes.SEARCH_SERVICES);
      },
      backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }
}
