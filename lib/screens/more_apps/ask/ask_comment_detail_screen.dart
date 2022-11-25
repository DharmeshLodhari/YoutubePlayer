import 'package:Slydo/screens/more_apps/ask/components/ask_comment_view.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/state_notifier.dart';
import '../../../utils/colors.dart';
import '../../../utils/util.dart';
import 'ask_auth.dart';
import 'components/ask_loader.dart';
import 'components/topic_text_field.dart';
import 'models/Topics/CommentDetails.dart';
import 'models/Topics/ReplyCommentDetails.dart';

class AskCommentDetailScreen extends StatefulWidget {
  YarnTopic? yarnTopic;
  CommentDetails? commentDetail;

  AskCommentDetailScreen({this.yarnTopic, this.commentDetail});

  @override
  State<AskCommentDetailScreen> createState() => _AskCommentDetailScreenState();
}

class _AskCommentDetailScreenState extends State<AskCommentDetailScreen> {

  late UserBloc userBloc;
  bool isLoading = false;
  String next = "", previous = "";
  List<ReplyCommentDetails> replyCommentDetailsList = [];
  int count = 0;
  bool noList = false;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getAllCommentsDetails();
    super.initState();
  }

  void getAllCommentsDetails() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllReply(next, previous, widget.commentDetail!.id!);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'] != null ? result['count'] : 0;
        next = result['next'] != null ? result['next'] : "";
        previous = result['previous'] != null ? result['previous'] : "";
        var tempList = result['results'];
        replyCommentDetailsList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            replyCommentDetailsList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $replyCommentDetailsList");
      }
      if (replyCommentDetailsList.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCommentDetailView(),
        _buildTopicTextField(),
        SizedBox(height: 20,)
      ],
    );
  }

  Widget _buildCommentDetailView() {
    return Expanded(
      child: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: !isLoading ? AskCommentView(
            yarnTopic: widget.yarnTopic,
            commentDetail: widget.commentDetail,
            replyCommentDetailsList: replyCommentDetailsList,
            openReply: replyCommentDetailsList.isNotEmpty ? true : false,
          ) : AskLoader(),
        ),
      ),
    );
  }

  Widget _buildTopicTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TopicTextField(
        height: 50,
        controller: controller,
        hint: "Leave your thought",
        yarn: widget.yarnTopic,
        userImage: userBloc.user.avatar,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          Map<String, dynamic> data = {
            "comment": controller.text,
            "author_username": userBloc.user.userName,
            "is_reply": true
          };
          try {
            ReplyCommentDetails? replyCommentDetail = await AskAuth()
                .addReplyToComment(widget.commentDetail!.id!, data);
            if (replyCommentDetail != null) {
              replyCommentDetailsList.add(replyCommentDetail);
              controller.clear();

              if (mounted) setState(() {});
            }
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString())));
          }
        },
      ),
    );
  }
}