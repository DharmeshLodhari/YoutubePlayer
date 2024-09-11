import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/rider_delivery/tiles/delivery_order_tile.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RiderDashboard extends StatefulWidget {
  const RiderDashboard({super.key});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  DateTimeRange? newDateTimeRange;
  final GlobalKey _key = LabeledGlobalKey("deliveryHistoryPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  late UserBloc userBloc;

  int? listCount = 0;
  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  List<DeliveryModel> jobListing = [];
  bool noJobsInList = false;
  final ScrollController _historyScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _historyScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
    userBloc = Provider.of<UserBloc>(context);
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
      surfaceTintColor: Colors.transparent,
      backgroundColor: white,
      title: Text(
        'Earnings',
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

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.only(left: 0, right: 0, bottom: 8, top: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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

  Widget getSearchBtn() {
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
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            // CustomerProfile? userFound = await NavigationUtil.push(
            //   context,
            //   screen: const SearchUser(),
            // );
            //
            // if (userFound != null) {
            //   userName = userFound.userName;
            // }
          },
        ),
      ),
    );
  }

  Widget dateFilterIcon() {
    return Card(
      color: iconBtnGrey,
      elevation: 0,
      margin: const EdgeInsets.only(left: 4, right: 5, bottom: 8, top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            totalAmountEarned(),
            const SizedBox(
              height: 10,
            ),
            totalDistanceAndOrderCount(),
            const SizedBox(
              height: 20,
            ),
            deliveryHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget totalAmountEarned() {
    return CustomBoxShadow(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: greyBorderColor,
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            balanceRow(),
            viewTransaction(),
          ],
        ),
      ),
    );
  }

  Widget balanceRow() {
    return Container(
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildTotalAmountTitle(),
          const SizedBox(
            height: 20,
          ),
          _buildTotalAmount(),
          // const SizedBox(
          //   height: 5,
          // ),
          // _buildCompareLastWeek(),
        ],
      ),
    );
  }

  Widget _buildTotalAmountTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Amount Earned',
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        // CustomizedDropDownField(
        //   title: '',
        //   child: ListTile(
        //     dense: true,
        //     title: Text(
        //       "",
        //       maxLines: 1,
        //       style: TextStyle(
        //           color: blackFont,
        //           fontSize: 16,
        //           fontFamily: "Inter",
        //           fontWeight: FontWeight.w600),
        //     ),
        //     trailing: Icon(
        //       Icons.keyboard_arrow_down,
        //       color: darkGrey,
        //     ),
        //     onTap: () {
        //       // selectItemSubCategory(changeState);
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      children: [
        Text(
          worldCurrencies[userBloc.user.currency]!,
          style: TextStyle(
              color: black,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        Text(
          '0',
          style: TextStyle(
            color: navyBlue,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildCompareLastWeek() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "chart_down".toSVG(),
          height: 18,
          width: 18,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          '0%',
          style: TextStyle(
            color: navyBlue,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          'Compared to last week',
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget viewTransaction() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNextPayday(),
          const SizedBox(
            height: 5,
          ),
          _buildViewTransaction(),
        ],
      ),
    );
  }

  Widget _buildNextPayday() {
    return Text(
      '',
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  // todo: Tobe reopen latter
  // Widget _buildNextPayday() {
  //   return Text(
  //     'Next Payday : 22/12/24',
  //     style: TextStyle(
  //       color: blackFont,
  //       fontSize: 14,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: "Inter",
  //     ),
  //   );
  // }

  Widget _buildViewTransaction() {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed(Routes.RIDER_EARNING_WEEKLY_LIST);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'View Transaction',
            style: TextStyle(
              color: navyBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right_outlined,
            color: navyBlue,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget totalDistanceAndOrderCount() {
    return Row(
      children: [
        Expanded(
          child: customCard(lightGreen, '0.0KM', 'Total Distance Covered'),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: customCard(richPink, '0', 'Total Order Delivered'),
        ),
      ],
    );
  }

  Widget customCard(Color cardColor, String count, String title) {
    return CustomBoxShadow(
      child: Card(
        shadowColor: boxShadowTwo,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 120,
          decoration: decorateBox(color: cardColor),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  maxLines: 1,
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget deliveryHistoryList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delivery History',
              maxLines: 1,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pushNamed(Routes.DELIVERY_HISTORY);
              },
              child: Text(
                'See all',
                maxLines: 1,
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15.0),
        _buildDeliveryHistoryList(),
      ],
    );
  }

  Widget _buildDeliveryHistoryList() {
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
                  itemCount: 4,
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
                          Navigator.of(context).pushNamed(
                              Routes.RIDER_JOB_DETAILS,
                              arguments: {'journeyId': jobListing[index].id});
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
      case 'Canceled':
        return mateRed;
      default:
        return navyBlue;
    }
  }
}
