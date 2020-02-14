import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/splash.dart';
import 'package:flutter/material.dart';
import '../widget/LoadingIndicator.dart';


class PaymentRequestList extends StatefulWidget {
  @override
  _PaymentRequestListState createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList> {
  // Get list of user bank account
  final _auth = AuthService();

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
                  return PaymentRequestTile(paymentRequest: item);
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
            arguments: <String, bool>{'isFromProfile': true}
        );
      },
      tooltip: 'Add Account',
      child: Icon(Icons.add),
    );
  }
}
