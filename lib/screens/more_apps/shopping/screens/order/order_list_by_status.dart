import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_order_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OrderListByStatus extends StatefulWidget {
  const OrderListByStatus({
    super.key,
    this.selectedStatus,
    this.dateRange,
  });

  final String? selectedStatus;
  final DateTimeRange? dateRange;

  @override
  State<OrderListByStatus> createState() => _OrderListByStatusState();
}

class _OrderListByStatusState extends State<OrderListByStatus> {
  final _auth = ShoppingAuthService();
  bool isLoading = false;
  bool noItemInList = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List<Order> orderList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldBlockListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerOrderListKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
    super.initState();
  }

  void getList() async {
    final bool isNormalUser =
        Provider.of<UserBloc>(context, listen: false).user.type == 'User';
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        final result = await _auth.listOrders(
          next,
          previous,
          widget.selectedStatus ?? "",
          widget.dateRange,
          isMerchant: isNormalUser ? false : true,
        );
        if (result == null) {
          if (mounted) {
            setState(() {
              noItemInList = true;
              isLoading = false;
            });
          }
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        noItemInList = false;
        isLoading = false;
        orderList.addAll(tempList);

        if (mounted) setState(() {});
      }
      if (orderList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && orderList.length > 6) {
        _scaffoldMessengerOrderListKey.currentState?.showSnackBar(SnackBar(
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
      key: _scaffoldMessengerOrderListKey,
      child: Scaffold(
        key: _scaffoldBlockListKey,
        backgroundColor: lightGrey,
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildOrderList(),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return noItemInList
        ? NoOrderInList(
            title: AppLocalization.of(context)!.noOrdersToShow,
            msg: 'Browse product to make your first order.',
          )
        : isLoading && orderList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                //+1 for progressbar
                itemCount: orderList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == orderList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(
                            context, Routes.ORDER_DETAIL_PAGE,
                            arguments: {"order": orderList[index]});
                      },
                      child: OrderTile(
                        order: orderList[index],
                        key: Key(
                          "Order:${orderList[index].id}",
                        ),
                      ),
                    );
                  }
                },
                controller: _scrollController,
              );
  }

  void _onRefresh() async {
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

  void _refresh() {
    count = 0;
    next = "";
    previous = "";
    orderList = [];
    noItemInList = false;
    getList();
  }
}
