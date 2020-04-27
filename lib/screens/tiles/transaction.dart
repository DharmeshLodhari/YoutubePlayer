import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentRequestTile extends StatelessWidget {
  final PaymentRequest paymentRequest;
  PaymentRequestTile({this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing: paymentRequest.amount.toString().length > 6
                    ? null
                    : getTrailing(),
                subtitle: getSubtitle(context)),
          ),
        ],
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

  Widget getSubtitle(BuildContext context) {
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
        paymentRequest.amount.toString().length > 6
            ? getTrailing()
            : Container(),
        getDateTime(context)
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime requestTime = DateTime.parse(paymentRequest.createdAt);

    return Row(
      children: <Widget>[
        Text(
          AppLocalization.of(context).date +
              ": ${requestTime.day}/${requestTime.month}/${requestTime.year}",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
            AppLocalization.of(context).time +
                ": ${requestTime.hour}:${requestTime.minute}",
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

// ignore: must_be_immutable
class TransactionTile extends StatelessWidget {
  UserBloc userBloc;
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: getTitle(),
          subtitle: getSubTitle(context),
          leading: getLeading(),
          trailing:
              transaction.amount.toString().length > 6 ? null : getAmount(),
          onTap: () {
//            if (userBloc.user.setting.enableTransactionDetailPage) {
            Navigator.of(context).pushNamed('/transaction-detail',
                arguments: {'transaction': transaction});
//            }
          },
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${transaction.payee.length > 17 ? transaction.payee.substring(0, 17) : transaction.payee}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getLeading() {
    return ClipOval(
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
    );
  }

  Widget getAmount() {
    return Text(
      worldCurrencies[transaction.currency] +
          ' ' +
          transaction.amount.toString(),
      style: TextStyle(
          color: transaction.isCredit ? Colors.green[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
            "${transaction.description.length > 20 ? transaction.description.substring(0, 20) : transaction.description}"),
        SizedBox(
          height: 2,
        ),
        transaction.amount.toString().length > 6 ? getAmount() : Container(),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime transactionTime = DateTime.parse(transaction.createdAt);

    return Row(
      children: <Widget>[
        Text(
          AppLocalization.of(context).date +
              ": ${transactionTime.day}/${transactionTime.month}/${transactionTime.year}",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
            AppLocalization.of(context).time +
                ": ${transactionTime.hour}:${transactionTime.minute}",
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
