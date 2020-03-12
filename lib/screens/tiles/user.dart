import 'package:Slydo/models/transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            subtitle: Text(user.description),
            leading: CachedNetworkImage(
              imageUrl: user.avatar,
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => user.avatar == ""
                  ? Icon(
                      Icons.person,
                      color: Colors.black,
                    )
                  : CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
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
