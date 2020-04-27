import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/payout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PayoutTile extends StatelessWidget {
  final Payout payout;
  PayoutTile({this.payout});

  //TODO: amount, payout date time, status
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: ListTile(
            leading: ClipOval(
              child: CachedNetworkImage(
                imageUrl: payout.bankLogo,
                height: 45,
                width: 45,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => payout.bankLogo == ""
                    ? Icon(Icons.account_balance)
                    : CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
              ),
            ),
            title: Text(payout.bankName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            subtitle: getDateTime(context),
            trailing: Text(
              worldCurrencies[payout.currency] + ' ' + payout.amount.toString(),
              style: TextStyle(
                  color: getStatusColor(payout.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
      ),
    );
  }

  getStatusColor(String status) {
    if (status == "Paid") {
      return Colors.green[400];
    } else if (status == "Pending") {
      return Colors.orange[400];
    } else {
      return Colors.red[400];
    }
  }

  Widget getDateTime(BuildContext context) {
    DateTime dateTime = DateTime.parse(payout.timeStamp);

    return Row(
      children: <Widget>[
        Text(
          AppLocalization.of(context).date +
              ": ${dateTime.day}/${dateTime.month}/${dateTime.year}",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
            AppLocalization.of(context).time +
                ": ${dateTime.hour}:${dateTime.minute}",
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
