import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class PaymentRequestList extends StatefulWidget {
  @override
  _PaymentRequestListState createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
          _onRefresh();
          _refreshBloc.isRefresh = false;
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
        getList();
        _refreshController.refreshCompleted();
      } else {
        Toast.show("Internet Connection is not available", context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // refresh the list when lifecycle called onResume method\
    _onRefreshOnResume();

    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dashboard');
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: lightBlue(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: darkBlue(),
            title: Text('Payment Requests'),
            actions: <Widget>[
              sendRequestButton(),
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
        ));
  }

  Widget _buildRequestPaymentList() {
    return noItemInList
        ? NoItemInList(
            msg: "No Pending Payment Request.",
          )
        : ListView.builder(
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
        Map<String, dynamic> result =
            await _auth.listPaymentRequests(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        setState(() {
          isLoading = false;
          requestPaymentList.addAll(tempList);
        });
      }
      if (requestPaymentList.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && requestPaymentList.length > 6) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Your have reached the bottom of the list"),
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
              Navigator.of(context).pushNamed('/request-payment',
                  arguments: <String, bool>{
                    'isRequest': true,
                    'isFromProfile': true
                  });
            } else {
              Toast.show("Internet Connection is not available", context,
                  gravity: Toast.BOTTOM, backgroundColor: darkBlue());
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
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    String caption = !paymentRequest.isCredit ? 'Cancel' : 'Reject';
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
          caption: 'Send Money',
          color: Colors.green,
          icon: Icons.reply,
          onTap: () {
            acceptPaymentRequestAlert(paymentRequest, index);
          },
        ),
      ];
    }
  }

  void acceptPaymentRequestAlert(PaymentRequest paymentRequest, int index) {
    showDialog(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Text('Are you sure want to Accept this request?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            )),
        actions: <Widget>[
          FlatButton(
            child: const Text('YES'),
            color: darkBlue(),
            onPressed: () async {
              bool done = await _auth.acceptPaymentRequests(paymentRequest);
              if (done) {
                Navigator.pop(context);
                _showSnackBar(context, 'Payment Request Accepted !!');
                setState(() {
                  requestPaymentList.removeAt(index);
                  if (requestPaymentList.length <= 9) {
                    getList();
                  }
                });
              } else {
                Navigator.pop(context);
                _showSnackBar(context, "Error");
              }
            },
          ),
          FlatButton(
            color: darkBlue(),
            child: const Text(
              'NO',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  void rejectPaymentRequestAlert(PaymentRequest paymentRequest, int index) {
    showDialog(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Text('Are you sure want to reject this request?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            )),
        actions: <Widget>[
          FlatButton(
            child: const Text('YES'),
            color: darkBlue(),
            onPressed: () async {
              bool done = await _auth.rejectPaymentRequests(paymentRequest);
              if (done) {
                Navigator.pop(context);
                _showSnackBar(context, "Payment Request Rejected !!");
                setState(() {
                  requestPaymentList.removeAt(index);
                  if (requestPaymentList.length <= 9) {
                    getList();
                  }
                });
              } else {
                Navigator.pop(context);
                _showSnackBar(context, "Error");
              }
            },
          ),
          FlatButton(
            color: darkBlue(),
            child: const Text(
              'NO',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            onPressed: () {
              setState(() {
                //requestPaymentList.insert(index, paymentRequest);
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void showMaterialDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
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
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.paymentRequest);
  final PaymentRequest paymentRequest;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: lightBlue(),
        child: PaymentRequestTile(paymentRequest: paymentRequest),
      ),
    );
  }
}
