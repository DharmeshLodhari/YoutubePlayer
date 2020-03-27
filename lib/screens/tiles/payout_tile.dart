import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/payout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayoutTile extends StatelessWidget {
  final Payout payout;
  PayoutTile({this.payout});

  BankAccountBloc bankAccountBloc;
  //TODO: amount, payout date time, status
  @override
  Widget build(BuildContext context) {
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: bankAccountBloc.bankAccount.bankAvatar,
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => bankAccountBloc.bankAccount.bankAvatar == ""
                  ? Icon(Icons.account_balance)
                  : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          ),
            title: Text(bankAccountBloc.bankAccount.bankName,
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
