import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../screens/user_profile_module_new/profile_template/utils.dart';

// ignore: must_be_immutable
class UserTile extends StatefulWidget {
  CustomerProfile? user;

  UserTile({this.user});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    Widget tile = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: userNameWithVerifiedIcon(
            name: widget.user!.displayName()!,
            isVerified: widget.user!.isVerified,
          ),
          subtitle: getSubtitle(context),
          leading: getAvatar(),
        ),
      ),
    );
    return tile;
  }

  Widget getAvatar() {
    Color borderColor = getUserTypeColorByType(type: widget.user!.type!);

    if (widget.user!.avatar == null ||
        widget.user!.avatar == "" ||
        widget.user!.avatar ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(widget.user!.fullName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25,
          ),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.user!.avatar == "" || widget.user!.avatar == null
                ? defaultImage
                : widget.user!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      );
    }
  }

  Widget getSubtitle(BuildContext context) {
    return Text(
      widget.user!.userName!,
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
