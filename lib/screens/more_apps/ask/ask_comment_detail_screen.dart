import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/util.dart';
import 'components/ask_posts_view.dart';
import 'components/ask_reply_view.dart';

class AskCommentDetailScreen extends StatelessWidget {
  YarnTopic? yarnTopic;

  AskCommentDetailScreen({this.yarnTopic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            !yarnTopic!.isQuestion! ? "Yarn" : "Question",
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
                  child: AskPosts(
                      openComments: true,
                      commentsOnPosts: Container(
                        child: Column(
                          children: [
                            AskReplyView(
                              yarnTopic: yarnTopic,
                            ),
                            AskReplyView(
                              yarnTopic: yarnTopic,
                            ),
                            AskReplyView(
                              yarnTopic: yarnTopic,
                            ),
                          ],
                        ),
                      ),
                      yarnTopic: yarnTopic,
                      isImages: yarnTopic!.media != null ? true : false,
                      backGroundColor: HexColor("#EBEDFC")),
                ),
              ),
            ),
            TopicTextField(
              controller: TextEditingController(),
              hint: "Leave your thought",
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
      padding: EdgeInsets.symmetric(horizontal: 15),
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
                imageUrl:
                    "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg",
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
                  contentPadding: const EdgeInsets.all(15),
                  border: InputBorder.none,
                  hintText: hint ?? '',
                  hintStyle:
                      TextStyle(fontSize: 12, color: HexColor("#75818F")),
                  suffixIcon: suffixIcon ?? const SizedBox.shrink()),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
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
