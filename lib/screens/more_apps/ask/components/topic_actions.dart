import 'dart:convert';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";
import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../messaging/chat/models/ChatConversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';
import '../ask_auth.dart';
import '../ask_detail_screen.dart';

class TopicActions extends StatefulWidget {
  YarnTopic? yarnTopic;

  TopicActions({this.yarnTopic});

  @override
  State<TopicActions> createState() => _TopicActionsState();
}

class _TopicActionsState extends State<TopicActions> {


  Future addLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await AskAuth().addLike(widget.yarnTopic!.id!);
    if (data != null) {
      setState(() {
        widget.yarnTopic!.voteCount = data['vote_count'];
        widget.yarnTopic!.downVoteCount = data['down_vote_count'];
      });
    }
  }

  Future addDisLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await AskAuth().addDisLike(widget.yarnTopic!.id!);
    if (data != null) {
      setState(() {
        widget.yarnTopic!.voteCount = data['vote_count'];
        widget.yarnTopic!.downVoteCount = data['down_vote_count'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: AskDetailScreen(yarnTopic: widget.yarnTopic),
            );
          },
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
            addLikeToYarnAndQuestion();
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
                  color: HexColor("#75818F")
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            addDisLikeToYarnAndQuestion();
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
                  color: HexColor("#75818F")
                ),
              ),
            ],
          ),
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
                            yarnTopic: widget.yarnTopic!);
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
        if(widget.yarnTopic!.enablePayme!)...[
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.SEND_PAYMENT,
                arguments: <String, dynamic>{
                  'recipient': widget.yarnTopic!.author,
                  'isFromProfile': false,
                  'isFromChat': false,
                  'defaultReferenceText':
                  'Payment from  "${truncateString(
                    str: widget.yarnTopic!.title!,
                    lengthToTruncateAt: 8,
                  )}\" yarn'
                },
              );
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
    if (widget.yarnTopic!.numberOfComments != null &&
        widget.yarnTopic!.numberOfComments != 0) {
      return widget.yarnTopic!.numberOfComments?.toString() ?? "";
    }
    return "";
  }

  String getLikeCount() {
    if (widget.yarnTopic!.voteCount != null &&
        widget.yarnTopic!.voteCount != 0) {
      return widget.yarnTopic!.voteCount?.toString() ?? "";
    }
    return "";
  }

  String getDisLikeCount() {
    if (widget.yarnTopic!.downVoteCount != null &&
        widget.yarnTopic!.downVoteCount != 0) {
      return widget.yarnTopic!.downVoteCount?.toString() ?? "";
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
