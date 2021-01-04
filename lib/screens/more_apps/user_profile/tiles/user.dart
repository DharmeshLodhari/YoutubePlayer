import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserTile extends StatelessWidget {
  CustomerProfile user;

  UserTile({this.user});

  @override
  Widget build(BuildContext context) {
    Widget avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : user.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ));

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
            user.fullName,
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Text(
            user.userName,
            maxLines: 1,
            style: TextStyle(
              color: darkGrey,
              fontSize: 12,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          leading: avatarImage,
          trailing: getTrailing(),
        ),
      ),
    );
    return tile;
  }

  Widget getTrailing() {
    return FutureBuilder<ChatUserModel>(
        future: ChatUserManager().getUser(user.conversationId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(
                "Error:- while retrieving message count ${snapshot.error}");
            return Container(
              width: 1,
              height: 1,
            );
          } else if (snapshot.hasData) {
            debugPrint("Data:- ${snapshot.data.messageCount}");

            if (snapshot.data.messageCount == 0) {
              return Container(
                width: 1,
                height: 1,
              );
            }

            return Badge(
              elevation: 0,
              badgeColor: naturalGreen,
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                "${snapshot.data.messageCount}",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              position: BadgePosition(end: 0, top: 0),
            );
          }
          return Container(
            width: 1,
            height: 1,
          );
        });
  }
}
