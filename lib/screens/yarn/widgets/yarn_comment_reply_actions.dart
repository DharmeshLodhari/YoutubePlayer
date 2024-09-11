import 'dart:convert';
import 'dart:math';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/yarn/models/Topics/comment_details.dart';
import 'package:Slydo/screens/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

class YarnCommentReplyActions extends StatefulWidget {
  final YarnComment? replyCommentDetail;
  const YarnCommentReplyActions({super.key, this.replyCommentDetail});

  @override
  State<YarnCommentReplyActions> createState() =>
      _YarnCommentReplyActionsState();
}

class _YarnCommentReplyActionsState extends State<YarnCommentReplyActions> {
  Future addLikeToReplyComment() async {
    final Map<String, dynamic>? data =
        await YarnAuth().addLikeComment(widget.replyCommentDetail!.id!);
    if (data != null) {
      setState(() {
        widget.replyCommentDetail!.likes = data['likes'];
        widget.replyCommentDetail!.dislike = data['dislikes'];
      });
    }
  }

  Future addDisLikeToReplyComment() async {
    final Map<String, dynamic>? data =
        await YarnAuth().addDisLikeComment(widget.replyCommentDetail!.id!);
    if (data != null) {
      setState(() {
        widget.replyCommentDetail!.likes = data['likes'];
        widget.replyCommentDetail!.dislike = data['dislikes'];
      });
    }
  }

  int retweetCount = 1;
  @override
  void initState() {
    retweetCount = Random().nextInt(200);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildActionableList()),
        _buildShareButton(),
        if (getLoggedInUserName(context) !=
            widget.replyCommentDetail!.authorUsername) ...[_buildPayButton()],
      ],
    );
  }

  Widget _buildActionableList() {
    final List<Widget> finalActionList = [];

    finalActionList.addAll([
      Expanded(child: _buildCommentButton()),
      Expanded(child: _buildLikeButton()),
      Expanded(child: _buildDisLikeButton()),
      //Expanded(child: _buildRetweetButton()),
    ]);

    if (finalActionList.length == 3) {
      finalActionList.add(Expanded(child: Container()));
    }
    return Row(
      children: finalActionList,
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
        addLikeToReplyComment();
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

  Widget _buildDisLikeButton() {
    return InkWell(
      onTap: () {
        addDisLikeToReplyComment();
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

  // Widget _buildRetweetButton() {
  //   return InkWell(
  //     onTap: () {
  //       // addDisLikeToYarnAndQuestion();
  //     },
  //     child: Row(
  //       children: [
  //         SvgPicture.asset(
  //           "yarn/re_share".toSVG(),
  //           color: darkGreyYarn,
  //           height: 13,
  //           width: 13,
  //         ),
  //         SizedBox(
  //           width: 6,
  //         ),
  //         Text(
  //           "$retweetCount",
  //           style: TextStyle(
  //               fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
          SvgPicture.asset(
            "ask/share".toSVG(),
            height: 17,
            width: 17,
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return InkWell(
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
                    'recipient': widget.replyCommentDetail!.authorUsername!,
                    'isFromProfile': false,
                    'isFromChat': false,
                    'defaultReferenceText': 'Payment from  "${truncateString(
                      str: widget.replyCommentDetail!.comment!,
                      lengthToTruncateAt: 8,
                    )}" comment'
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
          SvgPicture.asset("yarn/send_money".toSVG()),
        ],
      ),
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
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    // debugPrint("Selected users = ${listOfRecipient.length}");

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
