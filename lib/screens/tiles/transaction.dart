import 'package:PayBay/models/transactions.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {

  final Transaction transaction;
  TransactionTile({ this.transaction });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text("MTN Nigeria Ltd",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
          ),
          subtitle: Text("Insufficient Funds"),
          leading: Image.network(
            'https://cdn.primedia.co.za/primedia-broadcasting/image/upload/c_fill,h_289,w_463/vog0kklmjnimmofrd1u4',
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          ),
          trailing: Text(
            "₦ 98,042",
          style: TextStyle(color: Colors.green[400],
              fontWeight: FontWeight.bold,
              fontSize: 15),
          )
        ),
      ),
    );
  }
}