import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_reply_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/CommentDetails.dart';
import 'yarn_options.dart';

class AskReplyView extends StatelessWidget {
  final Yarn? yarnTopic;
  final YarnComment? commentDetail;
  final YarnComment? replyCommentDetail;

  AskReplyView({this.yarnTopic, this.replyCommentDetail, this.commentDetail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          _buildUserInfoRow(context: context),
        ],
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: replyCommentDetail!.authorAvatar!,
                    fit: BoxFit.cover,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
            ),
            const SizedBox(
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
            const SizedBox(
              height: 3,
            ),
            _buildRepliedText(),
            const SizedBox(
              height: 15,
            ),
            _buildCommentDescription(),
            const SizedBox(
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  child: YarnOptions(
                    commentDetail: replyCommentDetail,
                    isComment: true,
                  ),
                );
              },
            );
          },
          child: const Icon(
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
          text: "@${replyCommentDetail!.authorUsername}",
          style: TextStyle(fontSize: 10, color: HexColor("#3F61DB")),
        ),
      ]),
    );
  }

  Widget _buildCommentDescription() {
    return RichTextForTitle(
      description: replyCommentDetail!.comment ?? '',
    );
  }

  Widget _buildTopActions() {
    return YarnCommentReplyActions(
      replyCommentDetail: replyCommentDetail!,
    );
  }
}
