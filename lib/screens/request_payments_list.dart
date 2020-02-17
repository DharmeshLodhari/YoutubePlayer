import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../widget/LoadingIndicator.dart';

class PaymentRequestList extends StatefulWidget {
  @override
  _PaymentRequestListState createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList> {
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List requestPaymentList = [];
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;

  @protected
  void initState() {
    setState(() {
      isLoading = true;
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // CircularProgressIndicator();
        setState(() {
          isLoading = true;
        });
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
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text('Payment Requests'),
          actions: <Widget>[
            sendRequestButton(),
          ],
        ),
        body: FutureBuilder(
          future: getList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return LoadingIndicator();
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount: requestPaymentList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (isLoading) {
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    //requestPaymentList[index]
                    var item = requestPaymentList[index];
//                    return Dismissible(
//                      key: UniqueKey(),
//                      child: PaymentRequestTile(
//                        paymentRequest: item,
//                      ),
//                    );
                    return _getSlidableWithLists(context, item, index);
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  getList() {
    if (next != null && isLoading) {
      Future<Map<String, dynamic>> result =
          _auth.listPaymentRequests(next, previous);

      result.then((value) {
        count = value['count'];
        next = value['next'];
        previous = value['previous'];
        var tempList = value['results'];
        print(count);
        print(next);
        print(previous);
        print(requestPaymentList);
        requestPaymentList.addAll(tempList);
        print(requestPaymentList.length);
        print(requestPaymentList);
      });
      setState(() {
        isLoading = false;
      });
      return result;
    }
    if (next != null) {
//      setState(() {
//        isLoading = true;
//      });

    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Your have reached at bottom of the list"),
      ));
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
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    String caption = paymentRequest.isCredit ? 'Cancel' : 'Reject';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () async {
            bool done = await _auth.rejectPaymentRequests(paymentRequest.id);
            if (done) {
              _showSnackBar(context, caption);
              requestPaymentList.removeAt(index);
            } else {
              _showSnackBar(context, "Error");
            }
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
            onTap: () async {
              bool done = await _auth.acceptPaymentRequests(paymentRequest.id);
              if (done) {
                _showSnackBar(context, 'Accept');
                requestPaymentList.removeAt(index);
              } else {
                _showSnackBar(context, "Error");
              }
            }),
      ];
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, PaymentRequest paymentRequest, int index) {
    return Slidable(
      key: Key(paymentRequest.payee),
      controller: slidableController,
      direction: Axis.horizontal,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {
          _showSnackBar(
              context,
              actionType == SlideActionType.primary
                  ? 'Dismiss Archive'
                  : 'Dimiss Delete');
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
