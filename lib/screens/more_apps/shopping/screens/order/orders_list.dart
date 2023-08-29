import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../routes/route_constants.dart';
import '../../shopping_auth.dart';
import '../../tiles/order_tile.dart';

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final GlobalKey<ScaffoldState> _scaffoldOrderListKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerOrderListKey =
      new GlobalKey<ScaffoldMessengerState>();
  final _auth = ShoppingAuthService();
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  List orderList = [];
  String? previous = "";
  bool isMerchant = true;
  late UserBloc userBloc;
  bool isFirstTime = true;

  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  // variables for to getting filter orderList
  String filterValue = "";
  DateTimeRange? newDateTimeRange;

  GlobalKey _key = LabeledGlobalKey("orderListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  // DateTimeRange dateTimeRange = DateTimeRange(start: DateTime.parse("2020-01-01"), end: DateTime.now(),
  // );

  @protected
  void initState() {
    this.getList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refresh();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    if (index == 8) {
      filterValue = value;
      newDateTimeRange = null;
    } else {
      selectedMenuItemIndex = index;
      filterValue = value;
    }

    switch (value) {
      case "clear_all":
        filterValue = '';
        newDateTimeRange = null;

        selectedMenuItemIndex = 0;

        break;
    }

    setState(() {});
    _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "All", value: ""),
        CustomizedPopUpMenuItem(title: "New order", value: "New Order"),
        CustomizedPopUpMenuItem(
            title: "Awaiting payment", value: "Awaiting Payment"),
        CustomizedPopUpMenuItem(title: "Canceled", value: "Canceled"),
        CustomizedPopUpMenuItem(title: "Completed", value: "Complete"),
        CustomizedPopUpMenuItem(title: "On hold", value: "On Hold"),
        CustomizedPopUpMenuItem(title: "Pending", value: "Pending"),
        CustomizedPopUpMenuItem(title: "Payment Received", value: "Payment Received"),
        CustomizedPopUpMenuItem(title: "Order Picked Up", value: "Order Picked Up"),
        CustomizedPopUpMenuItem(title: "Processing", value: "Processing"),
        CustomizedPopUpMenuItem(title: "Out For Delivery", value: "Out For Delivery"),
        CustomizedPopUpMenuItem(title: "Clear Date", value: filterValue),
        CustomizedPopUpMenuItem(title: "Clear All", value: 'clear_all'),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerOrderListKey,
        child: Scaffold(
          key: _scaffoldOrderListKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getDateRangeText(),
              Expanded(child: _buildOrderList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget getDateRangeText() {
    return newDateTimeRange != null
        ? Container(
            color: greyBorderColor.withOpacity(0.2),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${dateFormat.format(newDateTimeRange!.start)} - ${dateFormat.format(newDateTimeRange!.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
              ),
            ),
          )
        : SizedBox.shrink();
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
        getSwitchBtn(),
        SizedBox(width: 8),
        dateFilterIcon(),
        SizedBox(width: 8),
        popUpMenuButton(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget getSwitchBtn() {
    return userBloc.user.type != 'User'
        ? Switch(
            value: isMerchant,
            activeThumbImage: AssetImage('assets/images/incoming_arrow.png'),
            inactiveThumbImage: AssetImage('assets/images/outgoing_arrow.png'),
            activeColor: Colors.grey.withOpacity(0.9),
            onChanged: (value) {
              if (!isLoading) {
                // Only make a switch when the page is not loading(i.e, we should always wait for the page to complete loading before making another request)
                if (value == true) {
                  showSnackbar(context,
                      message: 'These are your incoming orders',
                      duration: 1000);
                } else {
                  showSnackbar(context,
                      message: 'These are your outgoing orders',
                      duration: 1000);
                }
                isMerchant = value;
                _refresh();
              }
            })
        : SizedBox.shrink();
  }

  Widget dateFilterIcon() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
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
              _onRefresh();
            }
          },
        ),
      ),
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
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
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noOrdersPresent,
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              //+1 for progressbar
              itemCount: orderList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == orderList.length) {
                  return _buildIndicator(isLoading: isLoading);
                } else {
                  return _getSlidableWithLists(
                      context, orderList[index], index);
                }
              },
              controller: _scrollController,
            ),
          );
  }

  Widget _buildIndicator({required bool isLoading}) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  void getList() async {
    bool isNormalUser =
        Provider.of<UserBloc>(context, listen: false).user.type == 'User';
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        var result = await _auth.listOrders(
          next,
          previous,
          filterValue,
          newDateTimeRange,
          isMerchant: isNormalUser ? false : isMerchant,
        );
        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        var tempList = result['results'];

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
        _scaffoldMessengerOrderListKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget sendRequestButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () {
          Connectivity().checkConnectivity().then((value) {
            var connectionResult = value;
            if (connectionResult == ConnectivityResult.wifi ||
                connectionResult == ConnectivityResult.mobile) {
              Navigator.of(context).pushNamed(Routes.REQUEST_PAYMENT,
                  arguments: <String, bool>{
                    'isRequest': true,
                    'isFromProfile': true
                  });
            } else {
              showToast(
                  message: AppLocalization.of(context)!
                      .internetConnectionNotAvailable);
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  List<Widget> listSecondaryActions(Order order, int index) {
    bool canPay = order.status == 'Awaiting Payment' &&
        userBloc.user.userName != order.merchant;

    return canPay
        ? [
            SlideActionButton(
                backgroundColor: navyBlue,
                icon: Icons.done,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (dialogLoadingContext) => LoadingIndicator());
                  var data = {
                    "orders": [order.id]
                  };
                  PaymentAndBankingAuth().makePaymentForCartOrder(data).then(
                    (response) {
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        showToast(message: 'Payment successful');
                        _refresh();
                      } else if (response.statusCode == 500) {
                        showToast(
                            message: AppLocalization.of(context)!.serverError);
                      } else {
                        showToast(
                            message: jsonDecode(response.body)[0]['errors']);
                      }
                    },
                  );
                },
                title: AppLocalization.of(context)!.pay,
                slideController: _slideController),
          ]
        : [];
  }

  List<Widget> listActionSlideActions(Order order, int index) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.text_message,
          onTap: () {
            var recipient = userBloc.user.userName == order.merchant
                ? order.customerName
                : order.merchant;

            Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
              'recipient': recipient,
              'subject': AppLocalization.of(context)!.orderDetail +
                  " : " +
                  AppLocalization.of(context)!.ref +
                  " #${order.id}",
            });
          },
          title: AppLocalization.of(context)!.message,
          slideController: _slideController),
    ];
  }

  Widget _getSlidableWithLists(BuildContext context, Order order, int index) {
    return Slidable(
      key: Key(order.customerName!),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(
        order,
        onPaymentSuccessfulFromDetailPage: () {
          _refresh();
        },
      ),
      actions: listActionSlideActions(order, index),
      secondaryActions: listSecondaryActions(order, index),
    );
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

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.order,
      {required this.onPaymentSuccessfulFromDetailPage});

  final Function onPaymentSuccessfulFromDetailPage;
  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var reloadPage = await Navigator.pushNamed(
            context, Routes.ORDER_DETAIL_PAGE,
            arguments: {"order": order});
        if (reloadPage != null && reloadPage == true) {
          onPaymentSuccessfulFromDetailPage();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: OrderTile(
          order: order,
          key: Key(
            "Order:${order.id}",
          ),
        ),
      ),
    );
  }
}
