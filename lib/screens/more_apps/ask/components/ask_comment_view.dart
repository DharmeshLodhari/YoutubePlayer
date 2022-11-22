import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../utils/util.dart';
import '../models/Topics/CommentDetails.dart';

class AskCommentView extends StatelessWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;

  AskCommentView(
      {
      this.yarnTopic,
      this.commentDetail,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            _buildUserInfoRow(),
            Divider(
              thickness: 2,
              color: HexColor("#EBEDFC"),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUserInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
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
            SizedBox(
              width: 10,
            ),
          ],
        ),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    userNameWithVerifiedIcon(name: commentDetail!.authorUsername!, isVerified: false),
                    SizedBox(width: 5,),
                    Text(
                      '',
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3,),
                _buildRepliedText(),
                SizedBox(height: 15,),
                _buildCommentDescription(),
                SizedBox(height: 10,),
                _buildTopActions(),
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
    return Text(
      "",
      style: TextStyle(
        fontSize: 10,
        color: HexColor("#030F36")
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

  Widget _buildTopActions() {
    return TopicActions(
      yarnTopic: yarnTopic!,
      commentCount: commentDetail!.replyCount! as int,
      likeCount: commentDetail!.socialLikes != null ? commentDetail!.socialLikes! as int : 0,
      disLikeCount: commentDetail!.socialDislikes != null ? commentDetail!.socialDislikes! as int : 0,
    );
  }
}
