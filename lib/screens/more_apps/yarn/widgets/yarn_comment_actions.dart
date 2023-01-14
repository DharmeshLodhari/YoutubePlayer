// ignore_for_file: unnecessary_statements

import 'dart:convert';
import 'dart:math';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_detail_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
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
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Expanded(child: _buildActionableList()),
    //     _buildShareButton(),
    //     SizedBox(
    //       width: 18,
    //     ),
    //     _buildPayButton(),
    //     SizedBox(
    //       width: 16,
    //     )
    //   ],
    // );
    return _buildActionableList();
  }

  Widget _buildActionableList() {
    List<Widget> finalActionList = [];

    finalActionList.addAll([
      Expanded(child: _buildCommentButton()),
      Spacer(),
      Expanded(child: _buildLikeButton()),
      Spacer(),
      Expanded(child: _buildDisLikeButton()),
      Spacer(),
      Expanded(child: _buildShareButton()),
      Spacer(),
      Expanded(child: _buildPayButton()),
    ]);

    if (finalActionList.length == 3) {
      finalActionList.add(Expanded(child: Container()));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: finalActionList,
    );
  }

  Widget _buildCommentButton() {
    return Row(
      children: [
        LikeButton(
          size: 15,
          onTap: (_) async {
            if (!widget.isCommentDetail) {
              NavigationUtil.push(
                context,
                screen: YarnCommentDetailScreen(
                  yarn: widget.yarn,
                  yarnComment: widget.comment,
                ),
              );
            }
            return false;
          },
          likeBuilder: (bool isLiked) {
            return SvgPicture.asset(
              "yarn/yarn_comment".toSVG(),
              color: darkGreyYarn,
              height: 15,
              width: 15,
            );
          },
          countBuilder: (_, __, ___) {
            return Text(
              getCommentCount(),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: darkGreyYarn),
            );
          },
        ),
        SizedBox(
          width: 6,
        ),
        Text(getCommentCount())
      ],
    );
  }

  String getCommentReplyCount() {
    if (widget.comment.replyCount != null && widget.comment.replyCount != 0) {
      return widget.comment.replyCount?.toString() ?? "";
    }
    return "";
  }

  Widget _buildLikeButton() {
    return LikeButton(
      size: 15,
      circleColor: CircleColor(start: red, end: red),
      bubblesColor: BubblesColor(
        dotPrimaryColor: red,
        dotSecondaryColor: red,
      ),
      onTap: (isLike) {
        return addLikeToComment();
      },
      likeBuilder: (bool isLiked) {
        return SvgPicture.asset(
          widget.comment.userLike!
              ? "yarn/likeAfter".toSVG()
              : "yarn/likeBefore".toSVG(),
          color: widget.comment.userLike! ? red : darkGreyYarn,
          height: 15,
          width: 15,
        );
      },
      likeCount: getLikeCount(),
      countBuilder: (_, __, ___) {
        int count = getLikeCount();
        return Text(
          count == 0 ? '' : count.toString(),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: widget.comment.userLike! ? red : darkGreyYarn),
        );
      },
    );
  }

  Widget _buildDisLikeButton() {
    return LikeButton(
      size: 15,
      circleColor: CircleColor(start: starYellow, end: starYellow),
      bubblesColor: BubblesColor(
        dotPrimaryColor: starYellow,
        dotSecondaryColor: starYellow,
      ),
      onTap: (isLike) {
        return addDisLikeToComment();
      },
      likeBuilder: (bool isLiked) {
        return SvgPicture.asset(
          widget.comment.userDisLike!
              ? "yarn/unlikeAfter".toSVG()
              : "yarn/unlikeBefore".toSVG(),
          color: widget.comment.userDisLike! ? starYellow : darkGreyYarn,
          height: 13,
          width: 13,
        );
      },
      likeCount: getDisLikeCount(),
      countBuilder: (_, __, ___) {
        int count = getDisLikeCount();
        return Text(
          count == 0 ? '' : count.toString(),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: widget.comment.userDisLike! ? starYellow : darkGreyYarn),
        );
      },
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
    return LikeButton(
        size: 17,
        onTap: (_) async => false,
        likeBuilder: (_) => SvgPicture.asset("yarn/share".toSVG(),
            color: darkGreyYarn, height: 17, width: 17));
  }

  Widget _buildPayButton() {
    bool isPayMeEnable = false;
    if (widget.comment.enablePayMe ?? false) {
      isPayMeEnable = true;
    }
    return LikeButton(
        size: 15,
        onTap: (_) async {
          getLoggedInUserName(context) != widget.comment.authorUsername
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
                        'defaultReferenceText':
                            'Payment from  "${truncateString(
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
                };
          return false;
        },
        likeBuilder: (_) => SvgPicture.asset("yarn/send_money".toSVG(),
            color: darkGreyYarn, height: 17, width: 17));
  }

  // Widget _buildPayButton() {
  //   bool isPayMeEnable = false;
  //   if (widget.comment.enablePayMe ?? false) {
  //     isPayMeEnable = true;
  //   }

  //   return InkWell(
  //     onTap: getLoggedInUserName(context) != widget.comment.authorUsername
  //         ? () {
  //             if (!isPayMeEnable) return;
  //             if (getIt<AppConfigurationBloc>()
  //                     .appConfigurationModel
  //                     ?.enablePayment ==
  //                 true) {
  //               Navigator.of(context).pushNamed(
  //                 Routes.SEND_PAYMENT,
  //                 arguments: <String, dynamic>{
  //                   'recipient': widget.comment.authorUsername!,
  //                   'isFromProfile': false,
  //                   'isFromChat': false,
  //                   'defaultReferenceText': 'Payment from  "${truncateString(
  //                     str: widget.comment.comment!,
  //                     lengthToTruncateAt: 8,
  //                   )}\" comment'
  //                 },
  //               );
  //             } else {
  //               showToast(message: 'Payment not available at the moment');
  //             }
  //           }
  //         : () {
  //             if (!isPayMeEnable) return;
  //             showToast(message: 'You cannot pay yourself');
  //           },
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height: 2,
  //         ),
  //         SvgPicture.asset(
  //           "yarn/send_money".toSVG(),
  //           color: darkGreyYarn,
  //           height: 13,
  //           width: 13,
  //           // color: !isPayMeEnable ? Colors.transparent : null,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String getCommentCount() {
    if (widget.comment.replyCount != null && widget.comment.replyCount != 0) {
      return widget.comment.replyCount?.toString() ?? "";
    }
    return "";
  }

  int getLikeCount() {
    if (widget.comment.likes != null && widget.comment.likes != 0) {
      return widget.comment.likes ?? 0;
    }
    return 0;
  }

  int getDisLikeCount() {
    if (widget.comment.dislike != null &&
        widget.comment.dislike != 0 &&
        widget.comment.userDisLike == true) {
      return widget.comment.dislike ?? 0;
    }
    return 0;
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

  Future<bool> addLikeToComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addLikeComment(widget.comment.id!);
    setState(() {
      widget.comment.userLike = !widget.comment.userLike!;
      widget.comment.userDisLike = false;
    });
    if (data != null) {
      setState(() {
        widget.comment.likes = data['likes'];
        widget.comment.dislike = data['dislikes'];
      });
      return true;
    }
    return false;
  }

  Future<bool> addDisLikeToComment() async {
    Map<String, dynamic>? data =
        await YarnAuth().addDisLikeComment(widget.comment.id!);

    setState(() {
      widget.comment.userDisLike = !widget.comment.userDisLike!;
      widget.comment.userLike = false;
    });
    if (data != null) {
      setState(() {
        widget.comment.likes = data['likes'];
        widget.comment.dislike = data['dislikes'];
      });
      return true;
    }
    return false;
  }
}
