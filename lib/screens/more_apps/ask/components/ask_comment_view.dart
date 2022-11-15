import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class AskCommentView extends StatelessWidget {
  Widget? replyViews;
  String? totalLikes;
  String? totalReplies;
  String? totalDislikes;
  bool? isASubReply;
  bool? hasReplies;

  AskCommentView(
      {this.replyViews,
      this.totalLikes,
      this.totalDislikes,
      this.hasReplies = false,
      this.isASubReply,
      this.totalReplies});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: navyBlueLight,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Black Enterprise',
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '4 mins',
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (hasReplies!) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Expanded(
                      child: Container(
                          width: 2,
                          height: 110,
                          decoration: BoxDecoration(
                            color: blackFont.withOpacity(0.2),
                          )),
                    ),
                  )
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      children: [
                        Text(
                          'Replying to Tamara enterprise',
                          style: TextStyle(
                            color: eyeGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Text(
                        'Vitamin C helps in controlling fever, halts the infection from '
                        'spreading',
                        maxLines: 30,
                        style: TextStyle(
                          color: blackFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        children: [
                          TopicActions(
                            yarnTopic: YarnTopic(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
            if (hasReplies!) ...[
              replyViews!,
              Row(
                children: [
                  Text(
                    'view more',
                    style: TextStyle(
                      color: blackFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
