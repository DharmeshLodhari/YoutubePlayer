import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RiderEarningWeeklyList extends StatefulWidget {
  const RiderEarningWeeklyList({super.key});

  @override
  State<RiderEarningWeeklyList> createState() => _RiderEarningWeeklyListState();
}

class _RiderEarningWeeklyListState extends State<RiderEarningWeeklyList> {
  DateTimeRange? newDateTimeRange;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
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
        getSearchBtn(),
        const SizedBox(width: 10.0),
        dateFilterIcon(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getSearchBtn() {
    return Card(
      color: iconBtnGrey,
      elevation: 0,
      margin: const EdgeInsets.only(left: 4, right: 5, bottom: 8, top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget dateFilterIcon() {
    return Card(
      color: iconBtnGrey,
      elevation: 0,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 8, top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.date_range_rounded,
          color: Colors.black,
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
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        //+1 for progressbar
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.EARNING_LIST);
                      },
                      child: ListTile(
                        dense: true,
                        leading: getLeading(),
                        title: getTitle(),
                        trailing: getTrailing(),
                        subtitle: getSubtitle(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        controller: _scrollController,
      ),
    );
  }

  Widget getLeading() {
    return GestureDetector(
      onTap: () {
        // Navigator.of(myGlobals.navigationKey.currentContext!)
        //     .pushNamed("/photo-viewer", arguments: paymentRequest!.avatar);
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25,
          ),
          // border: Border.all(color: borderColor, width: 2),
          border: Border.all(color: navyBlue, width: 1),
        ),
        child: ClipOval(
          // child: CachedNetworkImage(
          //   imageUrl: paymentRequest!.avatar!,
          //   height: 48,
          //   width: 48,
          //   errorWidget: imageErrorWidget,
          //   colorBlendMode: BlendMode.darken,
          //   fit: BoxFit.cover,
          //   filterQuality: FilterQuality.high,
          //   placeholder: (context, url) => paymentRequest!.avatar == ""
          //       ? const Icon(Icons.person)
          //       : CircularLoadingIndicator(),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/app_logo_navyBlue.png',
              height: 30,
              width: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        'Slydo',
        maxLines: 1,
        style: TextStyle(
          color: blackFont,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget getSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Weekly Dispatch Earn',
          style: TextStyle(
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
        ),
        const SizedBox(
          height: 2,
        ),
        getDateTime(),
      ],
    );
  }

  Widget getDateTime() {
    // final DateTime transactionTime =
    // DateTime.parse(transaction!.createdAt!).toLocal();
    // final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    // final String time = DateFormat("hh:mm a").format(transactionTime);
    return Text(
      '15/02/2024 - 22/08/2020',
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: darkGrey,
        fontSize: 10,
        fontFamily: "Inter",
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '₦',
          style: TextStyle(
              fontFamily: "Inter",
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          '42,000.00',
          style: TextStyle(
              color: navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  void _refresh() {
    // count = 0;
    // next = "";
    // previous = "";
    // transactionList = [];
    // noItemInList = false;
    // isFirstTime = true;
    // isLoading = false;
    // if (mounted) setState(() {});
    // getList();
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      _refresh();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
