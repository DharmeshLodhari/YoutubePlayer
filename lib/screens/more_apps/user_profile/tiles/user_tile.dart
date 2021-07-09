import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserTile extends StatefulWidget {
  CustomerProfile user;

  UserTile({this.user});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    Widget avatarImage;

    Color borderColor = getUserTypeColor(user: widget.user);

    avatarImage = GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/photo-viewer", arguments: widget.user.avatar);
      },
      child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(color: borderColor, width: 2)),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.user.avatar == ""
                  ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                  : widget.user.avatar,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          )),
    );

    Widget tile = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: Text(
            widget.user.fullName,
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: getSubtitle(context),
          leading: avatarImage,
        ),
      ),
    );
    return tile;
  }

  Widget getSubtitle(BuildContext context) {
    return Text(
      widget.user.userName,
      maxLines: 1,
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }
}
