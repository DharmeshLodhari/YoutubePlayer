import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  final GlobalKey<ScaffoldMessengerState> _historyScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  ScrollController _historyScrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int? listCount = 0;
  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  List<DeliveryModel> jobListing = [];
  bool noJobsInList = false;

  @override
  void initState() {
    getRiderJobListing();
    _historyScrollController.addListener(() {
      if (_historyScrollController.position.pixels ==
              _historyScrollController.position.maxScrollExtent &&
          _historyScrollController.position.pixels != 0) {
        getRiderJobListing();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void getRiderJobListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await RiderDeliveryAuthService()
            .getRiderHistory(listNext, listPrevious);

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
        _historyScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: lightGrey,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      title: Text(
        'Delivery History',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: _buildHistoryList(),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    } else {
      if (!noJobsInList) {
        return SingleChildScrollView(
          controller: _historyScrollController,
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
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10.0, right: 10.0, top: 12.0),
                                  child: _buildDateAndWaitingButton(index),
                                ),
                                DeliveryOrderTile(
                                    jobListing: jobListing[index]),
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

  Widget _buildDateAndWaitingButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildDate(index)),
        _buildWaitingButton(index),
      ],
    );
  }

  Widget _buildDate(int index) {
    String date =
        DateFormat("dd MMMM,yyyy").format(jobListing[index].createdAt!);
    return Text(
      date,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: darkGrey,
        fontSize: 12,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildWaitingButton(int index) {
    Color color = getStatusColor(index);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        jobListing[index].status ?? "",
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  getStatusColor(int index) {
    switch (jobListing[index].status) {
      case 'Awaiting Pickup':
        return starYellow;
      case 'Pending':
        return darkGrey;
      case 'Ongoing':
        return navyBlue;
      case 'Completed':
        return naturalGreen;
      case 'Canceled':
        return mateRed;
      default:
        return navyBlue;
    }
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
}
