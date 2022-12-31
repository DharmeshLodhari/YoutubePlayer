import 'dart:convert';

import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
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
import '../add_or_edit_yarn_screen.dart';
import '../ask_report_screen.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/yarn_model.dart';
import '../utils/utils.dart';
import '../yarn_auth.dart';
import '../yarn_dashboard_bloc.dart';
import '../yarn_list_screen.dart';

class YarnOptions extends StatefulWidget {
  Yarn? yarnTopic;
  YarnComment? commentDetail;
  bool? isComment;
  bool? isShareOption;
  Function(Yarn)? onDeleteYarn;
  Function(YarnComment)? onDeleteComment;
  Function(Yarn)? onUpdate;

  YarnOptions(
      {this.yarnTopic,
      this.commentDetail,
      this.isComment = false,
      this.isShareOption = false,
      this.onDeleteYarn,
      this.onUpdate,
      this.onDeleteComment});
  @override
  State<YarnOptions> createState() => _YarnOptionsState();
}

class _YarnOptionsState extends State<YarnOptions> {
  late YarnDashboardBloc yarnDashboardBloc;
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;

  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

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
      if (widget.yarnTopic != null) {
        widget.onDeleteYarn!(widget.yarnTopic!);
      }
      Navigator.pop(context);
    }
  }

  Future deleteComment() async {
    bool? data = await YarnAuth().deleteComment(widget.commentDetail!.id!);
    if (data != null && data) {
      showToast(message: "Comment deleted successfully");
      if (widget.commentDetail != null) {
        widget.onDeleteComment!(widget.commentDetail!);
      }
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    super.initState();
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
          ..._buildMoreOptionList(),
        ],
      ),
    );
  }

  List<Widget> _buildMoreOptionList() {
    final List<Widget> widgetList = [];
    if (isMyYarnQuestion()) {
      debugPrint("IS MY YARN QUESTION TRUE");
      if ((widget.isComment ?? true) && widget.commentDetail != null) {
        widgetList.add(_buildMoreOptionForComments());
      } else {
        widgetList.add(_buildMoreOptionForOwner());
      }
    } else {
      widgetList.add(_buildMoreOptionForOther());
    }
    return widgetList;
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
              Duration(minutes: 5)) ...[
            _buildTile(
                icon: "yarn/bookmark",
                width: 12,
                title: 'Edit',
                subTitle: 'Edit yarn',
                onTap: () async {
                  NavigationUtil.push(context,
                      screen: AddOrEditYarn(
                        askCategories: yarnDashboardBloc.yarnCategories,
                        isYarn: true,
                        yarn: widget.yarnTopic,
                        shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
                      )).then((value) {
                    debugPrint("THEN VALUE===$value");
                    if (value != null) {
                      if (value[0] == Types.Yarn) {
                        widget.onUpdate!(value[1]);
                        Navigator.of(context).pop();
                        // updateCurrentAskTapOnHome(index: 0);
                        // _pageViewController.jumpToPage(0);
                        // topicViewStateKey.currentState?.onRefresh();
                      }
                      // Navigator.of(context).pop();
                    }
                  });
                }),
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
          title: !widget.yarnTopic!.isQuestion ? 'Save Yarn' : 'Save Questions',
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
            title: 'Not Interested',
            subTitle: !widget.yarnTopic!.isQuestion
                ? 'Not interested in this yarn'
                : 'Not interested in this type of question',
            onTap: () {
              addUserVisibilityOption("not-interested");
            }),
        SizedBox(
          height: 15,
        ),
        // _buildTile(
        //     icon: "yarn/not_interested",
        //     title: 'Not Interested',
        //     subTitle: 'Not interested in this yarn',
        //     onTap: () {
        //       addUserVisibilityOption("not-interested");
        //     }),
        // SizedBox(
        //   height: 15,
        // ),
        _buildTile(
            icon: "yarn/report",
            title: !widget.yarnTopic!.isQuestion
                ? 'Report yarn'
                : "Report question",
            subTitle: !widget.yarnTopic!.isQuestion
                ? 'I’m concerned about this yarn'
                : 'I’m concerned about this question',
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

  // Widget _buildMoreOptionForShare() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       _buildTile(
  //         icon: "yarn/copy",
  //         title: "Copy Link",
  //         width: 12,
  //         onTap: () {}
  //       ),
  //       _buildTile(
  //           icon: "yarn/send",
  //           title: "Send To",
  //           width: 12,
  //           onTap: () async {
  //             Navigator.of(context).pop();
  //             await sendMomentToUserInChat(yarnTopic: widget.yarnTopic!);
  //           }
  //       ),
  //       _buildTile(
  //           icon: "yarn/share",
  //           title: "Share Via",
  //           width: 12,
  //           onTap: () {}
  //       ),
  //       _buildTile(
  //           icon: "yarn/report",
  //           title: "Repost to Feed",
  //           width: 12,
  //           onTap: () {}
  //       ),
  //     ],
  //   );
  // }

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
    if (widget.yarnTopic != null) {
      debugPrint("IS MY YARN QUESTION");
      return getLoggedInUserName(context) == widget.yarnTopic!.author;
    } else if (widget.commentDetail != null) {
      debugPrint("IS MY COMMENTS");
      return getLoggedInUserName(context) ==
          widget.commentDetail!.authorUsername;
    }
    debugPrint("NOTHING");
    return false;
  }

  bool isComments() {
    if (widget.commentDetail != null) {
      debugPrint("IS MY COMMENTS");
      return getLoggedInUserName(context) ==
          widget.commentDetail!.authorUsername;
    } else if (widget.yarnTopic != null) {
      debugPrint("IS MY YARN QUESTION");
      return getLoggedInUserName(context) == widget.yarnTopic!.author;
    }
    debugPrint("NOTHING");
    return false;
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
