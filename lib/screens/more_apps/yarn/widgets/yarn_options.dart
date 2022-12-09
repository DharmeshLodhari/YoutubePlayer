import 'dart:convert';

import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/state_notifier.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../messaging/chat/models/ChatConversation.dart';
import '../../messaging/chat/share_in_chat/ShareInChat.dart';
import '../ask_report_screen.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/YarnTopic.dart';
import '../yarn_auth.dart';

class YarnOptions extends StatefulWidget {
  Yarn? yarnTopic;
  YarnComment? commentDetail;
  bool? isComment;
  bool? isShareOption;
  YarnOptions({this.yarnTopic, this.commentDetail, this.isComment = false, this.isShareOption = false});
  @override
  State<YarnOptions> createState() => _YarnOptionsState();
}

class _YarnOptionsState extends State<YarnOptions> {
  Future addUserVisibilityOption(String status) async {
    bool? data =
        await YarnAuth().addStatusInPost(widget.yarnTopic!.id!, status);
    if (data != null) {
      if (data) {
        showToast(message: "Status Updated Successfully");
        Navigator.pop(context);
      }
    }
  }

  Future deleteYarnAndQuestion() async {
    bool isQuestion = widget.yarnTopic!.isQuestion;
    bool? data =
        await YarnAuth().deleteSingleTopics(yarnId: widget.yarnTopic!.id);
    if (data != null && data) {
      showToast(
          message: isQuestion
              ? "Question Deleted Successfully"
              : "Yarn Deleted Successfully");
      Navigator.pop(context);
    }
  }

  Future deleteComment() async {
    bool? data = await YarnAuth().deleteComment(widget.commentDetail!.id!);
    if (data != null && data) {
      showToast(message: "Comment deleted successfully");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return _buildMoreOption();
  }

  Widget _buildMoreOption() {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'More options',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            color: HexColor("#EBEDFC"),
          ),
          SizedBox(
            height: 15,
          ),
          if (isMyYarnQuestion() && !(widget.isShareOption ?? false) && (!(widget.isComment ?? false) && widget.commentDetail != null)) ...[
            _buildMoreOptionForOwner()
          ] else ...[
            if ((widget.isComment ?? false) && widget.commentDetail != null)...[
              _buildMoreOptionForComments()
            ] else if (widget.isShareOption ?? false)...[
              _buildMoreOptionForShare()
            ] else...[
              _buildMoreOptionForOther()
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildMoreOptionForOwner() {
    DateTime messageCreatedTime =
        DateTime.parse(widget.yarnTopic!.createdAt!).toLocal();

    DateTime currentTime = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.yarnTopic!.isQuestion) ...[
          _buildTile(
              icon: "yarn/bookmark",
              title: 'Accept Answer ',
              subTitle:
                  'Once you accept this answer, your bounty \nreward will be sent to this user.'),
        ] else ...[
          if (currentTime.difference(messageCreatedTime) <
              Duration(minutes: 1)) ...[
            _buildTile(
                icon: "yarn/bookmark",
                width: 12,
                title: 'Edit',
                subTitle: 'Edit yarn'),
          ]
        ],
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/hide",
            width: 12,
            title: 'Turn off commenting',
            subTitle: 'Disable commenting on this post.'),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/delete",
            width: 12,
            title: 'Delete',
            subTitle: widget.yarnTopic!.isQuestion
                ? 'Delete this question'
                : 'Delete this yarn',
            onTap: () {
              deleteYarnAndQuestion();
            }),
      ],
    );
  }

  Widget _buildMoreOptionForOther() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTile(
          icon: "yarn/bookmark",
          width: 12,
          title: 'Save yarn/question',
          subTitle: 'Add this to you saved items',
          onTap: () {
            addUserVisibilityOption("saved");
          },
        ),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/hide",
            width: 12,
            title: 'Hide yarn',
            subTitle: 'See fewer posts like this',
            onTap: () {
              addUserVisibilityOption("hidden");
            }),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/not_interested",
            title: 'Not Interested',
            subTitle: 'Not interested in this yarn',
            onTap: () {
              addUserVisibilityOption("not-interested");
            }),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/report",
            title: 'Report yarn',
            subTitle: 'I’m concerned about this post',
            onTap: () {
              Navigator.pop(context);
              NavigationUtil.push(context,
                  screen: AddReportScreen(
                    object: widget.yarnTopic!.toJson(),
                    type: "yarn",
                  ));
            }),
      ],
    );
  }

  Widget _buildMoreOptionForComments() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isComments()) ...[
          _buildTile(
              icon: "yarn/delete",
              title: 'Delete',
              subTitle: 'Delete this comment',
              onTap: () {
                deleteComment();
              }),
        ] else ...[
          _buildTile(
              icon: "yarn/report",
              title: 'Report comment',
              subTitle: 'I’m concerned about this post',
              onTap: () {
                Navigator.pop(context);
                NavigationUtil.push(context,
                    screen: AddReportScreen(
                      object: widget.commentDetail!.toJson(),
                      type: "comment",
                    ));
              }),
        ],
      ],
    );
  }

  Widget _buildMoreOptionForShare() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTile(
          icon: "yarn/copy",
          title: "Copy Link",
          width: 12,
          onTap: () {}
        ),
        _buildTile(
            icon: "yarn/send",
            title: "Send To",
            width: 12,
            onTap: () async {
              Navigator.of(context).pop();
              await sendMomentToUserInChat(yarnTopic: widget.yarnTopic!);
            }
        ),
        _buildTile(
            icon: "yarn/share",
            title: "Share Via",
            width: 12,
            onTap: () {}
        ),
        _buildTile(
            icon: "yarn/report",
            title: "Repost to Feed",
            width: 12,
            onTap: () {}
        ),
      ],
    );
  }

  Widget _buildTile(
      {String? icon,
      double? width,
      String? title,
      String? subTitle,
      GestureTapCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              "$icon".toSVG(),
              height: 20,
              width: 20,
            ),
            // Icon(
            //   icon,
            //   size: iconSize ?? 24,
            // ),
            SizedBox(
              width: width ?? 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subTitle ?? "",
                  style: TextStyle(
                    color: HexColor("#75818F"),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool isMyYarnQuestion() {
    return getLoggedInUserName(context) == widget.yarnTopic!.author;
  }

  bool isComments() {
    return getLoggedInUserName(context) == widget.commentDetail!.authorUsername;
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

    Map<String, dynamic> metaData = yarnTopic.toJson();
    // {
    //   "id": yarnTopic.id,
    //   "author_avatar": yarnTopic.authorAvatar,
    //   "author_name": messageDecoderWithEmoji(yarnTopic.authorName),
    //   "author_username": yarnTopic.author,
    //   "title": messageDecoderWithEmoji(yarnTopic.title),
    //   "description": yarnTopic.body,
    //   "tags": yarnTopic.tags,
    //   "image": yarnTopic.media,
    //   "is_question": yarnTopic.isQuestion,
    //   "author_is_verified": yarnTopic.authorIsVerified,
    // };

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
}
