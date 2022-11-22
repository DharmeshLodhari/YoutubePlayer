import 'package:Slydo/screens/more_apps/ask/components/ask_comment_view.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/state_notifier.dart';
import '../../../utils/colors.dart';
import '../../../utils/util.dart';
import 'components/topic_text_field.dart';
import 'models/Topics/CommentDetails.dart';

class AskCommentDetailScreen extends StatefulWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;

  AskCommentDetailScreen({this.yarnTopic, this.commentDetail});

  @override
  State<AskCommentDetailScreen> createState() => _AskCommentDetailScreenState();
}

class _AskCommentDetailScreenState extends State<AskCommentDetailScreen> {

  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            !widget.yarnTopic!.isQuestion! ? "Yarn" : "Question",
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
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: AskCommentView(
                      yarnTopic: widget.yarnTopic,
                    commentDetail: widget.commentDetail,
                  ),
                ),
              ),
            ),
            TopicTextField(
              height: 50,
              controller: TextEditingController(),
              hint: "Leave your thought",
              yarn: widget.yarnTopic,
              userImage: userBloc.user.avatar,
            ),
          ],
        ));
  }
}