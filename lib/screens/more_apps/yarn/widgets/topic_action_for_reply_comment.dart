import 'dart:convert';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

import '../../../../data/state_notifier.dart';
import '../../../../locator.dart';
import '../../../../routes/route_constants.dart';
import '../../../../services/app_config_bloc.dart';
import '../../../../utils/util.dart';
import '../../messaging/chat/models/ChatConversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';
import '../yarn_auth.dart';

class TopicActionsForReplyComment extends StatefulWidget {
  YarnComment? replyCommentDetail;
  TopicActionsForReplyComment({this.replyCommentDetail});

  @override
  State<TopicActionsForReplyComment> createState() =>
      _TopicActionsForReplyCommentState();
}

class _TopicActionsForReplyCommentState
    extends State<TopicActionsForReplyComment> {
  Future addLikeToReplyComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addLikeComment(widget.replyCommentDetail!.id!);
    if (data != null) {
      setState(() {
        widget.replyCommentDetail!.likes = data['likes'];
        widget.replyCommentDetail!.dislike = data['dislikes'];
      });
    }
  }

  Future addDisLikeToReplyComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addDisLikeComment(widget.replyCommentDetail!.id!);
    if (data != null) {
      setState(() {
        widget.replyCommentDetail!.likes = data['likes'];
        widget.replyCommentDetail!.dislike = data['dislikes'];
      });
    }
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
                    color: HexColor("#75818F")),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            addLikeToReplyComment();
          },
          child: Row(
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
                    color: HexColor("#75818F")),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            addDisLikeToReplyComment();
          },
          child: Row(
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
                    color: HexColor("#75818F")),
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
        if (getLoggedInUserName(context) !=
            widget.replyCommentDetail!.authorUsername) ...[
          InkWell(
            onTap: getLoggedInUserName(context) !=
                    widget.replyCommentDetail!.authorUsername
                ? () {
                    if (getIt<AppConfigurationBloc>()
                            .appConfigurationModel
                            ?.enablePayment ==
                        true) {
                      Navigator.of(context).pushNamed(
                        Routes.SEND_PAYMENT,
                        arguments: <String, dynamic>{
                          'recipient':
                              widget.replyCommentDetail!.authorUsername!,
                          'isFromProfile': false,
                          'isFromChat': false,
                          'defaultReferenceText':
                              'Payment from  "${truncateString(
                            str: widget.replyCommentDetail!.comment!,
                            lengthToTruncateAt: 8,
                          )}\" comment'
                        },
                      );
                    } else {
                      showToast(message: 'Payment not available at the moment');
                    }
                  }
                : () {
                    showToast(message: 'You cannot pay yourself');
                  },
            child: Row(
              children: [
                SvgPicture.asset("ask/send_money".toSVG()),
              ],
            ),
          )
        ],
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
    if (widget.replyCommentDetail!.likes != null &&
        widget.replyCommentDetail!.likes != 0) {
      return widget.replyCommentDetail!.likes?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.replyCommentDetail!.dislike != null &&
        widget.replyCommentDetail!.dislike != 0) {
      return widget.replyCommentDetail!.dislike?.toString() ?? "";
    }
    return "";
  }

  Future<void> sendMomentToUserInChat({required Yarn yarnTopic}) async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(recipientUser: recipient!, yarnTopic: yarnTopic);
    });
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required Yarn yarnTopic,
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
