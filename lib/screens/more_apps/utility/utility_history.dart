import 'package:Slydo/screens/more_apps/utility/tiles/utility_history_tile.dart';
import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../../widget/noItemInList.dart';

class UtilityHistory extends StatefulWidget {
  @override
  _UtilityHistoryState createState() => _UtilityHistoryState();
}

class _UtilityHistoryState extends State<UtilityHistory> {
  int? count = 0;
  String? next = "";
  String? previous = "";

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  List<Map<String, dynamic>> utilityPayment = [
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Complete"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Pending"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Canceled"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Paused"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Complete"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Pending"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Canceled"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Paused"
    },
  ];

  bool isFirstTime = true;
  List utilityHistoryList = [];

  @override
  void initState() {
    // secureScreen();
    getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result =
            await UtilityAuth().getUtilityTransactions(next, previous);
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];

        isLoading = false;

        utilityHistoryList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (utilityHistoryList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && utilityHistoryList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        utilityHistoryList = [];
        noItemInList = false;
        isFirstTime = true;
        if (mounted) setState(() {});
        isLoading = false;
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: foregroundScreen(),
    );
  }

  Widget foregroundScreen() {
    return Container(
        padding: EdgeInsets.only(top: 16, bottom: 8),
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildUtilityPaymentHistoryList(),
        ));
  }

  Widget _buildUtilityPaymentHistoryList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.utilityHistoryEmpty,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: utilityHistoryList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == utilityHistoryList.length) {
                return _buildIndicator();
              } else {
                return UtilityHistoryTile(
                    utilityHistoryModel: utilityHistoryList[index]);
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "Utility History",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        // utilityHistoryBtn(),
        // SizedBox(
        //   width: 16,
        // )
      ],
    );
  }

  Widget utilityHistoryBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.utility_history,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // Navigator.of(context)
        //     .pushNamed('/scan-qr', arguments: {"isRequest": true});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }
}
