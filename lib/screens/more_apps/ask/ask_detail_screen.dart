import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/topic_text_field.dart';
import 'ask_auth.dart';
import 'components/ask_posts_view.dart';
import 'models/Topics/CommentDetails.dart';

class AskDetailScreen extends StatefulWidget {
  YarnTopic? yarnTopic;

  AskDetailScreen({this.yarnTopic});

  @override
  State<AskDetailScreen> createState() => _AskDetailScreenState();
}

class _AskDetailScreenState extends State<AskDetailScreen> {
  bool isLoading = false;
  String next = "", previous = "";
  List<CommentDetails> commentDetailsList = [];
  int count = 0;
  bool noList = false;
  late UserBloc userBloc;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getAllComments();
    super.initState();
  }

  void getAllComments() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllComments(next, previous, widget.yarnTopic!.id!);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'] != null ? result['next'] : "";
        previous = result['previous'] != null ? result['previous'] : "";
        var tempList = result['results'];
        commentDetailsList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            commentDetailsList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $commentDetailsList");
      }
      if (commentDetailsList.isEmpty) {
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: !isLoading ? AskPosts(
                  openComments: commentDetailsList.isNotEmpty ? true : false,
                  commentDetailsList: commentDetailsList,
                  yarnTopic: widget.yarnTopic,
                  isImages: widget.yarnTopic!.media != null &&
                          widget.yarnTopic!.media!.isNotEmpty
                      ? true
                      : false,
                ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(navyBlue),),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TopicTextField(
                height: 50,
                controller: controller,
                hint: "Leave your thought",
                yarn: widget.yarnTopic,
                userImage: userBloc.user.avatar,
                onPressed: () async {
                  Map<String, dynamic> data = {
                    "comment": controller.text,
                    "author_username": userBloc.user.userName
                  };
                  try {
                    CommentDetails? commentDetails = await AskAuth()
                        .addCommentToYarn(widget.yarnTopic!.id!, data);
                    if (commentDetails != null) {
                      commentDetailsList.insert(0, commentDetails);
                      controller.clear();

                      if (mounted) setState(() {});
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }
}
