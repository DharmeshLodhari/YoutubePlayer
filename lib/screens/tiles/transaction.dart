import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';

// ignore: must_be_immutable
class PaymentRequestTile extends StatefulWidget {
  final PaymentRequest paymentRequest;
  bool isExpanded = false;
  Widget expandedWidget = Container();
  PaymentRequestTile(
      {this.paymentRequest, this.isExpanded, this.expandedWidget});

  @override
  _PaymentRequestTileState createState() => _PaymentRequestTileState();
}

class _PaymentRequestTileState extends State<PaymentRequestTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing: widget.paymentRequest.amount.toString().length > 6
                    ? null
                    : getTrailing(),
                subtitle: getSubtitle(context)),
          ),
          widget.isExpanded ? widget.expandedWidget : Container(),
        ],
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.paymentRequest.avatar,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.paymentRequest.avatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${widget.paymentRequest.payee.length > 17 ? widget.paymentRequest.payee.substring(0, 17) : widget.paymentRequest.payee}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.paymentRequest.currency] + " ",
          style: TextStyle(
              fontFamily: "Roboto",
              color: widget.paymentRequest.isCredit
                  ? Colors.grey[600]
                  : Colors.green[400],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        Text(
          widget.paymentRequest.amount.toString(),
          style: TextStyle(
              color: widget.paymentRequest.isCredit
                  ? Colors.grey[600]
                  : Colors.green[400],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.paymentRequest.description.length > 20 ? widget.paymentRequest.description.substring(0, 20) : widget.paymentRequest.description}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          height: 2,
        ),
        widget.paymentRequest.amount.toString().length > 6
            ? getTrailing()
            : Container(),
        getDateTime(context)
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime requestTime = DateTime.parse(widget.paymentRequest.createdAt);

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
class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  bool isExpanded = false;
  Widget expandedWidget = Container();
  TransactionTile({this.transaction, this.isExpanded, this.expandedWidget});

  @override
  _TransactionTileState createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: getTitle(),
              subtitle: getSubTitle(context),
              leading: getLeading(),
              trailing: widget.transaction.amount.toString().length > 6
                  ? null
                  : getAmount(),
              onTap: () {
                Navigator.of(context).pushNamed('/transaction-detail',
                    arguments: {'transaction': widget.transaction});
              },
            ),
          ),
          widget.isExpanded ? widget.expandedWidget : Container(),
        ],
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${widget.transaction.payee.length > 17 ? widget.transaction.payee.substring(0, 17) : widget.transaction.payee}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.transaction.avatar,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.transaction.avatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.transaction.currency] + " ",
          style: TextStyle(
              fontFamily: "Roboto",
              color: widget.transaction.isCredit
                  ? Colors.grey[600]
                  : Colors.green[400],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        Text(
          widget.transaction.amount.toString(),
          style: TextStyle(
              color: widget.transaction.isCredit
                  ? Colors.grey[600]
                  : Colors.green[400],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
            "${widget.transaction.description.length > 20 ? widget.transaction.description.substring(0, 20) : widget.transaction.description}"),
        SizedBox(
          height: 2,
        ),
        widget.transaction.amount.toString().length > 6
            ? getAmount()
            : Container(),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime transactionTime = DateTime.parse(widget.transaction.createdAt);

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
