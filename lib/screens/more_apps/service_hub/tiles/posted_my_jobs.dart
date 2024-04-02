import 'dart:developer';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class PostedMyJobs extends StatefulWidget {
  const PostedMyJobs({super.key});

  @override
  State<PostedMyJobs> createState() => _PostedMyJobsState();
}

class _PostedMyJobsState extends State<PostedMyJobs> {
  late UserBloc userBloc;

  bool isLoading = false;
  List<JobModel> postedMyJobListing = [];
  bool noJobsInPostedList = false;
  int? listCount = 0;
  String? listNext = "";
  String? listPrevious = "";

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _postedScrollController = ScrollController();
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

        log('message......${result.toJson()}');

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
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget getPostedJobsList() {
    if (postedMyJobListing.isEmpty) {
      return const SizedBox.shrink();
    }
    return listNext == "" && isLoading
        ? const SizedBox.shrink()
        : Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                itemCount: postedMyJobListing.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.MY_JOB_DETAILS,
                          arguments: {
                            'jobId': postedMyJobListing[index].id,
                            'listingId': '',
                            'job': postedMyJobListing[index]
                          }),
                      child: JobDescriptionCard(
                        job: postedMyJobListing[index],
                      ),
                    ),
                  );
                }),
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // args = ModalRoute.of(context)!.settings.arguments;
    userBloc = Provider.of<UserBloc>(context, listen: false);
    getPostedMyJobListing();
    _postedScrollController.addListener(() {
      if (_postedScrollController.position.pixels ==
              _postedScrollController.position.maxScrollExtent &&
          _postedScrollController.position.pixels != 0) {
        getPostedMyJobListing();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      onRefresh: _onRefresh,
      child: getPostedMyJobs(),
    );
  }

  Widget getPostedMyJobs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _postedScrollController,
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
              visible: !isLoading && postedMyJobListing.isEmpty,
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
    );
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
    listPrevious = "";
    listCount = 0;
    isLoading = false;
    postedMyJobListing = [];
    getPostedMyJobListing();
  }
}
