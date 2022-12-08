import 'dart:convert';
import 'dart:math';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

class YarnActions extends StatefulWidget {
  final Yarn yarn;
  YarnActions({required this.yarn});

  @override
  State<YarnActions> createState() => _YarnActionsState();
}

class _YarnActionsState extends State<YarnActions> {
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
          width: 32,
        ),
        _buildPayButton(),
        SizedBox(
          width: 24,
        )
      ],
    );
  }

  Widget _buildActionableList() {
    List<Widget> finalActionList = [];

    if (enableCommenting()) {
      finalActionList.add(Expanded(child: _buildCommentButton()));
    }

    finalActionList.addAll([
      Expanded(child: _buildLikeButton()),
      Expanded(child: _buildDisLikeButton()),
      Expanded(child: _buildRetweetButton()),
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
      onTap: enableCommenting()
          ? () {
              NavigationUtil.push(
                context,
                screen: YarnDetailScreen(yarn: widget.yarn),
              );
            }
          : null,
      child: Row(
        children: [
          SvgPicture.asset(
            "ask/reply".toSVG(),
            color: darkGreyYarn,
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
        addLikeToYarnAndQuestion();
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "ask/like".toSVG(),
            color: darkGreyYarn,
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
        addDisLikeToYarnAndQuestion();
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "ask/dislike".toSVG(),
            color: darkGreyYarn,
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

  Widget _buildRetweetButton() {
    return InkWell(
      onTap: () {
        // addDisLikeToYarnAndQuestion();
      },
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            color: darkGreyYarn,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            "$retweetCount",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
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
                    await sendMomentToUserInChat(yarnTopic: widget.yarn);
                  }),
            ],
          ),
        );
      },
      // child: SvgPicture.asset("ask/share".toSVG()),
      child: Column(
        children: [
          Icon(
            Icons.ios_share_rounded,
            color: darkGreyYarn,
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
    if (widget.yarn.enablePayMe ?? false) {
      isPayMeEnable = true;
    }

    return InkWell(
      onTap: getLoggedInUserName(context) != widget.yarn.author
          ? () {
              if (!isPayMeEnable) return;

              if (getIt<AppConfigurationBloc>()
                      .appConfigurationModel
                      ?.enablePayment ==
                  true) {
                Navigator.of(context).pushNamed(
                  Routes.SEND_PAYMENT,
                  arguments: <String, dynamic>{
                    'recipient': widget.yarn.author,
                    'isFromProfile': false,
                    'isFromChat': false,
                    'defaultReferenceText': 'Payment from  "${truncateString(
                      str: widget.yarn.title!,
                      lengthToTruncateAt: 8,
                    )}\" yarn'
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
            "ask/send_money".toSVG(),
            color: !isPayMeEnable ? Colors.transparent : null,
          ),
        ],
      ),
    );
  }

  String getCommentCount() {
    if (widget.yarn.numberOfComments != null &&
        widget.yarn.numberOfComments != 0) {
      return widget.yarn.numberOfComments?.toString() ?? "";
    }
    return "";
  }

  String getLikeCount() {
    if (widget.yarn.voteCount != null && widget.yarn.voteCount != 0) {
      return widget.yarn.voteCount?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.yarn.downVoteCount != null && widget.yarn.downVoteCount != 0) {
      return widget.yarn.downVoteCount?.toString() ?? "";
    }
    return "";
  }

  bool enableCommenting() {
    return widget.yarn.enableCommenting != null &&
        widget.yarn.enableCommenting!;
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
      "author_is_verified": yarnTopic.authorIsVerified,
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
        message: yarnTopic.isQuestion ? 'Question Shared' : 'Yarn Shared');
  }

  Future addLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await YarnAuth().addLike(widget.yarn.id!);
    if (data != null) {
      setState(() {
        widget.yarn.voteCount = data['vote_count'];
        widget.yarn.downVoteCount = data['down_vote_count'];
      });
    }
  }

  Future addDisLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await YarnAuth().addDisLike(widget.yarn.id!);
    if (data != null) {
      setState(() {
        widget.yarn.voteCount = data['vote_count'];
        widget.yarn.downVoteCount = data['down_vote_count'];
      });
    }
  }
}
