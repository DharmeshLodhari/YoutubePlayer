import 'dart:convert';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_comment.screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/add_or_edit_yarn_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/comment_details.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_list_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_report_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class YarnOptions extends StatefulWidget {
  Yarn? yarnTopic;
  YarnComment? commentDetail;
  bool? isComment;
  bool? isShareOption;
  Function(Yarn)? onDeleteYarn;
  Function(YarnComment)? onDeleteComment;
  Function(Yarn)? onUpdate;
  Function(YarnComment, bool)? onUpdateMomentComment;
  Function(bool)? minusComment;
  String? momentUsername;
  MomentsModel? moment;
  Function(bool)? reloadView;
  final Function(bool)? callbackUpdateCommentCount;

  YarnOptions(
      {this.yarnTopic,
      this.commentDetail,
      this.isComment = false,
      this.isShareOption = false,
      this.onDeleteYarn,
      this.onUpdate,
      this.minusComment,
      this.onUpdateMomentComment,
      this.momentUsername,
      this.moment,
      this.reloadView,
      this.callbackUpdateCommentCount,
      this.onDeleteComment});

  @override
  State<YarnOptions> createState() => _YarnOptionsState();
}

class _YarnOptionsState extends State<YarnOptions> {
  late YarnDashboardBloc yarnDashboardBloc;
  // late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  bool? pinned = false;

  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            'More options',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            color: HexColor("#EBEDFC"),
          ),
          const SizedBox(
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
      if ((widget.isComment ?? true) && widget.commentDetail != null) {
        widgetList.add(_buildMoreOptionForComments());
      } else {
        widgetList.add(_buildMoreOptionForOwner());
      }
    } else {
      if (widget.commentDetail != null) {
        widgetList.add(_buildMoreOptionForOtherComment());
      } else {
        widgetList.add(_buildMoreOptionForOther());
      }
    }
    return widgetList;
  }

  Widget _buildMoreOptionForComments() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isComments()) ...[
          _buildTile(
              icon: "yarn/delete",
              title: 'Delete',
              subTitle: '',
              onTap: () {
                showDeleteYarnCommentDialog();
              }),
          const SizedBox(
            height: 8,
          ),
          _buildTile(
              icon: "yarn/reply",
              title: 'Reply',
              subTitle: '',
              onTap: () {
                NavigationUtil.pop(context);
                NavigationUtil.push(
                  context,
                  screen: MomentCommentScreen(
                    yarnComment: widget.commentDetail,
                    momentId: widget.commentDetail?.id,
                    minusComment: widget.minusComment,
                  ),
                );
              }),

          ///Do a check for original post author
          if (widget.yarnTopic?.author ==
              widget.commentDetail?.authorUsername) ...[
            const SizedBox(height: 15),

            ///check if comment is pinned
            if (widget.commentDetail?.pinned == true) ...[
              _buildTile(
                  icon: "yarn/unpinned",
                  title: 'Unpin Comment',
                  subTitle: 'Unpin comment from the top of the feed',
                  onTap: () {
                    deletePinnedComment(
                        widget.yarnTopic!.id, widget.commentDetail!.id);
                  }),
            ] else ...[
              _buildTile(
                  icon: "yarn/pinned",
                  title: 'Pin Comment',
                  subTitle: 'Pin comment to the top of the feed',
                  onTap: () {
                    pinComment(widget.yarnTopic!.id, widget.commentDetail!.id);
                  }),
            ]
          ],

          if (widget.moment?.owner == widget.commentDetail?.authorUsername) ...[
            const SizedBox(height: 10),

            // /check if comment is pinned
            if (widget.commentDetail?.pinned == true) ...[
              _buildTile(
                  icon: "yarn/unpinned",
                  title: 'Unpin Comment',
                  subTitle: '',
                  onTap: () {
                    deletePinnedComment(
                        widget.moment!.id, widget.commentDetail!.id,
                        isComment: true);
                  }),
            ] else ...[
              _buildTile(
                  icon: "yarn/pinned",
                  title: 'Pin Comment',
                  subTitle: '',
                  onTap: () {
                    pinComment(widget.moment!.id, widget.commentDetail!.id,
                        isComment: true);
                  }),
            ]
          ]
        ] else ...[
          _buildTile(
              icon: "yarn/report",
              title: 'Report comment',
              subTitle: 'I’m concerned about this post',
              onTap: () {
                Navigator.pop(context);
                NavigationUtil.push(context,
                    screen: AddReportScreen(
                      object: widget.moment != null
                          ? widget.moment!.toJson()
                          : widget.commentDetail!.toJson(),
                      type: "comment",
                      isCommentMoment: false,
                    ));
              }),
        ],
      ],
    );
  }

  Widget _buildMoreOptionForOwner() {
    final DateTime messageCreatedTime =
        DateTime.parse(widget.yarnTopic!.createdAt!).toLocal();

    final DateTime currentTime = DateTime.now();
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
              const Duration(minutes: 5)) ...[
            _buildTile(
                icon: "yarn/bookmark",
                title: 'Edit',
                subTitle: 'Edit yarn',
                onTap: () async {
                  NavigationUtil.push(context,
                      screen: AddOrEditYarn(
                        askCategories: yarnDashboardBloc.yarnCategories,
                        isYarn: true,
                        yarn: widget.yarnTopic,
                        shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
                        passedCategory: '',
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
        const SizedBox(
          height: 15,
        ),
        if (widget.yarnTopic!.saveId != null) ...[
          _buildTile(
            icon: "yarn/delete",
            title: !widget.yarnTopic!.isQuestion
                ? 'Delete Saved Yarn'
                : 'Delete Saved Questions',
            subTitle: 'Deleted this from saved items',
            onTap: () {
              removeSavedYarn(widget.yarnTopic!.saveId.toString());
            },
          ),
          const SizedBox(
            height: 15,
          ),
        ],
        _buildTile(
            icon: "yarn/hide",
            title: widget.yarnTopic!.enableCommenting!
                ? 'Turn off commenting'
                : 'Turn on commenting',
            subTitle: widget.yarnTopic!.enableCommenting!
                ? 'Disable commenting on this post.'
                : 'Enable commenting on this post.',
            onTap: () async {
              final bool mstatus = widget.yarnTopic!.enableCommenting =
                  !widget.yarnTopic!.enableCommenting!;
              Navigator.pop(context);
              await YarnAuth().toggleCommenting(widget.yarnTopic!.id!, mstatus);
              showToast(message: 'Commenting updated..');
            }),
        const SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: "yarn/delete",
            title: 'Delete',
            subTitle: widget.yarnTopic!.isQuestion
                ? 'Delete this question'
                : 'Delete this yarn',
            onTap: () {
              showDeleteYarnDialog();
            }),
      ],
    );
  }

  void showDeleteYarnDialog() {
    showDialogBox(
        context: context,
        actionOneTextColor: blackFont,
        actionOneBgColor: greyBorderColor,
        actionTwoTextColor: white,
        actionTwoBgColor: mateRed,
        title: 'Delete Yarn',
        actionOneText: AppLocalization.of(context)!.discard,
        actionTwoText: AppLocalization.of(context)!.continueMsg,
        description: 'Are you sure you want to delete this yarn?',
        roundedBackgroundIcon: RoundedBackgroundIcon(
          enableMargin: false,
          width: 90,
          height: 90,
          image: Image.asset('assets/images/delete_dialog_icon.png'),
        ),
        rightButtonOnPressed: () => deleteYarnAndQuestion(),
        leftButtonOnPressed: () {
          return Navigator.pop(context);
        });
  }

  void showDeleteYarnCommentDialog() {
    showDialogBox(
        context: context,
        actionOneTextColor: blackFont,
        actionOneBgColor: greyBorderColor,
        actionTwoTextColor: white,
        actionTwoBgColor: mateRed,
        title: 'Delete Comment',
        actionOneText: AppLocalization.of(context)!.discard,
        actionTwoText: AppLocalization.of(context)!.continueMsg,
        description: 'Are you sure you want to delete this comment?',
        roundedBackgroundIcon: RoundedBackgroundIcon(
          enableMargin: false,
          width: 90,
          height: 90,
          image: Image.asset('assets/images/delete_dialog_icon.png'),
        ),
        rightButtonOnPressed: () {
          // Navigator.pop(context);
          return deleteComment();
        },
        leftButtonOnPressed: () {
          return Navigator.pop(context);
        });
  }

  Widget _buildMoreOptionForOther() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.yarnTopic!.saveId != null) ...[
          //if saved yarn is not null
          _buildTile(
            icon: "yarn/delete",
            title: !widget.yarnTopic!.isQuestion
                ? 'Delete Saved Yarn'
                : 'Delete Saved Questions',
            subTitle: 'Deleted this from saved items',
            onTap: () {
              removeSavedYarn(widget.yarnTopic!.saveId.toString());
            },
          ),
        ] else ...[
          //if saved yarn is null
          if (widget.yarnTopic!.authorName != getLoggedInUserName(context)) ...[
            _buildTile(
              icon: "yarn/bookmark",
              title: !widget.yarnTopic!.isQuestion
                  ? 'Save Yarn'
                  : 'Save Questions',
              subTitle: 'Add this to you saved items',
              onTap: () {
                addUserVisibilityOption("saved");
              },
            ),
          ] else ...[
            _buildTile(
              icon: "yarn/delete",
              title: !widget.yarnTopic!.isQuestion
                  ? 'Delete Saved Yarn'
                  : 'Delete Saved Questions',
              subTitle: 'Deleted this from saved items',
              onTap: () {
                removeSavedYarn(widget.yarnTopic!.saveId.toString());
              },
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: "yarn/hide",
              title: 'Not Interested',
              subTitle: 'Not interested in this yarn',
              onTap: () {
                addUserVisibilityOption("not-interested");
              }),
          const SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: "yarn/report",
              title: 'Report yarn',
              subTitle: 'I’m concerned about this yarn',
              onTap: () {
                Navigator.pop(context);
                NavigationUtil.push(context,
                    screen: AddReportScreen(
                      object: widget.yarnTopic!.toJson(),
                      type: "yarn",
                      isCommentMoment: false,
                    ));
              }),
          const SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: "yarn/block",
              title: 'Block Account',
              subTitle: 'Block this account',
              onTap: () {
                final user = CustomerProfile();
                user.userName = widget.yarnTopic!.author;
                user.fullName = widget.yarnTopic!.authorName;
                user.type = "";
                user.nickName = "";

                final Future<bool?> check = blockUserAlert(context, user);
                if (check == true) {
                  widget.reloadView!(true);
                  Navigator.pop(context);
                }
              }),
        ]
      ],
    );
  }

  Widget _buildMoreOptionForOtherComment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (getLoggedInUserName(context) ==
            widget.commentDetail!.authorUsername) ...[
          _buildTile(
              icon: "yarn/delete",
              title: 'Delete',
              subTitle: 'Delete this comment',
              onTap: () {
                showDeleteYarnCommentDialog();
              }),
        ] else ...[
          _buildTile(
              icon: "yarn/report",
              title: 'Report comment',
              subTitle: '',
              onTap: () {
                Navigator.pop(context);
                NavigationUtil.push(context,
                    screen: AddReportScreen(
                      object: widget.moment != null
                          ? widget.moment!.toJson()
                          : widget.commentDetail!.toJson(),
                      type: "comment",
                      isCommentMoment: true,
                    ));
              }),

          const SizedBox(
            height: 8,
          ),
          _buildTile(
              icon: "yarn/reply",
              title: 'Reply',
              subTitle: '',
              onTap: () {
                NavigationUtil.pop(context);
                NavigationUtil.push(
                  context,
                  screen: MomentCommentScreen(
                    yarnComment: widget.commentDetail,
                    momentId: widget.commentDetail?.id,
                    minusComment: widget.minusComment,
                  ),
                );
              }),
          const SizedBox(
            height: 8,
          ),
          // if (getLoggedInUserName(context) == widget.moment?.owner) ...[
          //   if (widget.commentDetail?.pinned == true) ...[
          //     _buildTile(
          //         icon: "yarn/unpinned",
          //         title: 'Unpin Comment',
          //         subTitle: '',
          //         onTap: () {
          //           deletePinnedComment(
          //               widget.moment!.id, widget.commentDetail!.id, isComment: true);
          //         }),
          //   ] else ...[
          //     _buildTile(
          //         icon: "yarn/pinned",
          //         title: 'Pin Comment',
          //         subTitle: '',
          //         onTap: () {
          //           pinComment(widget.moment!.id, widget.commentDetail!.id,
          //               isComment: true);
          //         }),
          //   ]
          // ]

          // SizedBox(
          //   height: 15,
          // ),
          _buildTile(
              icon: "yarn/block",
              title: 'Block Account',
              subTitle: '',
              onTap: () {
                final user = CustomerProfile();
                user.userName = widget.commentDetail!.authorUsername;
                user.fullName = widget.commentDetail!.authorName;
                user.type = "";
                user.nickName = "";

                final Future<bool?> check = blockUserAlert(context, user);
                if (check == true) {
                  // widget.onUpdate!(widget.yarnTopic!);
                  widget.onUpdateMomentComment!(widget.commentDetail!, true);
                  Navigator.pop(context);
                }
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
      String? title,
      String? subTitle,
      GestureTapCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
              child: SvgPicture.asset(
                "$icon".toSVG(),
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
      debugPrint("IS MY YARN QUESTION::: ${widget.yarnTopic!.author}");
      return getLoggedInUserName(context) == widget.yarnTopic!.author;
    } else if (widget.commentDetail != null) {
      debugPrint("IS MY COMMENTS::: ${widget.commentDetail!.authorUsername}");
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
    } else if (widget.commentDetail != null) {
      debugPrint("IS Not MY COMMENT");
      return getLoggedInUserName(context) !=
          widget.commentDetail!.authorUsername;
    }
    debugPrint("NOTHING");
    return false;
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

    final Map<String, dynamic> metaData = yarnTopic.toJson();
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
        message: yarnTopic.isQuestion ? 'Question Shared' : 'Yarn Shared');
  }

  Future addUserVisibilityOption(String status) async {
    final bool? data =
        await YarnAuth().addStatusInPost(widget.yarnTopic!.id!, status);
    if (data != null) {
      if (data) {
        showToast(message: "Status Updated Successfully");
        Navigator.pop(context);
      }
    }
  }

  Future deleteYarnAndQuestion() async {
    final bool isQuestion = widget.yarnTopic!.isQuestion;
    final bool? data =
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

  Future removeSavedYarn(String yarnId) async {
    final bool? data = await YarnAuth().deleteSavedYarn(savedYarnID: yarnId);
    if (data != null && data) {
      showToast(message: "Removed Saved Yarn Successfully");
      if (widget.yarnTopic != null) {
        widget.onDeleteYarn!(widget.yarnTopic!);
      }
      Navigator.pop(context);
    }
  }

  Future deleteComment() async {
    final bool? data =
        await YarnAuth().deleteComment(widget.commentDetail!.id!);
    if (data != null && data) {
      showToast(message: "Comment deleted successfully");
      if (widget.commentDetail != null) {
        widget.onDeleteComment!(widget.commentDetail!);
      }
      Navigator.pop(context);
    }
  }

  Future<void> pinComment(String? yarnId, String? commentId,
      {bool isComment = false}) async {
    final bool? data =
        await YarnAuth().pinComment(yarnId!, commentId!, isComment: isComment);
    if (data != null && data) {
      showToast(message: "Comment pinned successfully");
      Navigator.pop(context);
      if (isComment == false) {
        widget.onUpdate!(widget.yarnTopic!);
      } else {
        widget.onUpdateMomentComment!(widget.commentDetail!, true);
      }
      // Navigator.pop(context);
    } else {
      showToast(message: "Comment pinned failed");
      Navigator.pop(context);
    }
  }

  Future<void> deletePinnedComment(String? yarnId, String? commentId,
      {bool isComment = false}) async {
    final bool? data = await YarnAuth()
        .deletePinnedComment(yarnId!, commentId!, isComment: isComment);
    if (data != null && data) {
      showToast(message: "Pinned Comment remove successfully");

      if (isComment == false) {
        Navigator.pop(context);
        widget.onUpdate!(widget.yarnTopic!);
      } else {
        Navigator.pop(context);
        widget.onUpdateMomentComment!(widget.commentDetail!, false);
      }
    } else {
      showToast(message: "Pinned Comment removal failed");
      Navigator.pop(context);
    }
  }
}
