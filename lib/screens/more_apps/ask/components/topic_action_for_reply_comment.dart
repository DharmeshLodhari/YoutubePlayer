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
import '../ask_auth.dart';
import '../models/Topics/ReplyCommentDetails.dart';

class TopicActionsForReplyComment extends StatefulWidget {
  ReplyCommentDetails? replyCommentDetail;
  TopicActionsForReplyComment({this.replyCommentDetail});

  @override
  State<TopicActionsForReplyComment> createState() => _TopicActionsForReplyCommentState();
}

class _TopicActionsForReplyCommentState extends State<TopicActionsForReplyComment> {


  Future addLikeToReplyComment() async {
    await AskAuth().addLike(widget.replyCommentDetail!.id!);
  }

  Future addDisLikeToReplyComment() async {
    await AskAuth().addDisLike(widget.replyCommentDetail!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {},
          child: Row(
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
        ),
        InkWell(
          onTap: () {
            // addLikeToReplyComment();
          },
          child: Row(
            children: [
              SvgPicture.asset("ask/like".toSVG()),
              SizedBox(
                width: 6,
              ),
              Text(
                "",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: HexColor("#75818F")
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            // addDisLikeToReplyComment();
          },
          child: Row(
            children: [
              SvgPicture.asset("ask/dislike".toSVG()),
              SizedBox(
                width: 6,
              ),
              Text(
                "",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: HexColor("#75818F")
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            // androidBottomSheet(
            //   context: context,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       bottomSheetItem(
            //           title: 'Share in chat',
            //           iconData: Icons.send_outlined,
            //           onTap: () async {
            //             Navigator.of(context).pop();
            //             await sendMomentToUserInChat(
            //                 yarnTopic: widget.yarnTopic);
            //           }),
            //     ],
            //   ),
            // );
          },
          child: Row(
            children: [
              SvgPicture.asset("ask/share".toSVG()),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              SvgPicture.asset("ask/send_money".toSVG()),
            ],
          ),
        ),
      ],
    );
  }

  String getCommentCount() {
    if (widget.replyCommentDetail!.replyCount != null &&
        widget.replyCommentDetail!.replyCount != 0) {
      return widget.replyCommentDetail!.replyCount?.toString() ?? "";
    }
    return "";
  }

  String getLikeCount() {
    if (widget.replyCommentDetail!.socialLikes != null &&
        widget.replyCommentDetail!.socialLikes != 0) {
      return widget.replyCommentDetail!.socialLikes?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.replyCommentDetail!.socialDislikes != null &&
        widget.replyCommentDetail!.socialDislikes != 0) {
      return widget.replyCommentDetail!.socialDislikes?.toString() ?? "";
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
      "author_avatar": yarnTopic.authorAvatar,
      "author_name": messageDecoderWithEmoji(yarnTopic.authorName),
      "author_username": yarnTopic.author,
      "title": messageDecoderWithEmoji(yarnTopic.title),
      "description": yarnTopic.body,
      "tags": yarnTopic.tags,
      "image": yarnTopic.media,
      "is_question": yarnTopic.isQuestion,
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
