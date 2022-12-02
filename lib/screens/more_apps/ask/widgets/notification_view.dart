import 'package:Slydo/screens/more_apps/ask/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/topic_action_for_notification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';

class AskNotificationView extends StatelessWidget {
  const AskNotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildUserInfoRow(context: context);
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
                    arguments: "");
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: "",
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
                    // Navigator.pushNamed(context, Routes.USER_PROFILE,
                    //     arguments: {
                    //       "searchedUserName": commentDetail!.authorUsername!
                    //     });
                  },
                  child: userNameWithVerifiedIcon(name: "Japa Inc", isVerified: false),
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
              text: "@japa",
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
    return RichTextForTitle(description: messageDecoderWithEmoji('') ?? '',);
  }

  Widget _buildTopActions({required BuildContext context}) {
    return TopicActionsForNotification();
  }
}
