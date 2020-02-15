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
  // Get list of user bank account
  final _auth = AuthService();
  SlidableController slidableController;

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
        ),
        body: FutureBuilder(
          future: _auth.listPaymentRequests(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return LoadingIndicator();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = snapshot.data[index];
                  return _getSlidableWithLists(context, item, index, snapshot);
                },
              );
            }
          },
        ),
        floatingActionButton: sendRequestButton(),
      ),
    );
  }

  Widget sendRequestButton() {
    return FloatingActionButton(
      backgroundColor: darkBlue(),
      onPressed: () {
        Navigator.of(context).pushNamed('/request-payment',
            arguments: <String, bool>{'isFromProfile': true});
      },
      tooltip: 'Request Payment',
      child: Icon(Icons.add),
    );
  }

  @protected
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
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

  List<Widget> listSecondaryActions(
      PaymentRequest paymentRequest, int index, AsyncSnapshot snapshot) {
    String caption = paymentRequest.isCredit ? 'Cancel': 'Reject';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () {
//          bool done = _auth.rejectPaymentRequests();
//          if (done){
//            _showSnackBar(context, caption);
//            snapshot.data.removeAt(index);
//          }else{
//            _showSnackBar(context, "Error");
//          }
          }),
    ];
  }

  List<Widget> listActionSlideActions(
      PaymentRequest paymentRequest, int index, AsyncSnapshot snapshot) {
    if (paymentRequest.isCredit) {
      return [];
    } else {
      return [
        IconSlideAction(
            caption: 'Send Money',
            color: Colors.green,
            icon: Icons.reply,
            onTap: () {
              //bool done = _auth.acceptPaymentRequests();
//          if (done){
//            _showSnackBar(context, 'Accept');
//            snapshot.data.removeAt(index);
//          }else{
//            _showSnackBar(context, "Error");
//          }
            }),
      ];
    }
  }

  Widget _getSlidableWithLists(BuildContext context,
      PaymentRequest paymentRequest, int index, AsyncSnapshot snapshot) {
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
      actions: listActionSlideActions(paymentRequest, index, snapshot),
      secondaryActions: listSecondaryActions(paymentRequest, index, snapshot),
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
