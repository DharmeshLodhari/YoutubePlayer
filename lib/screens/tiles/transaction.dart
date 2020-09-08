import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class PaymentRequestTile extends StatefulWidget {
  final PaymentRequest paymentRequest;
  Widget expandedWidget = Container();
  PaymentRequestTile({this.paymentRequest, this.expandedWidget});

  @override
  _PaymentRequestTileState createState() => _PaymentRequestTileState();
}

class _PaymentRequestTileState extends State<PaymentRequestTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                  dense: true,
                  leading: getLeading(),
                  title: getTitle(),
                  trailing: widget.paymentRequest.amount.toString().length > 6
                      ? null
                      : getTrailing(),
                  subtitle: getSubtitle(context)),
            ),
            widget.expandedWidget
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.paymentRequest.avatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.paymentRequest.avatar == ""
            ? Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${widget.paymentRequest.payee}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.paymentRequest.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: widget.paymentRequest.isCredit ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          widget.paymentRequest.amount.toString(),
          style: TextStyle(
              color: widget.paymentRequest.isCredit ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.paymentRequest.description}",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
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
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}

// ignore: must_be_immutable
class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  Widget expandedWidget = Container();
  TransactionTile({this.transaction, this.expandedWidget});

  @override
  _TransactionTileState createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                dense: true,
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
            widget.expandedWidget,
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${widget.transaction.payee}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.transaction.avatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.transaction.avatar == ""
            ? Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.transaction.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: widget.transaction.isCredit ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          widget.transaction.amount.toString(),
          style: TextStyle(
              color: widget.transaction.isCredit ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.transaction.description}",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
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
    String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    String time = DateFormat("hh:mm a").format(transactionTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
