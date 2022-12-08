import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_reply_view.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../models/Topics/CommentDetails.dart';
import '../widgets/yarn_options.dart';
import '../yarn_comment_detail_screen.dart';

class YarnCommentTile extends StatelessWidget {
  final Yarn yarn;
  final YarnComment yarnComment;
  List<YarnComment>? commentDetailsList = [];
  final bool? openReply;

  YarnCommentTile({
    required this.yarn,
    required this.yarnComment,
    this.commentDetailsList,
    this.openReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: YarnCommentDetailScreen(
            yarn: yarn,
            yarnComment: yarnComment,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: 12),
        child: Column(
          children: [
            _buildUserInfoRow(context: context),
            SizedBox(
              height: 15,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 1,
                    color: greySecondaryYarn,
                    height: double.infinity,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommentDescription(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildTopActions(context: context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildReplyCommentView(context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar({required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: yarnComment.authorAvatar!);
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: yarnComment.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow({required BuildContext context}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildUserAvatar(context: context),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                  "searchedUserName": yarnComment.authorUsername!
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    messageDecoderWithEmoji(yarnComment.authorName ?? "") ?? "",
                    style: TextStyle(fontSize: 12, color: yarnBlack),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "@${yarnComment.authorUsername!}",
                    style: TextStyle(fontSize: 12, color: yarnBlack),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  ClipOval(
                    child: Container(
                      height: 4,
                      width: 4,
                      color: yarnBlack,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      '${getGetYarnQuestionDateTime(yarnComment.createdAt!)}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 12,
                          color: yarnBlack,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 3,
            ),
            _buildRepliedText(),
          ],
        )),
        isComments(context)
            ? InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        child: YarnOptions(
                          commentDetail: yarnComment,
                          isComment: true,
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF4B545A),
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget _buildRepliedText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Replying to ",
          style: TextStyle(fontSize: 12, color: yarnBlack),
        ),
        Expanded(
          child: userNameWithVerifiedIcon(
              name: "@${yarn.author}",
              isVerified: false,
              textStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: navyBlue)),
        ),
      ],
    );
  }

  Widget _buildCommentDescription() {
    return RichTextForTitle(
      description: messageDecoderWithEmoji(yarnComment.comment ?? '') ?? '',
    );
    // return Text(
    //   messageDecoderWithEmoji(commentDetail!.comment!)!,
    //   maxLines: 30,
    //   style: TextStyle(
    //     color: blackFont,
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //   ),
    // );
  }

  Widget _buildTopActions({required BuildContext context}) {
    return YarnCommentActions(
      comment: yarnComment,
      yarn: yarn,
    );
  }

  Widget _buildReplyCommentView({required BuildContext context}) {
    if (openReply! &&
        commentDetailsList!.isNotEmpty &&
        commentDetailsList != null) {
      return Column(
        children: commentDetailsList!.map((replyCommentDetail) {
          return InkWell(
            onTap: () {
              NavigationUtil.push(
                context,
                screen: YarnCommentDetailScreen(
                  yarn: yarn,
                  yarnComment: replyCommentDetail,
                ),
              );
            },
            child: AskReplyView(
              yarnTopic: yarn,
              commentDetail: yarnComment,
              replyCommentDetail: replyCommentDetail,
            ),
          );
        }).toList(),
      );
    }
    return SizedBox();
  }

  bool isComments(BuildContext context) {
    DateTime messageCreatedTime =
        DateTime.parse(yarnComment.createdAt!).toLocal();

    DateTime currentTime = DateTime.now();
    if (getLoggedInUserName(context) == yarnComment.authorUsername) {
      if (currentTime.difference(messageCreatedTime) < Duration(minutes: 3)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
