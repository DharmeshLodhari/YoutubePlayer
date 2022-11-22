import 'dart:convert';

import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

import '../../../../data/state_notifier.dart';
import '../../../../utils/util.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../messaging/chat/models/ChatConversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';

class TopicActions extends StatefulWidget {
  YarnTopic yarnTopic;
  int? commentCount;
  int? likeCount;
  int? disLikeCount;

  TopicActions({required this.yarnTopic, this.commentCount, this.likeCount, this.disLikeCount});

  @override
  State<TopicActions> createState() => _TopicActionsState();
}

class _TopicActionsState extends State<TopicActions> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset("ask/reply".toSVG()),
            SizedBox(
              width: 6,
            ),
            Text(
              getCommentCount(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/like".toSVG()),
            SizedBox(
              width: 6,
            ),
            Text(
              getLikeCount(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/dislike".toSVG()),
            SizedBox(
              width: 6,
            ),
            Text(
              getDisLikeCount(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            androidBottomSheet(
              context: context,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bottomSheetItem(
                      title: 'Share in chat',
                      iconData: Icons.send_outlined,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await sendMomentToUserInChat(
                            yarnTopic: widget.yarnTopic);
                      }),
                ],
              ),
            );
          },
          child: Row(
            children: [
              SvgPicture.asset("ask/share".toSVG()),
            ],
          ),
        ),
      ],
    );
  }

  String getCommentCount() {
    if (widget.commentCount != null &&
        widget.commentCount != 0) {
      return widget.commentCount?.toString() ?? "";
    }
    return "";
  }

  String getLikeCount() {
    if (widget.likeCount != null &&
        widget.likeCount != 0) {
      return widget.likeCount?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.disLikeCount != null &&
        widget.disLikeCount != 0) {
      return widget.disLikeCount?.toString() ?? "";
    }
    return "";
  }

  Future<void> sendMomentToUserInChat({required YarnTopic yarnTopic}) async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(recipientUser: recipient!, yarnTopic: yarnTopic);
    });
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required YarnTopic yarnTopic,
    String? url,
  }) async {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    Map<String, dynamic> metaData = {
      "id": yarnTopic.id,
      "title": messageDecoderWithEmoji(yarnTopic.title),
      "author_avatar": yarnTopic.authorAvatar,
      "author_username": messageDecoderWithEmoji(yarnTopic.authorName),
      "image": yarnTopic.media,
      "description": yarnTopic.body,
    };

    // switch (yarnTopic.mediaType) {
    //   case "image":
    //     metaData.addAll({"image": momentsModel.media});
    //     break;
    //   case "video":
    //     metaData.addAll({"image": momentsModel.mediaPoster});
    //     break;
    // }

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'yarn',
      "kind": "yarn",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(
        message: yarnTopic.isQuestion! ? 'Yarn Shared' : 'Question Shared');
  }
}
