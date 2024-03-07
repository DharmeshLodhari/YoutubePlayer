import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FindJobsTab extends StatefulWidget {
  FindJobsTab({
    Key? key,
    this.onPageRefresh,
  }) : super(key: key);

  Function(bool)? onPageRefresh;

  @override
  State<FindJobsTab> createState() => FindJobsTabState();
}

class FindJobsTabState extends State<FindJobsTab> {
  final GlobalKey<ScaffoldMessengerState> _findJobScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController _findJobScrollController = new ScrollController();
  int? listCount = 0;
  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  List<DeliveryModel> jobListing = [];
  bool noJobsInList = false;

  @override
  void initState() {
    super.initState();
    getRiderJobListing();
    _findJobScrollController.addListener(() {
      if (_findJobScrollController.position.pixels ==
              _findJobScrollController.position.maxScrollExtent &&
          _findJobScrollController.position.pixels != 0) {
        getRiderJobListing();
      }
    });
  }

  @override
  void dispose() {
    _findJobScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void getRiderJobListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await RiderDeliveryAuthService()
            .getJobListing(listNext, listPrevious);

        if (result == null) {
          noJobsInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        listCount = result['count'];
        listNext = result['next'];
        listPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isLoading = false;
            jobListing.addAll(tempList!);
          });
        }
      }
      if (jobListing.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInList = true;
          });
        }
      } else if (listNext == null && jobListing.length > 6) {
        _findJobScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _findJobScaffoldMessengerKey,
      child: SafeArea(
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
            child: _buildJobList(),
          ),
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
    jobListing = [];
    getRiderJobListing();
  }

  Widget _buildReviewIndicator() {
    return new Opacity(
      opacity: isLoading ? 1.0 : 00,
      child: isLoading ? YarnShimmer() : Container(),
    );
  }

  Widget _buildJobList() {
    if (!noJobsInList) {
      return SingleChildScrollView(
        controller: _findJobScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                itemCount: jobListing.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == jobListing.length) {
                    return _buildReviewIndicator();
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.RIDER_JOB_DETAILS,
                          arguments: {
                            'showDetails': true,
                            'deliveryDetail': jobListing[index]
                          });
                    },
                    child: DeliveryOrderTile(jobListing: jobListing[index]),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
    );
  }
}
