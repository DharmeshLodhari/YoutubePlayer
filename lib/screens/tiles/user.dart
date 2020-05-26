import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

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
            leading: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                height: 50,
                width: 50,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => user.avatar == ""
                    ? Icon(Icons.person)
                    : CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: lightBlue(),
                      ),
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

// ignore: must_be_immutable
class CustomerTile extends StatelessWidget {
  CustomerProfile user;
  CustomerTile({this.user});

  @override
  Widget build(BuildContext context) {
    Widget avatarImage = Container(
        height: 50,
        width: 50,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : user.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ));

    Widget tile = Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          semanticContainer: true,
          child: ListTile(
            dense: true,
            title: Text(
              user.fullName,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            subtitle: Text(
              user.userName,
              maxLines: 1,
            ),
            leading: avatarImage,
          ),
        ));

    return tile;
  }
}
