import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class JobsCategoryJobsList extends StatefulWidget {
  final String categoryId;
  const JobsCategoryJobsList({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<JobsCategoryJobsList> createState() => _JobsCategoryJobsListState();
}

class _JobsCategoryJobsListState extends State<JobsCategoryJobsList> {
  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  bool noJobsInList = false;
  int? listCount = 0;
  List<ActiveListingData> activeListing = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _jobListScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _jobScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  void getActiveJobListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService().getActiveJobListing(
            listNext, listPrevious,
            category: widget.categoryId);

        if (result == null) {
          noJobsInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        listCount = result.count;
        listNext = result.next;
        listPrevious = result.previous;
        final tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isLoading = false;
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
      } else if (listNext == null && activeListing.length > 6) {
        _jobScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // args = ModalRoute.of(context)!.settings.arguments;
    getActiveJobListing();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
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
    listCount = 0;
    isLoading = false;
    activeListing = [];

    listPrevious = "";

    getActiveJobListing();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _jobScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                controller: _jobListScrollController,
                children: [
                  getJobsListData(),
                  const SizedBox(height: 16),
                  if (isLoading)
                    Shimmer.fromColors(
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
                  else
                    const SizedBox.shrink(),
                  Visibility(
                    visible: !isLoading && activeListing.isEmpty,
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
    );
  }

  Widget getJobsListData() {
    if (activeListing.isEmpty) {
      return const SizedBox.shrink();
    }
    return listNext == "" && isLoading
        ? const SizedBox.shrink()
        : ListView.builder(
            itemCount: activeListing.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, Routes.JOBS_PREVIEW_DETAIL, arguments: {
                    'jobId': activeListing[index].job!.id,
                    'listingId': activeListing[index].id
                  }),
                  child: JobDescriptionCard(
                    job: activeListing[index].job,
                  ),
                ),
              );
            },
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
        "Service Hub",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _filterBtn(),
        const SizedBox(
          width: 12,
        )
      ],
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
