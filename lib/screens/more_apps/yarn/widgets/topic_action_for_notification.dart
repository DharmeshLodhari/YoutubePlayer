import 'dart:convert';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

import '../../../../data/state_notifier.dart';
import '../../../../utils/util.dart';
import '../../messaging/chat/models/chat_conversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';

class TopicActionsForNotification extends StatefulWidget {
  TopicActionsForNotification();

  @override
  State<TopicActionsForNotification> createState() =>
      _TopicActionsForNotificationState();
}

class _TopicActionsForNotificationState
    extends State<TopicActionsForNotification> {
  // Future addLikeToComment() async {
  //   Map<String, dynamic>? data = await AskAuth().addLikeComment(widget.commentDetail!.id!);
  //   if (data != null) {
  //     setState(() {
  //       widget.commentDetail!.likes = data['likes'];
  //       widget.commentDetail!.dislike = data['dislikes'];
  //     });
  //   }
  // }
  //
  // Future addDisLikeToComment() async {
  //   Map<String, dynamic>? data = await AskAuth().addDisLikeComment(widget.commentDetail!.id!);
  //   if (data != null) {
  //     setState(() {
  //       widget.commentDetail!.likes = data['likes'];
  //       widget.commentDetail!.dislike = data['dislikes'];
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCommentButton(),
        _buildLikeButton(),
        _buildDisLike(),
        _buildShareButton(),
        _buildPayButton(),
      ],
    );
  }

  Widget _buildCommentButton() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          SvgPicture.asset("ask/reply".toSVG()),
          const SizedBox(
            width: 6,
          ),
          Text(
            getCommentCount(),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return InkWell(
      onTap: () {
        // addLikeToComment();
      },
      child: Row(
        children: [
          SvgPicture.asset("ask/like".toSVG()),
          const SizedBox(
            width: 6,
          ),
          Text(
            getLikeCount(),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")),
          ),
        ],
      ),
    );
  }

  Widget _buildDisLike() {
    return InkWell(
      onTap: () {
        // addDisLikeToComment();
      },
      child: Row(
        children: [
          SvgPicture.asset("ask/dislike".toSVG()),
          const SizedBox(
            width: 6,
          ),
          Text(
            getDisLikeCount(),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: HexColor("#75818F")),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
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
    );
  }

  Widget _buildPayButton() {
    return InkWell(
      // onTap: getLoggedInUserName(context) != widget.commentDetail!.authorUsername ? () {
      //   if (getIt<AppConfigurationBloc>()
      //       .appConfigurationModel
      //       ?.enablePayment ==
      //       true) {
      //     Navigator.of(context).pushNamed(
      //       Routes.SEND_PAYMENT,
      //       arguments: <String, dynamic>{
      //         'recipient': widget.commentDetail!.authorUsername!,
      //         'isFromProfile': false,
      //         'isFromChat': false,
      //         'defaultReferenceText':
      //         'Payment from  "${truncateString(
      //           str: widget.commentDetail!.comment!,
      //           lengthToTruncateAt: 8,
      //         )}\" comment'
      //       },
      //     );
      //   } else {
      //     showToast(message: 'Payment not available at the moment');
      //   }
      // } : () {
      //   showToast(message: 'You cannot pay yourself');
      // },
      child: Row(
        children: [
          SvgPicture.asset("yarn/send_money".toSVG()),
        ],
      ),
    );
  }

  String getCommentCount() {
    // if (widget.commentDetail!.replyCount != null &&
    //     widget.commentDetail!.replyCount != 0) {
    //   return widget.commentDetail!.replyCount?.toString() ?? "";
    // }
    return "";
  }

  String getLikeCount() {
    // if (widget.commentDetail!.likes != null &&
    //     widget.commentDetail!.likes != 0) {
    //   return widget.commentDetail!.likes?.toString() ?? "";
    // }
    return "";
  }

  String getDisLikeCount() {
    // if (widget.commentDetail!.dislike != null &&
    //     widget.commentDetail!.dislike != 0) {
    //   return widget.commentDetail!.dislike?.toString() ?? "";
    // }
    return "";
  }

  Future<void> sendMomentToUserInChat({required Yarn yarnTopic}) async {
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    for (var recipient in listOfRecipient) {
      addMomentPostToChat(recipientUser: recipient!, yarnTopic: yarnTopic);
    }
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required Yarn yarnTopic,
    String? url,
  }) async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    final Map<String, dynamic> metaData = {
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

    final Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": const Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'yarn',
      "kind": "yarn",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(
        message: yarnTopic.isQuestion ? 'Yarn Shared' : 'Question Shared');
  }
}
