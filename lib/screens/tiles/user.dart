import 'package:Slydo/models/transactions.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final Transaction user;
  UserTile({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            title: Text(
              user.payee,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(user.description),
            leading: Image.network(
              user.avatar,
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
              loadingBuilder:
                  (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 45,
                  width: 45,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
            trailing: Text(
              user.currency + ' ' + user.amount.toString(),
              style: TextStyle(
                  color: user.isCredit ? Colors.green[400] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
      ),
    );
  }
}
