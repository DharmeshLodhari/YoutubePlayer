import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import 'tiles/order_tile.dart';

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List orderList = [];

  UserBloc userBloc;

  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  // variables for to getting filter orderList
  String filterValue = "";

  @protected
  void initState() {
    this.getList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getList();
      }
    });
    slidableController = SlidableController(
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
        count = 0;
        next = "";
        previous = "";
        orderList = [];
        noItemInList = false;
        getList();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          key: _scaffoldPaymentListKey,
          backgroundColor: lightBlue(),
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: darkBlue(),
            title: Text(AppLocalization.of(context).orders),
            actions: <Widget>[
              _threeItemPopup(),
            ],
          ),
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: darkBlue(),
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildOrderList()),
        ));
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: EdgeInsets.all(0),
        captureInheritedThemes: true,
        itemBuilder: (context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppLocalization.of(context).filter),
                  Icon(
                    Icons.sort,
                    color: Colors.black,
                  )
                ],
              ),
              value: 1,
            ),
          );
          list.add(
            PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).all,
                style: TextStyle(color: Colors.black),
              ),
              value: "",
              checked: filterValue == "" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).newOrder,
                style: TextStyle(color: Colors.green[600]),
              ),
              value: "new order",
              checked: filterValue == "new order" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).awaitingPayment,
                style: TextStyle(color: Colors.black),
              ),
              value: "awaiting payment",
              checked: filterValue == "awaiting payment" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).canceled,
                style: TextStyle(color: Colors.black),
              ),
              value: "canceled",
              checked: filterValue == "canceled" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).completed,
                style: TextStyle(color: Colors.black),
              ),
              value: "completed",
              checked: filterValue == "completed" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).onHold,
                style: TextStyle(color: Colors.black),
              ),
              value: "on hold",
              checked: filterValue == "on hold" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).pending,
                style: TextStyle(color: Colors.black),
              ),
              value: "pending",
              checked: filterValue == "pending" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).processing,
                style: TextStyle(color: Colors.black),
              ),
              value: "processing",
              checked: filterValue == "processing" ? true : false,
            ),
          );
          return list;
        },
        onSelected: (Object object) {
          setState(() {
            if (object != 1) {
              filterValue = object;
              filterValue = object;
              _onRefresh();
            }
          });
        },
      );

  Widget _buildOrderList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noOrdersPresent,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: orderList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == orderList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(context, orderList[index], index);
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
            opacity: isLoading ? 1.0 : 00,
            child: isLoading
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  )
                : Container()),
      ),
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
        var result = await _auth.listOrders(next, previous, filterValue);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            orderList.addAll(tempList);
          });
        }
      }
      if (orderList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && orderList.length > 6) {
        _scaffoldPaymentListKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          getList();
        });
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
              Navigator.of(context).pushNamed('/request-payment',
                  arguments: <String, bool>{
                    'isRequest': true,
                    'isFromProfile': true
                  });
            } else {
              Toast.show(
                  AppLocalization.of(context).internetConnectionNotAvailable,
                  context,
                  gravity: Toast.BOTTOM,
                  backgroundColor: darkBlue());
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  List<Widget> listSecondaryActions(Order order, int index) {
    return [];
  }

  List<Widget> listActionSlideActions(Order order, int index) {
    return [
      IconSlideAction(
        caption: AppLocalization.of(context).message,
        color: Colors.green,
        icon: Icons.message,
        onTap: () {
          var recipient = userBloc.user.userName == order.merchant
              ? order.customer
              : order.merchant;

          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': recipient,
            'subject': AppLocalization.of(context).orderDetail +
                " : " +
                AppLocalization.of(context).ref +
                " #${order.id}",
          });
        },
      ),
    ];
  }

  Widget _getSlidableWithLists(BuildContext context, Order order, int index) {
    return Slidable(
      key: Key(order.customer),
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(order),
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
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.order);
  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/order-detail-page",
            arguments: {"order": order});
      },
      child: Container(
        color: lightBlue(),
        child: OrderTile(order: order),
      ),
    );
  }
}
