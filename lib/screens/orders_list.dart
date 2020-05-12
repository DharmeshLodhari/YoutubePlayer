//TODO: ADD APP LOCALIZATION
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForRequestPayment _refreshBloc;

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
            title: Text("Orders"),
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
              child: _buildorderList()),
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
                "New Order",
                style: TextStyle(color: Colors.green[600]),
              ),
              value: "new order",
              checked: filterValue == "new order" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Awaiting Payment",
                style: TextStyle(color: Colors.black),
              ),
              value: "awaiting payment",
              checked: filterValue == "awaiting payment" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Canceled",
                style: TextStyle(color: Colors.black),
              ),
              value: "canceled",
              checked: filterValue == "canceled" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Completed",
                style: TextStyle(color: Colors.black),
              ),
              value: "completed",
              checked: filterValue == "completed" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "On Hold",
                style: TextStyle(color: Colors.black),
              ),
              value: "on hold",
              checked: filterValue == "on hold" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Pending",
                style: TextStyle(color: Colors.black),
              ),
              value: "pending",
              checked: filterValue == "pending" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Processing",
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

  Widget _buildorderList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noPendingPaymentRequest,
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
                ? new CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : Container()),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        setState(() {
          isLoading = true;
        });
        var result = await _auth.listOrders(next, previous, filterValue);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        setState(() {
          isLoading = false;
          orderList.addAll(tempList);
        });
      }
      if (orderList.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && orderList.length > 6) {
        _scaffoldPaymentListKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      setState(() {
        isLoading = false;
        getList();
      });
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

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldPaymentListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(Order order, int index) {
    return [
      IconSlideAction(
          caption: "Cancel",
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () async {
//            rejectOrder(order, index);
          }),
    ];
  }

  List<Widget> listActionSlideActions(Order order, int index) {
    return [
      IconSlideAction(
        caption: "Message",
        color: Colors.green,
        icon: Icons.message,
        onTap: () {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': order.merchant,
            'subject': "Order: Ref #123488752627",
          });
//            acceptPaymentRequestAlert(paymentRequest, index);
        },
      ),
    ];
  }

  void acceptPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: AppLocalization.of(context).accept,
      description:
          AppLocalization.of(context).areYouSureWantToAcceptThisRequest,
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.acceptPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestAccepted);
        setState(() {
          orderList.removeAt(index);
          if (orderList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> rejectOrder(Order order, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: AppLocalization.of(context).reject,
      description:
          AppLocalization.of(context).areYouSureWantToRejectThisPayment,
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
//      bool done = await _auth.rejectPaymentRequests(order);
      var done = true;
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestRejected);
        setState(() {
          orderList.removeAt(index);
          if (orderList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
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
