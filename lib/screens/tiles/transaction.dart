import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      "${paymentRequest.payee.length > 17 ? paymentRequest.payee.substring(0, 17) : paymentRequest.payee}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Text(
      worldCurrencies[paymentRequest.currency] +
          ' ' +
          paymentRequest.amount.toString(),
      style: TextStyle(
          color: paymentRequest.isCredit ? Colors.grey[600] : Colors.green[400],
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }

  Widget getSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${paymentRequest.description.length > 20 ? paymentRequest.description.substring(0, 20) : paymentRequest.description}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          height: 2,
        ),
        getDateTime()
      ],
    );
  }

  Widget getDateTime() {
    DateTime requestTime = DateTime.parse(paymentRequest.createdAt);

    return Row(
      children: <Widget>[
        Text(
          " ${requestTime.day}/${requestTime.month}/${requestTime.year}",
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(
          width: 10,
        ),
        Text("${requestTime.hour}:${requestTime.minute}",
            style: TextStyle(fontSize: 10)),
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  UserBloc userBloc;
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            transaction.payee,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: getSubTitle(),
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
            worldCurrencies[transaction.currency] +
                ' ' +
                transaction.amount.toString(),
            style: TextStyle(
                color:
                    transaction.isCredit ? Colors.green[400] : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          onTap: () {
            if (userBloc.user.setting.enableTransactionDetailPage) {
              //TODO:NAVIGATE to Transaction detailPage
            }
          },
        ),
      ),
    );
  }

  Widget getSubTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(transaction.description),
        SizedBox(
          height: 2,
        ),
        getDateTime()
      ],
    );
  }

  Widget getDateTime() {
    DateTime transactionTime = DateTime.parse(transaction.createdAt);

    return Row(
      children: <Widget>[
        Text(
          " ${transactionTime.day}/${transactionTime.month}/${transactionTime.year}",
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(
          width: 10,
        ),
        Text("${transactionTime.hour}:${transactionTime.minute}",
            style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
