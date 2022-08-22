import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class AskPosts extends StatelessWidget {

  bool? openComments;
  Widget? commentsOnPosts;
  bool? showTag;
  Function? onOptionsAction;

  AskPosts({
    this.openComments = false,
    this.commentsOnPosts,
    this.showTag = true,
    this.onOptionsAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: navyBlueLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Row(children: [
            showTag! ? Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: navyBlue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Text(
                      'Health',
                      style: TextStyle(
                        color: white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
              ],
            ) : Container(),
            Expanded(
              child: Text(
                'Does Malaria Kills ?',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: ()=> onOptionsAction!(),
              child: Icon(Icons.more_horiz_rounded, color: navyBlue,),
            )
          ],),
          SizedBox(height: 10,),
          Row(children: [
            Text(
              'Posted by Tamara',
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10,),
            Text(
              '4 mins',
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],),
          SizedBox(height: 10,),
          Text(
            'I am currently in a remote environment at the '
                'moment. what can I take as first aid before seeing the doctor ?',
            maxLines: 30,
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 15,),
          TopicActions(
            totalDislikes: '30',
            totalLikes: '323',
            totalReply: '23',
          ),
          SizedBox(height: 20,),
          if(openComments! && commentsOnPosts != null) ... [
            Divider(thickness: 1, color: blackFont.withOpacity(0.3),),
            commentsOnPosts!,
          ]
        ],),
      ),
    );
  }
}