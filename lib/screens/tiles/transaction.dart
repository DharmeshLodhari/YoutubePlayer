import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PaymentRequestTile extends StatelessWidget {
  final PaymentRequest paymentRequest;
  PaymentRequestTile({this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: <Widget>[
            ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing: getTrailing(),
                subtitle: getSubtitle()),
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: paymentRequest.avatar,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => paymentRequest.avatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      paymentRequest.payee,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Text(
      paymentRequest.currency + ' ' + paymentRequest.amount.toString(),
      style: TextStyle(
          color: paymentRequest.isCredit ? Colors.green[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }

  Widget getSubtitle() {
    return Text(
      paymentRequest.description,
      style: TextStyle(
          color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            title: Text(
              transaction.payee,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            subtitle: Text(transaction.description),
            leading: ClipOval(
              child: CachedNetworkImage(
                imageUrl: transaction.avatar,
                height: 50,
                width: 50,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => transaction.avatar == ""
                    ? Icon(Icons.person)
                    : CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
              ),
            ),
            trailing: Text(
              transaction.currency + ' ' + transaction.amount.toString(),
              style: TextStyle(
                  color: transaction.isCredit
                      ? Colors.green[400]
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
      ),
    );
  }
}
