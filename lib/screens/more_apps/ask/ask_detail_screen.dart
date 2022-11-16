import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../widget/customized_textform_field.dart';
import 'components/ask_comment_view.dart';
import 'components/ask_posts_view.dart';

class AskDetailScreen extends StatelessWidget {

  YarnTopic? yarnTopic;

  AskDetailScreen({this.yarnTopic});

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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  AskPosts(
                    openComments: true,
                    commentsOnPosts: Container(
                      height: 330 * 3.1,
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          padding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 18),
                          itemCount: 3,
                          itemBuilder: (BuildContext context, int index) {
                            return AskCommentView(
                              totalLikes: '3',
                              totalDislikes: '6',
                              totalReplies: '13',
                              hasReplies: true,
                              yarnTopic: yarnTopic,
                              replyViews: AskCommentView(
                                totalLikes: '3',
                                totalDislikes: '6',
                                totalReplies: '13',
                                isASubReply: true,
                                yarnTopic: yarnTopic,
                              ),
                            );
                          }),
                    ),
                    yarnTopic: yarnTopic,
                    isImages: yarnTopic!.image != null ? true : false,
                  ),
                ],
              ),
            ),
            TopicTextField(
              controller: TextEditingController(),
            ),
          ],
        ));
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

  const TopicTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.height = 60,
    this.function,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.leading = const SizedBox(
      width: 0,
      height: 0,
    ),
    this.onTap,
    this.suffix = true,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: blackFont.withOpacity(0.1),
          width: 2,
        ),
      ),
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
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          hintText: hint ?? '',
          hintStyle: const TextStyle(fontSize: 12),
          suffixIcon: suffixIcon ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
