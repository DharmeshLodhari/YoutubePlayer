import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class UserTileForConnection extends StatefulWidget {
  ChatConversation? user;

  UserTileForConnection({this.user});

  @override
  _UserTileForConnectionState createState() => _UserTileForConnectionState();
}

class _UserTileForConnectionState extends State<UserTileForConnection> {
  bool isTyping = false;

  MainSocketProvider? mainSocketProvider;
  StreamSubscription? streamSubscription;
  String? typingMessage = "";

  late UserBloc userBloc;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      try {
        if (mounted) {
          mainSocketProvider =
              Provider.of<MainSocketProvider>(context, listen: false);

          streamSubscription = mainSocketProvider!.listen((message) {
            Map<String, dynamic> messageData = jsonDecode(message);
            if (messageData["type"] == "user_typing_message" &&
                messageData["conversation_id"] == widget.user!.conversationId) {
              isTyping = true;
              typingMessage = messageData["message"];
              if (mounted) setState(() {});
              Future.delayed(Duration(milliseconds: 500)).then((value) {
                isTyping = false;
                typingMessage = "";
                if (mounted) setState(() {});
              });
            }
          });
        }
      } catch (error) {
        debugPrint("ERROR10 :- $error");
      }
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
    userBloc = Provider.of<UserBloc>(context);
    Widget avatarImage;

    Color borderColor = getUserTypeColorByType(type: widget.user!.type!);

    avatarImage = GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/photo-viewer", arguments: widget.user!.avatar);
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
              imageUrl: widget.user!.avatar == "" || widget.user!.avatar == null
                  ? defaultImage
                  : widget.user!.avatar!,
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
            widget.user!.fullName!,
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
            typingMessage!,
            style: TextStyle(
              color: naturalGreen,
            ),
          )
        : Text(
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

  Widget getTrailing() {
    return StreamBuilder(
        stream: ChatMessageSynchronizer().getChatMessageCountStream,
        builder: (context, snapshot) {
          return FutureBuilder<ChatUserModel>(
              future: ChatUserManager().getUser(widget.user!.conversationId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                } else if (snapshot.hasData) {
                  return getBadgeAndGroupLabel(snapshot.data!.messageCount);
                }
                return Container(
                  width: 0,
                  height: 0,
                );
              });
        });
  }

  Widget getBadgeAndGroupLabel(int? count) {
    if (!widget.user!.isGroupConversation!) {
      if (count == 0) {
        return Container(
          width: 0,
          height: 0,
        );
      } else {
        return getBadge(count!, padding: 12);
      }
    } else {
      if (count == 0) {
        return getGroupLabel();
      } else {
        return Column(
          crossAxisAlignment: checkUserIsAdmin() || checkUserIsOwner()
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
          children: [
            getBadge(count!,
                padding: checkUserIsAdmin() || checkUserIsOwner() ? 10 : 0),
            Expanded(
              child: SizedBox(
                height: 4,
              ),
            ),
            getGroupLabel(),
          ],
        );
      }
    }
  }

  Widget getGroupLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        checkUserIsAdmin() || checkUserIsOwner()
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: navyBlue.withOpacity(0.1),
                    ),
                    child: Icon(
                      checkUserIsOwner() ? Icons.group : Icons.person,
                      color: navyBlue,
                      size: 12,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                ],
              )
            : Container(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: naturalGreen.withOpacity(0.1),
          ),
          child: Text(
            "Group",
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: naturalGreen),
          ),
        ),
      ],
    );
  }

  bool checkUserIsAdmin() {
    if (widget.user!.adminUsers.contains(userBloc.user.userName)) return true;
    return false;
  }

  bool checkUserIsOwner() {
    if (widget.user!.owner!.contains(userBloc.user.userName!)) return true;
    return false;
  }

  Widget getBadge(int count, {double padding = 0}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Badge(
        elevation: 0,
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: Text(
          getCountForMessage(count),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12),
        ),
        position: BadgePosition(end: 0, top: 0),
      ),
    );
  }

  String getCountForMessage(int count) {
    return count > 999 ? "999+" : "$count";
  }
}
