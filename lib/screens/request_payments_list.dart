import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class PaymentRequestList extends StatefulWidget {
  @override
  _PaymentRequestListState createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List requestPaymentList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForRequestPayment _refreshBloc;

  // variables for to getting filter requestPaymentList
  String filterValue = "all";
  bool fromMe = false;
  bool toMe = false;

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

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForRequestPayment>(context);
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
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        requestPaymentList = [];
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
    // refresh the list when lifecycle called onResume method\
    _onRefreshOnResume();

    return Scaffold(
      key: _scaffoldPaymentListKey,
      backgroundColor: lightBlue(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue(),
        title: Text(AppLocalization.of(context).paymentRequests),
        actions: <Widget>[
          sendRequestButton(),
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
          child: _buildRequestPaymentList()),
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
                filterValue = object;
                switch (filterValue) {
                  case "received":
                    toMe = true;
                    fromMe = false;
                    break;
                  case "sent":
                    toMe = false;
                    fromMe = true;
                    break;
                  default:
                    toMe = false;
                    fromMe = false;
                    break;
                }
                _onRefresh();
              }
            });
          }
        },
      );

  Widget _buildRequestPaymentList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noPendingPaymentRequest,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: requestPaymentList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == requestPaymentList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(
                    context, requestPaymentList[index], index);
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
        Map<String, dynamic> result =
            await _auth.listPaymentRequests(next, previous, toMe, fromMe);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            requestPaymentList.addAll(tempList);
          });
        }
      }
      if (requestPaymentList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && requestPaymentList.length > 6) {
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

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldPaymentListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    String caption = !paymentRequest.isCredit
        ? AppLocalization.of(context).cancel
        : AppLocalization.of(context).reject;
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () async {
            rejectPaymentRequestAlert(paymentRequest, index);
          }),
    ];
  }

  List<Widget> listActionSlideActions(
      PaymentRequest paymentRequest, int index) {
    if (!paymentRequest.isCredit) {
      return [];
    } else {
      return [
        IconSlideAction(
          caption: AppLocalization.of(context).sendMoney,
          color: Colors.green,
          icon: Icons.reply,
          onTap: () {
            acceptPaymentRequestAlert(paymentRequest, index);
          },
        ),
      ];
    }
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
      var response = await _auth.acceptPaymentRequests(paymentRequest);
      if (response.statusCode == 200) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestAccepted);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else if (response.statusCode == 500) {
        Toast.show(AppLocalization.of(context).serverError, context,
            gravity: Toast.TOP,
            backgroundColor: darkBlue(),
            textColor: Colors.white);
      } else if (response.statusCode == 700) {
        Navigator.pushNamed(context, "/bvn-verification");
      } else if (response.statusCode == 800) {
        Navigator.pushNamed(context, "/add-document");
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> rejectPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
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
      bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestRejected);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, PaymentRequest paymentRequest, int index) {
    return Slidable(
      key: Key(paymentRequest.payee),
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(paymentRequest),
      actions: listActionSlideActions(paymentRequest, index),
      secondaryActions: listSecondaryActions(paymentRequest, index),
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
  VerticalListItem(this.paymentRequest);
  final PaymentRequest paymentRequest;

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
        child: PaymentRequestTile(
            paymentRequest: widget.paymentRequest,
            expandedWidget: expandedWidget()),
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
        _auth.fetchCustomerProfile(widget.paymentRequest.payee).then((user) {
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
        _auth.fetchCustomerProfile(widget.paymentRequest.payee).then((user) {
          _auth.blockUser(user).then((result) {
            if (mounted) {
              setState(() {
                isExpanded = false;
              });
            }
            if (result) {
              Toast.show("${widget.paymentRequest.payee} is Blocked", context);
            } else {
              Toast.show("Error occurs", context);
            }
          });
        });
      },
    );
  }
}
