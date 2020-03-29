import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/payout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PayoutTile extends StatelessWidget {
  final Payout payout;
  PayoutTile({this.payout});

  //TODO: amount, payout date time, status
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Status : ${payout.status} ",
                ),
                Text("Time : ${payout.timeStemp} "),
              ],
            ),
            trailing: Text(
              worldCurrencies[payout.currency] + ' ' + payout.amount.toString(),
              style: TextStyle(
                  color: Colors.green[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
      ),
    );
  }
}
