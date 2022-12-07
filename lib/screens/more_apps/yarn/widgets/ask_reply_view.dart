import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/topic_action_for_reply_comment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/CommentDetails.dart';
import 'ask_options.dart';

class AskReplyView extends StatelessWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;
  CommentDetails? replyCommentDetail;

  AskReplyView({this.yarnTopic, this.replyCommentDetail, this.commentDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            _buildUserInfoRow(context: context),
          ],
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
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                    arguments: replyCommentDetail!.authorAvatar!);
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: replyCommentDetail!.authorAvatar!,
                    fit: BoxFit.cover,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
            ),
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
                  "searchedUserName": replyCommentDetail!.authorUsername!
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userNameWithVerifiedIcon(
                      name: replyCommentDetail!.authorName!, isVerified: false),
                  Text(
                    "@${replyCommentDetail!.authorUsername!}",
                    style: TextStyle(fontSize: 10, color: HexColor("#3F61DB")),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 3,
            ),
            _buildRepliedText(),
            SizedBox(
              height: 15,
            ),
            _buildCommentDescription(),
            SizedBox(
              height: 10,
            ),
            _buildTopActions(),
          ],
        )),
        InkWell(
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
                  child: AskOptions(
                    commentDetail: replyCommentDetail,
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
      ],
    );
  }

  Widget _buildRepliedText() {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: "Replying to ",
          style: TextStyle(fontSize: 10, color: HexColor("#030F36")),
        ),
        TextSpan(
          text: "@${commentDetail!.authorUsername}",
          style: TextStyle(fontSize: 10, color: HexColor("#3F61DB")),
        ),
      ]),
    );
  }

  Widget _buildCommentDescription() {
    return RichTextForTitle(
      description:
          messageDecoderWithEmoji(replyCommentDetail!.comment ?? '') ?? '',
    );
    // return Text(
    //   messageDecoderWithEmoji(replyCommentDetail!.comment!)!,
    //   maxLines: 30,
    //   style: TextStyle(
    //     color: blackFont,
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //   ),
    // );
  }

  Widget _buildTopActions() {
    return TopicActionsForReplyComment(
      replyCommentDetail: replyCommentDetail!,
    );
  }
}
