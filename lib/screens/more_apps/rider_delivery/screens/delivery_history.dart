import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
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
      GlobalKey<ScaffoldMessengerState>();
  final ScrollController _historyScrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int? listCount = 0;
  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  List<DeliveryModel> jobListing = [];
  bool noJobsInList = false;

  final GlobalKey _key = LabeledGlobalKey("deliveryHistoryPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  DateTimeRange? newDateTimeRange;

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

        final Map<String, dynamic>? result = await RiderDeliveryAuthService()
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
        final tempList = result['results'];
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
        _historyScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "All", value: "all"),
        CustomizedPopUpMenuItem(title: "Received", value: "received"),
        CustomizedPopUpMenuItem(title: "Sent", value: "sent"),
        CustomizedPopUpMenuItem(title: "Clear All", value: 'clear_all'),
        CustomizedPopUpMenuItem(title: "Clear Date", value: 'clear_date'),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
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
      actions: [
        dateFilterIcon(),
        const SizedBox(width: 10.0),
        popUpMenuButton(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget dateFilterIcon() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.date_range_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            newDateTimeRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime.parse("2020-01-01"),
              lastDate: DateTime.now(),
              builder: customThemeBuilder,
            );

            if (newDateTimeRange != null) {
              setState(() {});
              // _onRefresh();
            }
          },
        ),
      ),
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
      return const YarnShimmer();
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
                        if (jobListing[index].deliveryEvidence != null) {
                          Navigator.of(context).pushNamed(
                              Routes.VIEW_COMPLETED_DELIVERY,
                              arguments: {
                                'journeyId': jobListing[index].id,
                                'isCallAPI': true,
                              });
                        } else {
                          Navigator.of(context)
                              .pushNamed(Routes.RIDER_JOB_DETAILS, arguments: {
                            // 'showDetails': true,
                            'journeyId': jobListing[index].id
                          }).whenComplete(() => _onRefresh());
                        }
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
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0, top: 12.0),
                                  child: _buildDateAndWaitingButton(index),
                                ),
                                DeliveryOrderTile(
                                  jobListing: jobListing[index],
                                  earning: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
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
    final String date =
        DateFormat("dd MMMM,yyyy").format(jobListing[index].createdAt!);
    return Text(
      date,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: darkGrey,
        fontSize: 12,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildWaitingButton(int index) {
    final Color color = getStatusColor(index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Color getStatusColor(int index) {
    switch (jobListing[index].status) {
      case 'Awaiting Pickup':
        return starYellow;
      case 'Pending':
        return darkGrey;
      case 'Ongoing':
        return navyBlue;
      case 'Completed':
        return naturalGreen;
      case 'Delivered':
        return naturalGreen;
      case 'Canceled':
        return mateRed;
      default:
        return navyBlue;
    }
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      listNext = "";
      listPrevious = "";
      listCount = 0;
      isLoading = false;
      jobListing = [];
      getRiderJobListing();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.filter_alt_rounded,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            // if (menu.isMenuOpen) {
            //   menu.closeMenu();
            // } else {
            //   menu.openMenu();
            // }
          },
        ),
      ),
    );
  }

  void menuItemSelectionChange(String value, int index) {
    if (index == 4) {
      newDateTimeRange = null;
    } else {
      selectedMenuItemIndex = index;
    }

    switch (value) {
      case "received":
        // moneyIn = true;
        break;
      case "sent":
        // moneyIn = false;
        break;

      case "clear_date":
        // moneyIn =
        //     moneyIn; // To maintain the 'filter value' when you clear the date.
        break;

      case "clear_all":
        // moneyIn = null;
        // userName = null;
        newDateTimeRange = null;

        selectedMenuItemIndex = 0;

        break;

      default:
        // moneyIn = null;
        break;
    }

    setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }
}
