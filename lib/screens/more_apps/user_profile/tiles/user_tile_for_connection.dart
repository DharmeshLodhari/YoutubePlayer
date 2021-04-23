import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class UserTileForConnection extends StatefulWidget {
  CustomerProfile user;

  UserTileForConnection({this.user});

  @override
  _UserTileForConnectionState createState() => _UserTileForConnectionState();
}

class _UserTileForConnectionState extends State<UserTileForConnection> {
  bool isTyping = false;

  MainSocketProvider mainSocketProvider;
  StreamSubscription streamSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainSocketProvider =
          Provider.of<MainSocketProvider>(context, listen: false);

      streamSubscription = mainSocketProvider.listen((message) {
        Map<String, dynamic> messageData = jsonDecode(message);
        if (messageData["type"] == "user_typing_message" &&
            messageData["conversation_id"] == widget.user.conversationId) {
          isTyping = true;
          if (mounted) setState(() {});
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            isTyping = false;
            if (mounted) setState(() {});
          });
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    mainSocketProvider?.removeStreamSubscription(streamSubscription);
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarImage;

    Color borderColor = getUserTypeColor(user: widget.user);

    avatarImage = Container(
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
          trailing: getTrailing(),
        ),
      ),
    );
    return tile;
  }

  Widget getSubtitle(BuildContext context) {
    return isTyping
        ? Text(
            "Typing...",
            style: TextStyle(
              color: naturalGreen,
            ),
          )
        : Text(
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

  Widget getTrailing() {
    return FutureBuilder<ChatUserModel>(
        future: ChatUserManager().getUser(widget.user.conversationId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              width: 1,
              height: 1,
            );
          } else if (snapshot.hasData) {
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
