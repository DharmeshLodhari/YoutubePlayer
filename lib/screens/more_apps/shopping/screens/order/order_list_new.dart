import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_tile_new.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OrderListNew extends StatefulWidget {
  const OrderListNew({super.key});

  @override
  State<OrderListNew> createState() => _OrderListNewState();
}

class _OrderListNewState extends State<OrderListNew> {
  late UserBloc userBloc;
  final GlobalKey<ScaffoldState> _scaffoldOrderListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerOrderListKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final _auth = ShoppingAuthService();
  bool isLoading = false;
  bool noItemInList = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  String filterValue = "";
  DateTimeRange? newDateTimeRange;
  List<ProductCategory> customCategories = [];
  dynamic selectedCategory;
  bool isMerchant = true;
  List<Order> orderList = [];
  bool isFirstTime = true;

  @override
  void initState() {
    customCategories = const [
      ProductCategory("All"),
      ProductCategory("Awaiting payment"),
      ProductCategory("Processing"),
      ProductCategory("Shipped"),
      ProductCategory("Delivered"),
      ProductCategory("Cancelled")
    ];
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
          filterValue,
          newDateTimeRange,
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
    userBloc = Provider.of<UserBloc>(context);

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: ScaffoldMessenger(
          key: _scaffoldMessengerOrderListKey,
          child: Scaffold(
            key: _scaffoldOrderListKey,
            backgroundColor: Colors.white,
            appBar: appBar() as PreferredSizeWidget?,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                orderTabView(),
                const SizedBox(height: 20),
                getDateRangeText(),
                Expanded(child: _buildOrderList()),
              ],
            ),
          ),
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
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: SlidableAutoCloseBehavior(
                  closeWhenOpened: true,
                  child: ListView.builder(
                    //+1 for progressbar
                    itemCount: orderList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == orderList.length) {
                        return buildJumpingLoadingIndicator(
                            isLoading: isLoading);
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, Routes.ORDER_DETAIL_PAGE,
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
                ),
              );
  }

  Widget getDateRangeText() {
    return newDateTimeRange != null
        ? Container(
            color: greyBorderColor.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${dateFormat.format(newDateTimeRange!.start)} - ${dateFormat.format(newDateTimeRange!.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
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
      title: Row(
        children: [
          Text(
            AppLocalization.of(context)!.orders,
            style: TextStyle(
                color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: <Widget>[
        dateFilterIcon(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget dateFilterIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: const Icon(
        Icons.date_range_rounded,
        color: Colors.black,
        size: 20,
      ),
      onTap: () async {
        // newDateTimeRange = await showDateRangePicker(
        //   context: context,
        //   firstDate: DateTime.parse("2020-01-01"),
        //   lastDate: DateTime.now(),
        //   builder: customThemeBuilder,
        // );
        //
        // if (newDateTimeRange != null) {
        //   setState(() {});
        //   _onRefresh();
        // }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: false,
    );
  }

  Widget orderTabView() {
    return Container(
      color: white,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 32,
            padding: const EdgeInsets.only(left: 12),
            margin: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerLeft,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...customCategories.map((e) => InkWell(
                      onTap: () {
                        setState(() {
                          selectedCategory = e.id;
                        });
                      },
                      child: Container(
                        decoration: selectedCategory == e.id
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: navyBlue,
                                    width:
                                        2.5, // This would be the width of the underline
                                  ),
                                ),
                              )
                            : BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: greySecondaryYarn.withOpacity(0.5),
                                    width:
                                        1, // This would be the width of the underline
                                  ),
                                ),
                              ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            e.name.toTitleCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Inter",
                              color: selectedCategory == e.id
                                  ? navyBlue
                                  : darkGrey,
                              fontWeight: selectedCategory == e.id
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          // Container(
          //   margin: EdgeInsets.only(left: 30),
          //   child: Divider(
          //     color: greySecondaryYarn,
          //   ),
          // ),
        ],
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
