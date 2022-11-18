import 'dart:convert';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../../utils/util.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../messaging/chat/models/ChatConversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';
import "package:uuid/uuid.dart";

class TopicActions extends StatefulWidget {
  YarnTopic yarnTopic;

  TopicActions({required this.yarnTopic});

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
              width: 8,
            ),
            Text(
              "${widget.yarnTopic.numberOfComments!}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/like".toSVG()),
            SizedBox(
              width: 8,
            ),
            Text(
              "956",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/dislike".toSVG()),
            SizedBox(
              width: 8,
            ),
            Text(
              "12",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
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
                      await sendMomentToUserInChat(yarnTopic: widget.yarnTopic);
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

  Future<void> sendMomentToUserInChat(
      {required YarnTopic yarnTopic}) async {
    List<ChatConversation?> listOfRecipient =
    await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(
          recipientUser: recipient!, yarnTopic: yarnTopic);
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
    showToast(message: yarnTopic.isQuestion! ? 'Yarn Shared' : 'Question Shared');
  }
}
