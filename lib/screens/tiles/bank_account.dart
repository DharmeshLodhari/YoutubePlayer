import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BankAccountTile extends StatelessWidget {
  // Pass account object into this constructor
  final BankAccount account;
  BankAccountTile({this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            account.bankName,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle:
              Text('******' + account.accountNumber.toString().substring(5, 9)),
          leading: CachedNetworkImage(
            imageUrl: account.bankAvatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[400]),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
