import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final GlobalKey<ScaffoldState> _scaffoldTransactionKey =
      new GlobalKey<ScaffoldState>();
  // Get list of users transactions
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List transactionList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForTransaction _refreshBloc;

  // variables for to getting filter transactions
  String filterValue = "all";
  bool moneyOut = false;
  bool moneyIn = false;

  CustomerProfileBloc customerProfileBloc;

  @override
  void initState() {
    getList();

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
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForTransaction>(context);
    _refreshBloc
      ..addListener(() {
        if (_refreshBloc.isRefresh) {
          if (mounted) {
            _onRefresh();
            _refreshBloc.isRefresh = false;
          }
        }
      });
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
        transactionList = [];
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
    // refresh the list when lifecycle called onResume method
    _onRefreshOnResume();

    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        key: _scaffoldTransactionKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Text(AppLocalization.of(context).transactions),
          actions: <Widget>[
            openGraph(),
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
            child: _buildTransactionList()),
      ),
    );
  }

  Widget _buildTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).transactionHistoryEmpty,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: transactionList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == transactionList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(
                    context, transactionList[index], index);
              }
            },
            controller: _scrollController,
          );
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
              value: "all",
              checked: filterValue == "all" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).received,
                style: TextStyle(color: Colors.black),
              ),
              value: "received",
              checked: filterValue == "received" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).sent,
                style: TextStyle(color: Colors.black),
              ),
              value: "sent",
              checked: filterValue == "sent" ? true : false,
            ),
          );
          return list;
        },
        onSelected: (Object object) {
          if (mounted) {
            setState(() {
              if (object != 1) {
                filterValue = object;
                switch (filterValue) {
                  case "received":
                    moneyIn = true;
                    moneyOut = false;
                    break;
                  case "sent":
                    moneyIn = false;
                    moneyOut = true;
                    break;
                  default:
                    moneyIn = false;
                    moneyOut = false;
                    break;
                }
                _onRefresh();
              }
            });
          }
        },
      );

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
          ),
        ),
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
        Map<String, dynamic> result =
            await _auth.getTransactions(next, previous, moneyIn, moneyOut);
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
        _scaffoldTransactionKey.currentState.showSnackBar(SnackBar(
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

  Widget openGraph() {
    return IconButton(
      icon: Icon(
        Icons.pie_chart,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed("/transaction-graph");
      },
    );
  }

  void handleSlideAnimationChanged(Animation<double> value) {}

  void handleSlideIsOpenChanged(bool value) {}

  List<Widget> listSecondaryActions(Transaction transaction) {
    String caption = AppLocalization.of(context).send;
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.green,
          icon: Icons.send,
          onTap: () async {
            customerProfileBloc.customer =
                await _auth.fetchCustomerProfile(transaction.payee);
            Navigator.of(context).pushNamed('/send-payment',
                arguments: <String, bool>{
                  'isFromProfile': false,
                  'isRequest': false
                });
          }),
    ];
  }

  List<Widget> listActionSlideActions(Transaction transaction) {
    return [
      IconSlideAction(
        caption: AppLocalization.of(context).request,
        color: Colors.green,
        icon: Icons.event_note,
        onTap: () async {
          customerProfileBloc.customer =
              await _auth.fetchCustomerProfile(transaction.payee);
          Navigator.of(context).pushNamed('/request-payment',
              arguments: <String, bool>{
                'isFromProfile': false,
                'isRequest': true
              });
        },
      ),
    ];
  }

  Widget _getSlidableWithLists(
      BuildContext context, Transaction transaction, int index) {
    return Slidable(
      key: Key(transaction.payee),
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(transaction),
      actions: listActionSlideActions(transaction),
      secondaryActions: listSecondaryActions(transaction),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.transaction);
  final Transaction transaction;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  bool isExpanded = false;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      onLongPress: () {
        if (mounted) {
          setState(() {
            if (isExpanded) {
              isExpanded = false;
            } else {
              isExpanded = true;
            }
          });
        }
      },
      child: Container(
        color: lightBlue(),
        child: TransactionTile(
          transaction: widget.transaction,
          expandedWidget: expandedWidget(),
        ),
      ),
    );
  }

  Widget expandedWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? 42 : 0,
      curve: Curves.fastOutSlowIn,
      child: isExpanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 0.5,
                  color: darkBlue(),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(child: sendMessageButton()),
                      Container(
                        width: 0.5,
                        color: darkBlue(),
                        height: 40,
                      ),
                      Expanded(child: blockUserButton()),
                    ],
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget sendMessageButton() {
    return MaterialButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.message,
            color: darkBlue(),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Message",
            style: TextStyle(color: darkBlue()),
          ),
        ],
      ),
      onPressed: () {
        _auth.fetchCustomerProfile(widget.transaction.payee).then((user) {
          if (mounted) {
            setState(() {
              isExpanded = false;
            });
          }
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': user.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget blockUserButton() {
    return MaterialButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Icon(
                Icons.group,
                color: Colors.black,
              ),
              Icon(
                Icons.block,
                color: Colors.red,
              )
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Block User",
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
      onPressed: () {
        _auth.fetchCustomerProfile(widget.transaction.payee).then((user) {
          _auth.blockUser(user).then((result) {
            if (mounted) {
              setState(() {
                isExpanded = false;
              });
            }
            if (result) {
              Toast.show("${widget.transaction.payee} is Blocked", context);
            } else {
              Toast.show("Error occurs", context);
            }
          });
        });
      },
    );
  }
}
