import 'package:Slydo/screens/more_apps/ask/components/ask_reply_view.dart';
import 'package:Slydo/screens/more_apps/ask/components/topic_action_for_comment.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/ReplyCommentDetails.dart';

class AskCommentView extends StatelessWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;
  List<ReplyCommentDetails>? replyCommentDetailsList = [];
  bool? openReply = false;

  AskCommentView(
      {
      this.yarnTopic,
      this.commentDetail,
      this.replyCommentDetailsList,
      this.openReply,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            _buildUserInfoRow(context: context),
            Divider(
              thickness: 2,
              color: HexColor("#EBEDFC"),
            ),
            _buildReplyCommentView(context: context),
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
                    arguments: commentDetail!.authorAvatar!);
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: commentDetail!.authorAvatar!,
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
                    Navigator.pushNamed(context, Routes.USER_PROFILE,
                        arguments: {
                          "searchedUserName": commentDetail!.authorUsername!
                        });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userNameWithVerifiedIcon(
                          name: commentDetail!.authorName!, isVerified: false),
                      Text(
                        "@${commentDetail!.authorUsername!}",
                        style: TextStyle(
                            fontSize: 10,
                            color: HexColor("#3F61DB")
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3,),
                _buildRepliedText(),
                SizedBox(height: 15,),
                _buildCommentDescription(),
                SizedBox(height: 10,),
                _buildTopActions(context: context),
              ],
            )
        ),
        InkWell(
          onTap: () {},
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
      text: TextSpan(
        children: [
          TextSpan(
            text: "Replying to ",
            style: TextStyle(
                fontSize: 10,
                color: HexColor("#030F36")
            ),
          ),
          TextSpan(
            text: "@${yarnTopic!.author}",
            style: TextStyle(
                fontSize: 10,
                color: HexColor("#3F61DB")
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildCommentDescription() {
    return Text(
      commentDetail!.comment!,
      maxLines: 30,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTopActions({required BuildContext context}) {
    return TopicActionsForComment(
      commentDetail: commentDetail!,
    );
  }

  Widget _buildReplyCommentView({required BuildContext context}) {
    if (openReply! && replyCommentDetailsList!.isNotEmpty && replyCommentDetailsList != null) {
      return Column(
        children: replyCommentDetailsList!.map((replyCommentDetail) {
          return InkWell(
            onTap: () {
              // NavigationUtil.push(
              //   context,
              //   screen: AskCommentDetailScreen(yarnTopic: yarnTopic, commentDetail: commentDetail,),
              // );
            },
            child: AskReplyView(
              yarnTopic: yarnTopic,
              commentDetail: commentDetail,
              replyCommentDetail: replyCommentDetail,
            ),
          );
        }).toList(),
      );
    }
    return SizedBox();
  }
}
