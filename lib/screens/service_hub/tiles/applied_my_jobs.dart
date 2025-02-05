import 'dart:developer';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/service_hub/models/jobs.dart';
import 'package:Slydo/screens/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AppliedMyJobs extends StatefulWidget {
  const AppliedMyJobs({super.key});

  @override
  State<AppliedMyJobs> createState() => _AppliedMyJobsState();
}

class _AppliedMyJobsState extends State<AppliedMyJobs> {
  late UserBloc userBloc;

  List<JobModel> appliedMyJobListing = [];
  String? appliedListPrevious = "";
  bool isAppliedLoading = false;
  int? appliedListCount = 0;
  String? listNext = "";
  String? appliedListNext = "";
  String? listPrevious = "";
  bool noJobsInAppliedList = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _appliedScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _myJobsScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void getAppliedMyJobsListing() async {
    if (!isAppliedLoading) {
      if (appliedListNext != null && !isAppliedLoading) {
        isAppliedLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService().getMyJobListing(
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

        log('APPLIED JOBS...... ${result.toJson()}');

        appliedListCount = result.count;
        appliedListNext = result.next;
        appliedListPrevious = result.previous;
        final tempList = result.results;
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
            noJobsInAppliedList = true;
          });
        }
      } else if (appliedListNext == null && appliedMyJobListing.length > 6) {
        _myJobsScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
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
    userBloc = Provider.of<UserBloc>(context, listen: false);
    getAppliedMyJobsListing();
    _appliedScrollController.addListener(() {
      if (_appliedScrollController.position.pixels ==
              _appliedScrollController.position.maxScrollExtent &&
          _appliedScrollController.position.pixels != 0) {
        getAppliedMyJobsListing();
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: getAppliedJobList(),
      ),
    );
  }

  Widget getAppliedJobList() {
    if (appliedMyJobListing.isEmpty) {
      return const SizedBox.shrink();
    }
    return appliedListNext == "" && isAppliedLoading
        ? const SizedBox.shrink()
        : Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                itemCount: appliedMyJobListing.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.MY_JOB_DETAILS,
                          arguments: {
                            'jobId': appliedMyJobListing[index].id,
                            'listingId': '',
                            'job': appliedMyJobListing[index]
                          }),
                      child: JobDescriptionCard(
                        job: appliedMyJobListing[index],
                      ),
                    ),
                  );
                }),
          );
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refreshPage();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _refreshPage() {
    listNext = "";
    appliedListNext = "";
    listPrevious = "";
    appliedListPrevious = "";
    appliedListCount = 0;
    isAppliedLoading = false;
    appliedMyJobListing = [];
    getAppliedMyJobsListing();
  }
}
