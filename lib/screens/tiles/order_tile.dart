import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final PaymentRequest paymentRequest;
  OrderTile({this.paymentRequest});

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
      "Ref # : 1234567890102",
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
          color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${paymentRequest.payee.length > 17 ? paymentRequest.payee.substring(0, 17) : paymentRequest.payee}",
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
