import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  bool isLoading = false;
  bool noItemInList = false;

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

  @override
  Widget build(BuildContext context) {
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
          body: _buildRequestPaymentList()),
    );
  }

  Widget _buildRequestPaymentList() {
    return noItemInList
        ? NoItemInList(
            msg: "You Have No Payment Request Pending",
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
          content: Text("Your have reached at bottom of the list"),
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
          Navigator.of(context).pushNamed('/request-payment',
              arguments: <String, bool>{'isFromProfile': true});
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    String caption = paymentRequest.isCredit ? 'Cancel' : 'Reject';
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
    if (paymentRequest.isCredit) {
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
    showScaleAlertBox(
      context: context,
      yourWidget: Text("Are You Sure Want To Accept This Payment ? "),
      icon: Icon(Icons.warning),
      title: Text("Accept Payment Request"),
      firstButton: MaterialButton(
        color: darkBlue(),
        child: Text(
          "Yes",
          style: TextStyle(color: Colors.white),
        ),
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
            _showSnackBar(context, "Error");
          }
        },
      ),
      secondButton: MaterialButton(
        color: darkBlue(),
        child: Text(
          "No",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          setState(() {
            requestPaymentList.insert(index, paymentRequest);
            Navigator.pop(context);
          });
        },
      ),
    );
  }

  void rejectPaymentRequestAlert(PaymentRequest paymentRequest, int index) {
    showScaleAlertBox(
      context: context,
      yourWidget: Text("Are You Sure Want To Reject This Payment ? "),
      icon: Icon(Icons.warning),
      title: Text("Cancle Payment Request"),
      firstButton: MaterialButton(
        color: darkBlue(),
        child: Text(
          "Yes",
          style: TextStyle(color: Colors.white),
        ),
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
            _showSnackBar(context, "Error");
          }
        },
      ),
      secondButton: MaterialButton(
        color: darkBlue(),
        child: Text(
          "No",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          setState(() {
            requestPaymentList.insert(index, paymentRequest);
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, PaymentRequest paymentRequest, int index) {
    return Slidable(
      key: Key(paymentRequest.payee),
//      key: UniqueKey(),
      controller: slidableController,
      direction: Axis.horizontal,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {
          setState(() {
            requestPaymentList.removeAt(index);
          });
          if (actionType == SlideActionType.primary) {
            acceptPaymentRequestAlert(paymentRequest, index);
          } else {
            rejectPaymentRequestAlert(paymentRequest, index);
          }

          //make http call here
        },
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(paymentRequest),
      actions: listActionSlideActions(paymentRequest, index),
      secondaryActions: listSecondaryActions(paymentRequest, index),
    );
  }

  Future showScaleAlertBox({
    @required BuildContext context,
    @required Widget yourWidget,
    Widget icon,
    Widget title,
    @required Widget firstButton,
    Widget secondButton,
  }) {
    assert(context != null, "context is null!!");
    assert(yourWidget != null, "yourWidget is null!!");
    assert(firstButton != null, "button is null!!");
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.7),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                title: title,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    icon,
                    Container(
                      height: 10,
                    ),
                    yourWidget
                  ],
                ),
                actions: <Widget>[
                  firstButton,
                  secondButton,
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
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

enum LoadMoreData { LOADING, STABLE }
