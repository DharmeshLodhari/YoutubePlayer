import 'package:flutter/material.dart';

import '../../../../utils/navigation_util.dart';
import '../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../utils/util.dart';
import '../ask_report_screen.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/YarnTopic.dart';
import '../yarn_auth.dart';

class AskOptions extends StatefulWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;
  bool? isComment;
  AskOptions({this.yarnTopic, this.commentDetail, this.isComment = false});
  @override
  State<AskOptions> createState() => _AskOptionsState();
}

class _AskOptionsState extends State<AskOptions> {
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
    bool isQuestion = widget.yarnTopic!.isQuestion!;
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
          if (isMyYarnQuestion()) ...[
            _buildMoreOptionForOwner()
          ] else ...[
            _buildMoreOptionForOther()
          ],
          if (widget.isComment! && widget.commentDetail != null) ...[
            _buildMoreOptionForComments()
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
        if (widget.yarnTopic!.isQuestion!) ...[
          _buildTile(
              icon: Icons.verified_outlined,
              title: 'Accept Answer ',
              subTitle:
                  'Once you accept this answer, your bounty \nreward will be sent to this user.'),
        ] else ...[
          if (currentTime.difference(messageCreatedTime) <
              Duration(minutes: 1)) ...[
            _buildTile(
                icon: SlydoAppIconNew.edit_post,
                iconSize: 18,
                width: 12,
                title: 'Edit',
                subTitle: 'Edit yarn'),
          ]
        ],
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: SlydoAppIconNew.hide_commenting,
            iconSize: 18,
            width: 12,
            title: 'Turn off commenting',
            subTitle: 'Disable commenting on this post.'),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: SlydoAppIconNew.delete_post,
            iconSize: 18,
            width: 12,
            title: 'Delete',
            subTitle: widget.yarnTopic!.isQuestion!
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
          icon: SlydoAppIconNew.save_post,
          iconSize: 18,
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
            icon: SlydoAppIconNew.hide_post,
            iconSize: 18,
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
            icon: Icons.report_gmailerrorred_rounded,
            title: 'Not Interested',
            subTitle: 'Not interested in this yarn',
            onTap: () {
              addUserVisibilityOption("not-interested");
            }),
        SizedBox(
          height: 15,
        ),
        _buildTile(
            icon: Icons.report_gmailerrorred_rounded,
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
              icon: SlydoAppIconNew.delete_post,
              iconSize: 18,
              title: 'Delete',
              subTitle: 'Delete this comment',
              onTap: () {
                deleteComment();
              }),
        ] else ...[
          _buildTile(
              icon: Icons.report_gmailerrorred_rounded,
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

  Widget _buildTile(
      {IconData? icon,
      double? iconSize,
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
            Icon(
              icon,
              size: iconSize ?? 24,
            ),
            SizedBox(
              width: width ?? 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subTitle!,
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
}
