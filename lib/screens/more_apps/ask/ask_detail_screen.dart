import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import 'components/ask_comment_view.dart';
import 'components/ask_posts_view.dart';

class AskDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Health',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: blackFont,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: navyBlue,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              AskPosts(
                openComments: true,
                commentsOnPosts: Container(
                  height: 330 * 2,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 18),
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                      return AskCommentView(
                        totalLikes: '3',
                        totalDislikes: '6',
                        totalReplies: '13',
                      );
                    }
                  ),
                ),
              ),
          ],),
        ),
      )
    );
  }
}