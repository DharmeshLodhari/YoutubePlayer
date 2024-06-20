import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_tile_new.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  bool isFirstTime = true;
  final ScrollController _scrollController = ScrollController();
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
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        isLoading = false;
        orderList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (orderList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && orderList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
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
      child: Container(
        color: lightGrey,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SmartRefresher(
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
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noOrdersPresent,
          )
        : isLoading && orderList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  //+1 for progressbar
                  itemCount: orderList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == orderList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, Routes.ORDER_DETAIL_PAGE_NEW,
                              arguments: {"order": orderList[index]});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: OrderTileNew(
                            order: orderList[index],
                            key: Key(
                              "Order:${orderList[index].id}",
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  controller: _scrollController,
                ),
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
    isFirstTime = true;
    noItemInList = false;
    getList();
  }
}
