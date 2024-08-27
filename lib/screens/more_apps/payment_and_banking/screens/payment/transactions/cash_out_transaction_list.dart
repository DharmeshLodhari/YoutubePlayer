import 'package:Slydo/constant.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/payout.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/payout_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../payment_and_banking_auth.dart';

class CashOutTransactionsList extends StatefulWidget {
  const CashOutTransactionsList({super.key});

  @override
  State<CashOutTransactionsList> createState() =>
      _CashOutTransactionsListState();
}

class _CashOutTransactionsListState extends State<CashOutTransactionsList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late UserBloc userBloc;
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
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: lightGrey,
          body: SafeArea(
            child: SmartRefresher(
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
            : SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  //+1 for progressbar
                  itemCount: payoutList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == payoutList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      // return PayoutTile(
                      //   payout: payoutList[index],
                      //   key: Key(
                      //       "Payout:${payoutList[index].uuid! + payoutList[index].timeStamp!}"),
                      // );
                      return _getSlidableWithLists(
                          context, payoutList[index], index);
                    }
                  },
                  controller: _scrollController,
                ),
              );
  }

  Widget _getSlidableWithLists(BuildContext context, Payout payout, int index) {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    return Slidable(
      key: Key(payout.bankName!),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: hasPermission == PermissionType.WRITE ? 0.25 : 0.0001,
        children: listSecondaryActions(payout),
      ),
      child: PayoutTile(
        payout: payoutList[index],
        key: Key(
            "Payout:${payoutList[index].uuid! + payoutList[index].timeStamp!}"),
      ),
    );
  }

  List<Widget> listSecondaryActions(Payout payout) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: naturalGreen,
        icon: Icons.send,
        onPressed: (con) async {
          await Navigator.of(context).pushNamed(
            Routes.SEND_PAYMENT,
            arguments: <String, dynamic>{
              'isFromCashOut': true,
              'payout': payout,
            },
          );
        },
        label: AppLocalization.of(context)!.resend,
      ),
    ];
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
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
