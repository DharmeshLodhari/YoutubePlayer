import 'dart:async';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';

import '../business_auth.dart';

class ContractTransactionHistory extends StatefulWidget {
  @override
  _ContractTransactionHistoryState createState() =>
      _ContractTransactionHistoryState();
}

class _ContractTransactionHistoryState
    extends State<ContractTransactionHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  int? count = 0;
  String? next = "";
  String? previous = "";
  List transactionList = [];
  ScrollController _scrollController = new ScrollController();
  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    super.initState();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result = await BusinessAuth()
            .getContractTransactions(next, previous, false, false);
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            transactionList.addAll(tempList);
          });
        }
      }
      if (transactionList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && transactionList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  // void _onRefresh() async {
  //   //check network connectivity and if true then refresh the list
  //   Connectivity().checkConnectivity().then((value) {
  //     var connectionResult = value;
  //     if (connectionResult == ConnectivityResult.wifi ||
  //         connectionResult == ConnectivityResult.mobile) {
  //       count = 0;
  //       next = "";
  //       previous = "";
  //       transactionList = [];
  //       noItemInList = false;
  //       getList();
  //       _refreshController.refreshCompleted();
  //     } else {
  //       Toast.show(
  //           AppLocalization.of(context).internetConnectionNotAvailable, context,
  //           gravity: Toast.BOTTOM, backgroundColor: darkBlue());
  //       _refreshController.refreshCompleted();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: scaffoldBody(),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        "Contract transaction history",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return _buildTransactionList();
  }

  Widget _buildTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.transactionHistoryEmpty,
          )
        : isLoading && transactionList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4),
                //+1 for progressbar
                itemCount: transactionList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == transactionList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return ContractTransactionTile(
                      transaction: transactionList[index],
                    );
                  }
                },
                controller: _scrollController,
              );
  }
}
