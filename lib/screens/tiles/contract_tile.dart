import 'dart:math';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/contract_and_invoice/Contract.dart';
import 'package:Slydo/models/contract_and_invoice/Invoice.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ContractTile extends StatefulWidget {
  final Contract contract;
  final Function onTap;

  ContractTile({this.contract, this.onTap});

  @override
  _ContractTileState createState() => _ContractTileState();
}

class _ContractTileState extends State<ContractTile> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            dense: true,
            title: getTitle(),
            subtitle: getSubTitle(context),
            leading: getLeading(),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                getAmount(),
                SizedBox(
                  height: 4,
                ),
                getPaymentDuration()
              ],
            ),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }

  Widget getPaymentDuration() {
    bool isPaid = Random().nextBool();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
          color: getPaymentDurationColor(),
          borderRadius: BorderRadius.circular(4)),
      child: Text(getPaymentDurationText(),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Color getPaymentDurationColor() {
    switch (widget.contract.paymentDuration) {
      case "daily":
        return starYellow;
        break;
      case "weekday_only":
        return richPurple;
        break;
      case "weekly":
        return naturalGreen;
        break;
      case "monthly":
        return richPink;
        break;
      case "yearly":
        return navyBlue;
        break;
      default:
        return navyBlue;
    }
  }

  String getPaymentDurationText() {
    switch (widget.contract.paymentDuration) {
      case "daily":
        return "Daily";
        break;
      case "weekday_only":
        return "Weekday";
        break;
      case "weekly":
        return "Weekly";
        break;
      case "monthly":
        return "Monthly";
        break;
      case "yearly":
        return "Yearly";
        break;
      default:
        return "";
    }
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${widget.contract.contractor}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.contract.contractorAvatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.contract.contractorAvatar == ""
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
          worldCurrencies[widget.contract.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          widget.contract.amount.toString(),
          style: TextStyle(
              color: navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.contract.note}",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
        ),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime transactionTime = DateTime.parse(widget.contract.createdAt);
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

class InvoiceTile extends StatefulWidget {
  final Invoice invoice;
  final Function onTap;

  InvoiceTile({this.invoice, this.onTap});

  @override
  _InvoiceTileState createState() => _InvoiceTileState();
}

class _InvoiceTileState extends State<InvoiceTile> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            dense: true,
            title: getTitle(),
            subtitle: getSubTitle(context),
            leading: getLeading(),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                getAmount(),
                SizedBox(
                  height: 4,
                ),
                invoiceStatus()
              ],
            ),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }

  Widget invoiceStatus() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
          color: getStatusColor(), borderRadius: BorderRadius.circular(4)),
      child: Text(widget.invoice.status,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Color getStatusColor() {
    switch (widget.invoice.status) {
      case "Draft":
        return eyeGrey;
        break;
      case "Pending":
        return starYellow;
        break;
      case "Paid":
        return naturalGreen;
        break;
      case "Unpaid":
        return mateRed;
        break;
      default:
        return navyBlue;
    }
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${widget.invoice.toCustomer}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.invoice.toCustomerAvatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.invoice.toCustomerAvatar == ""
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
          worldCurrencies[widget.invoice.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          widget.invoice.amount.toString(),
          style: TextStyle(
              color: navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    DateTime dateAndTime = DateTime.parse(widget.invoice.dueDate);
    String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    String time = DateFormat("hh:mm a").format(dateAndTime);

    bool paymentIsDue = dateAndTime.isBefore(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Due Date:- $date • $time",
          style:
              TextStyle(color: paymentIsDue ? mateRed : darkGrey, fontSize: 10),
          maxLines: 1,
        ),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime dateAndTime = DateTime.parse(widget.invoice.createdAt);
    String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    String time = DateFormat("hh:mm a").format(dateAndTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
