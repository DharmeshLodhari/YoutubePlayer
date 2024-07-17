import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/payout.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/payout_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../payment_and_banking_auth.dart';

class PayoutTransactions extends StatefulWidget {
  const PayoutTransactions({super.key});

  @override
  State<PayoutTransactions> createState() => _PayoutTransactionsState();
}

class _PayoutTransactionsState extends State<PayoutTransactions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Get list of users transactions
  int? count = 0;
  String? next = "";
  String? previous = "";
  List<Payout> payoutList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

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

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      count = 0;
      next = "";
      previous = "";
      payoutList = [];
      if (mounted) {
        getList();
      }
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildPayoutTransactionList()),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        "Cashout transactions",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPayoutTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.payoutHistoryEmpty,
          )
        : isLoading && payoutList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                //+1 for progressbar
                itemCount: payoutList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == payoutList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        children: [
                          PayoutTile(
                            payout: payoutList[index],
                            key: Key(
                                "Payout:${payoutList[index].uuid! + payoutList[index].timeStamp!}"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                controller: _scrollController,
              );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? result =
            await PaymentAndBankingAuth().getPayoutList(next, previous);

        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            payoutList.addAll(tempList);
          });
        }
      }
      if (payoutList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && payoutList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void dispose() {
    // unsecureScreen();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
