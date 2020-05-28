import 'package:Slydo/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserTile extends StatelessWidget {
  CustomerProfile user;
  UserTile({this.user});

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
