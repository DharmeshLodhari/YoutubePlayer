import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../routes/route_constants.dart';

class UserProfileTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  UserProfileTileForChat({this.message, this.chatConversation});

  @override
  _UserProfileTileForChatState createState() => _UserProfileTileForChatState();
}

class _UserProfileTileForChatState extends State<UserProfileTileForChat> {
  late UserBloc userBloc;

  CustomerProfile? customerProfile;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    Map<String, dynamic>? data;

    if (widget.message!['meta_data'] is String) {
      data = jsonDecode(widget.message!['meta_data']);
    } else if (widget.message!['meta_data'] is Map) {
      data = widget.message!['meta_data'];
    }

    customerProfile = CustomerProfile.fromJson(data!);

    final bool isSend = widget.message!["author"] == userBloc.user.userName;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSend) Container() else Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              padding: EdgeInsets.symmetric(
                  horizontal: widget.chatConversation!.isGroupConversation!
                      ? isSend
                          ? 0
                          : 8
                      : 0,
                  vertical: widget.chatConversation!.isGroupConversation!
                      ? isSend
                          ? 0
                          : 8
                      : 0),
              decoration: BoxDecoration(
                color: widget.chatConversation!.isGroupConversation!
                    ? isSend
                        ? Colors.transparent
                        : Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(!isSend ? 0 : 10),
                  bottomRight: Radius.circular(isSend ? 0 : 10),
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.chatConversation!.isGroupConversation!)
                    widget.message!['author'] != userBloc.user.userName
                        ? Column(
                            children: [
                              Text(
                                widget.message!['author_full_name'] ??
                                    widget.message!['author'],
                                style: TextStyle(
                                    color: isSend ? Colors.white : navyBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )
                        : Container(
                            width: 0,
                          )
                  else
                    Container(
                      width: 0,
                    ),
                  UserProfileTile(user: customerProfile),
                ],
              ),
            ),
            if (isSend)
              Container(
                width: 20,
                child: isSend
                    ? Center(
                        child: getMessageTick(message: widget.message!),
                      )
                    : Container(),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isSend)
              Container()
            else
              const SizedBox(
                width: 20,
              ),
            Text(
              formatTime(widget.message!['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            if (isSend)
              const SizedBox(
                width: 20,
              )
            else
              Container(),
          ],
        )
      ],
    );
  }
}

class UserProfileTile extends StatefulWidget {
  final CustomerProfile? user;

  UserProfileTile({this.user});

  @override
  _UserProfileTileState createState() => _UserProfileTileState();
}

class _UserProfileTileState extends State<UserProfileTile> {
  Widget? avatarImage;

  late Color borderColor;

  @override
  Widget build(BuildContext context) {
    borderColor = getUserTypeColor(user: widget.user!);
    return getTile();
  }

  Widget getAvatar() {
    return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:
                widget.user!.avatar == "" ? defaultImage : widget.user!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ));
  }

  Widget getTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 3,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: getTitle(),
          subtitle: getSubtitle(),
          leading: getAvatar(),
          onTap: () {
            Navigator.pushNamed(context, Routes.USER_PROFILE,
                arguments: {"searchedUserName": widget.user!.userName});
          },
          // trailing: getTrailing(),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      widget.user!.displayName()!,
      maxLines: 1,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getSubtitle() {
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
