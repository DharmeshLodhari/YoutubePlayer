import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/navigation_util.dart';
import '../ask_search_screen.dart';
import '../utils/utils.dart';

class RichTextForTitle extends StatelessWidget {
  String? description;
  double? fontSize;
  FontWeight? fontWeight;
  RichTextForTitle({Key? key, this.description, this.fontSize = 12, this.fontWeight = FontWeight.w400}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildHighlightedText(description!, context);
  }

  RichText buildHighlightedText(String text, BuildContext context) {
    List<String> hashtags = getAllHashtags(text);
    List<String> mentions = getAllMentions(text);

    List<TextSpan> textSpans = [];

    text.split(" ").forEach((value) {
      String removeDot = value.trim();
      String removedString = "";
      while (removeDot.endsWith(".")) {
        removeDot = removeDot.substring(0, removeDot.length - 1);
        removedString += ".";
      }

      if (hashtags.contains(removeDot)) {
        String addSpace = '';
        if (removedString == '') {
          addSpace = " ";
        }

        textSpans.add(TextSpan(
          text: '$removeDot$addSpace',
          style: TextStyle(
            color: navyBlue,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              NavigationUtil.push(context,
                  screen: SearchScreen(
                    searchText: removeDot,
                  ));
            },
        ));
        if (removedString != '') {
          textSpans.add(TextSpan(
            text: '$removedString ',
            style: TextStyle(
              color: blackFont,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ));
        }
      } else if (mentions.contains(removeDot)) {
        String addSpace = '';
        if (removedString == '') {
          addSpace = " ";
        }

        textSpans.add(TextSpan(
          text: '$removeDot$addSpace',
          style: TextStyle(
            color: navyBlue,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, Routes.USER_PROFILE,
                  arguments: {"searchedUserName": removeDot.substring(1)});
            },
        ));
        if (removedString != '') {
          textSpans.add(TextSpan(
              text: '$removedString ',
              style: TextStyle(
                color: blackFont,
                fontSize: fontSize,
                fontWeight: fontWeight,
              )));
        }
      } else {
        textSpans.add(TextSpan(
          text: '$value ',
          style: TextStyle(
            color: blackFont,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ));
      }
    });
    return RichText(text: TextSpan(children: textSpans));
  }
}
