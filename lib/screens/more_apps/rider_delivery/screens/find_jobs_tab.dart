import 'package:Slydo/data/state_notifiers/rider_delivery_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  bool isRejectAPILoading = false;
  bool isAcceptAPILoading = false;
  bool isStartAPILoading = false;
  bool isEndedAPILoading = false;
  late UserBloc userBloc;
  late RiderDeliveryBloc riderDeliveryBloc;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getRiderJobListing();
      _findJobScrollController.addListener(() {
        if (_findJobScrollController.position.pixels ==
                _findJobScrollController.position.maxScrollExtent &&
            _findJobScrollController.position.pixels != 0) {
          getRiderJobListing();
        }
      });
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
    userBloc = Provider.of<UserBloc>(context);
    riderDeliveryBloc = Provider.of<RiderDeliveryBloc>(context);
    return ScaffoldMessenger(
      key: _findJobScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
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
              child: _buildJobList(),
            ),
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
        listNext = "";
        listPrevious = "";
        listCount = 0;
        isLoading = false;
        jobListing = [];
        getRiderJobListing();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  Widget _buildJobList() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    } else {
      if (!noJobsInList) {
        return SingleChildScrollView(
          controller: _findJobScrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Delivery Request around you',
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  itemCount: jobListing.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(Routes.RIDER_JOB_DETAILS, arguments: {
                          // 'showDetails': true,
                          'journeyId': jobListing[index].id
                        }).whenComplete(() => _onRefresh());
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: greyBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                DeliveryOrderTile(
                                    jobListing: jobListing[index]),
                                _buildJobAction(index),
                                SizedBox(height: 10.0),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
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

  Widget _buildJobAction(int index) {
    if (jobListing[index].isOfferAccepted(userBloc.user.userName) == false) {
      return _buildAcceptRejectButton(jobListing[index]);
    } else if (jobListing[index].isOfferAccepted(userBloc.user.userName) ==
            true &&
        jobListing[index].isInProgress == false &&
        jobListing[index].hasEnded == false) {
      return _buildStartDeliveryButton(jobListing[index]);
    } else if (jobListing[index].isOfferAccepted(userBloc.user.userName) ==
            true &&
        jobListing[index].isInProgress == true) {
      return _buildEndDeliveryButton(jobListing[index]);
    } else {
      return Container();
    }
  }

  Widget _buildAcceptRejectButton(DeliveryModel jobListing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: isRejectAPILoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      isRejectAPILoading = true;
                      if (mounted) setState(() {});
                      rejectJob(jobListing);
                      showToast(
                          message: AppLocalization.of(context)!
                              .jobRemovedFromListing);

                      isRejectAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: redBtn,
              textColor: white,
              text: 'Reject',
              fontSize: 15,
              isLoading: isRejectAPILoading,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: CurvedButton(
              onPressed: isAcceptAPILoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAcceptAPILoading = true;
                      if (mounted) setState(() {});
                      await acceptJob(jobListing);

                      isAcceptAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: white,
              text: 'Accept(4:49)',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDeliveryButton(DeliveryModel jobListing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.0),
      child: CurvedButton(
        text: 'Start Delivery',
        backgroundColor: navyBlue,
        textColor: white,
        onPressed: () {
          if (isStartAPILoading == false) {
            FocusScope.of(context).unfocus();
            isStartAPILoading = true;
            if (mounted) setState(() {});
            startOffer(jobListing);
            isStartAPILoading = false;
            if (mounted) setState(() {});
          }
        },
        isLoading: isStartAPILoading,
      ),
    );
  }

  Widget _buildEndDeliveryButton(DeliveryModel jobListing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.0),
      child: CurvedButton(
        text: 'End Delivery',
        backgroundColor: navyBlue,
        textColor: white,
        onPressed: isEndedAPILoading
            ? null
            : () async {
                FocusScope.of(context).unfocus();
                isEndedAPILoading = true;
                if (mounted) setState(() {});
                endOffer(jobListing);

                isEndedAPILoading = false;
                if (mounted) setState(() {});
              },
        isLoading: isEndedAPILoading,
      ),
    );
  }

  Future<void> rejectJob(DeliveryModel jobListing) async {
    await RiderDeliveryAuthService().rejectOffer(jobListing.id).then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
        _onRefresh();
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> acceptJob(DeliveryModel jobListing) async {
    await RiderDeliveryAuthService().acceptOffer(jobListing.id).then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobAcceptedFromListing);
        // jobListing.isShowDetails = false;
        // jobListing.isDeliveryAccepted = true;
        _onRefresh();
        setState(() {});
      } else {
        showToast(message: 'Offer already accepted by a dispatcher');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> startOffer(DeliveryModel jobListing) async {
    await RiderDeliveryAuthService().startJourney(jobListing.id).then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.journyStartedSuccessfully);
        // jobListing.isDeliveryAccepted = false;
        // jobListing.isDeliveryStarted = true;
        _onRefresh();
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> endOffer(DeliveryModel jobListing) async {
    await RiderDeliveryAuthService().endJourney(jobListing.id).then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.endJob);
        // jobListing.isDeliveryStarted = false;
        // jobListing.isDeliveryEnded = true;
        Navigator.of(context).pushNamed(Routes.RIDER_JOB_DETAILS, arguments: {
          'showDetails': true,
          'deliveryDetail': jobListing
        }).whenComplete(() => _onRefresh());
        setState(() {});
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }
}
