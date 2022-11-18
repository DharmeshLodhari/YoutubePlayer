import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../utils/util.dart';

class AskReplyView extends StatelessWidget {
  Widget? replyViews;
  String? totalLikes;
  String? totalReplies;
  String? totalDislikes;
  bool? isASubReply;
  bool? hasReplies;
  YarnTopic? yarnTopic;

  AskReplyView(
      {this.replyViews,
        this.totalLikes,
        this.totalDislikes,
        this.hasReplies = false,
        this.isASubReply,
        this.yarnTopic,
        this.totalReplies});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            _buildUserInfoRow(),
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
                  imageUrl: yarnTopic!.authorAvatar!,
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
                    userNameWithVerifiedIcon(name: yarnTopic!.authorName!, isVerified: false),
                    SizedBox(width: 5,),
                    Text(
                      '4 mins',
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
      "Replying to Ahmed Yusuf",
      style: TextStyle(
          fontSize: 10,
          color: HexColor("#030F36")
      ),
    );
  }

  Widget _buildCommentDescription() {
    return Text(
      "Vitamin C helps in controlling fever, halts the infection from spreading and accelerates healing in the body. Lemon water, orange and sweet lime are good options. Eat as fruits or have as juice depending upon your condition.",
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
    );
  }
}
