import 'dart:convert';
import 'dart:math';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_detail_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
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
import '../models/Topics/CommentDetails.dart';
import '../yarn_auth.dart';

class YarnCommentActions extends StatefulWidget {
  final YarnComment comment;
  final Yarn yarn;
  final bool isCommentDetail;

  YarnCommentActions({
    required this.comment,
    required this.yarn,
    this.isCommentDetail = false,
  });

  @override
  State<YarnCommentActions> createState() => _YarnCommentActionsState();
}

class _YarnCommentActionsState extends State<YarnCommentActions> {
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
        SizedBox(
          width: 18,
        ),
        _buildPayButton(),
        SizedBox(
          width: 16,
        )
      ],
    );
  }

  Widget _buildActionableList() {
    List<Widget> finalActionList = [];

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
      onTap: () {
        if (!widget.isCommentDetail) {
          NavigationUtil.push(
            context,
            screen: YarnCommentDetailScreen(
              yarn: widget.yarn,
              yarnComment: widget.comment,
            ),
          );
        }
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "yarn/yarn_comment".toSVG(),
            color: darkGreyYarn,
            height: 13,
            width: 13,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            getCommentCount(),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return InkWell(
      onTap: () {
        addLikeToComment();
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "yarn/like".toSVG(),
            color: darkGreyYarn,
            height: 13,
            width: 13,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            getLikeCount(),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
          ),
        ],
      ),
    );
  }

  Widget _buildDisLikeButton() {
    return InkWell(
      onTap: () {
        addDisLikeToComment();
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "yarn/unlike".toSVG(),
            color: darkGreyYarn,
            height: 13,
            width: 13,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            getDisLikeCount(),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
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
      // child: SvgPicture.asset("ask/share".toSVG()),
      child: Column(
        children: [
          SvgPicture.asset(
            "yarn/share".toSVG(),
            color: darkGreyYarn,
            height: 17,
            width: 17,
          ),
          SizedBox(
            height: 2,
          )
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    bool isPayMeEnable = false;
    if (widget.comment.enablePayMe ?? false) {
      isPayMeEnable = true;
    }

    return InkWell(
      onTap: getLoggedInUserName(context) != widget.comment.authorUsername
          ? () {
              if (!isPayMeEnable) return;
              if (getIt<AppConfigurationBloc>()
                      .appConfigurationModel
                      ?.enablePayment ==
                  true) {
                Navigator.of(context).pushNamed(
                  Routes.SEND_PAYMENT,
                  arguments: <String, dynamic>{
                    'recipient': widget.comment.authorUsername!,
                    'isFromProfile': false,
                    'isFromChat': false,
                    'defaultReferenceText': 'Payment from  "${truncateString(
                      str: widget.comment.comment!,
                      lengthToTruncateAt: 8,
                    )}\" comment'
                  },
                );
              } else {
                showToast(message: 'Payment not available at the moment');
              }
            }
          : () {
              if (!isPayMeEnable) return;
              showToast(message: 'You cannot pay yourself');
            },
      child: Column(
        children: [
          SizedBox(
            height: 2,
          ),
          SvgPicture.asset(
            "yarn/send_money".toSVG(),
            color: darkGreyYarn,
            height: 13,
            width: 13,
            // color: !isPayMeEnable ? Colors.transparent : null,
          ),
        ],
      ),
    );
  }

  String getCommentCount() {
    if (widget.comment.replyCount != null && widget.comment.replyCount != 0) {
      return widget.comment.replyCount?.toString() ?? "";
    }
    return "";
  }

  String getLikeCount() {
    if (widget.comment.likes != null && widget.comment.likes != 0) {
      return widget.comment.likes?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.comment.dislike != null && widget.comment.dislike != 0) {
      return widget.comment.dislike?.toString() ?? "";
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
        message: yarnTopic.isQuestion ? 'Yarn Shared' : 'Question Shared');
  }

  Future addLikeToComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addLikeComment(widget.comment.id!);
    if (data != null) {
      setState(() {
        widget.comment.likes = data['likes'];
        widget.comment.dislike = data['dislikes'];
      });
    }
  }

  Future addDisLikeToComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addDisLikeComment(widget.comment.id!);
    if (data != null) {
      setState(() {
        widget.comment.likes = data['likes'];
        widget.comment.dislike = data['dislikes'];
      });
    }
  }
}
