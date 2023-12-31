import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FindJobsTab extends StatefulWidget {
  FindJobsTab({
    Key? key,
    this.selectedCategory,
    this.onPageRefresh,
  }) : super(key: key);

  final String? selectedCategory;
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
  bool isRejectAPILoading = false;
  bool isAcceptAPILoading = false;
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
      // if (!isLoading) {
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
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: greyBorderColor,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLogoAndDeliveryAndAmount(index),
                                _buildItemsAndKg(index),
                                SizedBox(height: 10.0),
                                _buildIconAndAddressAndPickup(index),
                                SizedBox(height: 10.0),
                                _buildButtonCancelAndPickup(index),
                              ],
                            ),
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
      // }
      // return Padding(
      //   padding: EdgeInsets.all(10.0),
      //   child: CircularProgressIndicator(),
      // );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
    );
  }

  Widget _buildLogoAndDeliveryAndAmount(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLogo(index),
            _buildVerticalDivider(),
            _buildDelivery(index),
          ],
        ),
        Row(
          children: [
            _buildEst(),
            _buildAmount(index),
          ],
        )
      ],
    );
  }

  Widget _buildLogo(int index) {
    return Image.network(
      jobListing[index].merchantAvatar ?? "",
      height: 24,
      width: 24,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      cacheHeight: 24,
      cacheWidth: 24,
      frameBuilder: imageFrameBuilder,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      child: VerticalDivider(
        color: greySecondaryYarn,
        thickness: 1,
        indent: 10,
        endIndent: 10,
        width: 20,
      ),
    );
  }

  Widget _buildDelivery(int index) {
    return Text(
      jobListing[index].merchantFullName ?? "",
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildEst() {
    return Text(
      "Est ",
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildAmount(int index) {
    return Text(
      jobListing[index].currency ?? "",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildItemsAndKg(int index) {
    return Text(
      "${jobListing[index].totalNoOfItems} Items (${jobListing[index].totalWeight}Kg)",
      style: TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildIconAndAddressAndPickup(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconImage(),
        SizedBox(width: 7.0),
        Expanded(child: _buildMainAddressColumn(index))
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 65,
    );
  }

  Widget _buildMainAddressColumn(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${jobListing[index].pickupAddress?.addressLine1}, ${jobListing[index].pickupAddress?.addressLine2}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        Text(jobListing[index].expectedPickupTime.toString(),
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            )),
        SizedBox(height: 20),
        Text(
          '${jobListing[index].deliveryAddress?.addressLine1}, ${jobListing[index].deliveryAddress?.addressLine2}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              jobListing[index].expectedDeliveryTime.toString(),
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.keyboard_arrow_right_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonCancelAndPickup(int index) {
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
                      rejectJob(index);

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
                      await acceptJob(index);

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

  Future<void> rejectJob(int index) async {
    await RiderDeliveryAuthService()
        .rejectOffer(jobListing[index].id)
        .then((value) {
      showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> acceptJob(int index) async {
    await RiderDeliveryAuthService()
        .acceptOffer(jobListing[index].id)
        .then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobAcceptedFromListing);
        Navigator.of(context).pushNamed(Routes.RIDER_JOB_DETAILS, arguments: {
          'showDetails': false,
          'deliveryDetail': jobListing[index],
        });
      } else {
        showToast(message: 'Offer already accepted by a dispatcher');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }
}
