import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ask_auth.dart';
import 'ask_comment_detail_screen.dart';
import 'components/ask_comment_view.dart';
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
    getYarnTopic();
    super.initState();
  }

  void getYarnTopic() async {
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
                child: AskPosts(
                  openComments: true,
                  commentsOnPosts: Container(
                    child: _buildCommentSection(),
                  ),
                  yarnTopic: widget.yarnTopic,
                  isImages: widget.yarnTopic!.media != null &&
                          widget.yarnTopic!.media!.isNotEmpty
                      ? true
                      : false,
                ),
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
                        SnackBar(content: Text(error.toString() ?? "")));
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

  Widget _buildCommentSection() {
    return Column(
      children: commentDetailsList
          .map((e) => InkWell(
                onTap: () {
                  NavigationUtil.push(
                    context,
                    screen: AskCommentDetailScreen(yarnTopic: widget.yarnTopic),
                  );
                },
                child: AskCommentView(
                  totalLikes: '3',
                  totalDislikes: '6',
                  totalReplies: '13',
                  hasReplies: true,
                  yarnTopic: widget.yarnTopic,
                  replyViews: AskCommentView(
                    totalLikes: '3',
                    totalDislikes: '6',
                    totalReplies: '13',
                    isASubReply: true,
                    yarnTopic: widget.yarnTopic,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class TopicTextField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget leading;
  final double height;
  final Function()? function;
  final String? hint;
  final VoidCallback? onTap;
  final bool suffix;
  final Widget? suffixIcon;
  final YarnTopic? yarn;
  final String? userImage;
  final VoidCallback? onPressed;

  const TopicTextField(
      {Key? key,
      required this.controller,
      this.hint,
      this.validator,
      this.height = 60,
      this.function,
      this.keyboardType = TextInputType.text,
      this.readOnly = false,
      this.yarn,
      this.leading = const SizedBox(
        width: 0,
        height: 0,
      ),
      this.onTap,
      this.suffix = true,
      this.suffixIcon,
      this.userImage,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(left: 16, right: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: blackFont.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: userImage!,
                fit: BoxFit.cover,
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              onEditingComplete: function,
              controller: controller,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w400,
              ),
              validator: validator,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              minLines: 1,
              readOnly: readOnly,
              onTap: onTap,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                  hintText: hint ?? '',
                  hintStyle:
                      TextStyle(fontSize: 14, color: HexColor("#75818F")),
                  suffixIcon: suffixIcon ?? const SizedBox.shrink()),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: Icon(
              Icons.send,
              color: HexColor("#3F61DB"),
            ),
          ),
        ],
      ),
    );
  }
}
