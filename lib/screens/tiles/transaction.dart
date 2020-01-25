import 'package:Slydo/models/transactions.dart';
import 'package:flutter/material.dart';

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
            leading: Image.network(
              transaction.avatar,
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
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
