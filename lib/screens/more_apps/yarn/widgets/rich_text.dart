import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/navigation_util.dart';
import '../ask_search_screen.dart';
import '../utils/utils.dart';

class RichTextForTitle extends StatelessWidget {
  String? description;
  RichTextForTitle({Key? key, this.description}) : super(key: key);

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
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              NavigationUtil.push(context, screen: SearchScreen(searchText: removeDot,));
            },
        ));
        if (removedString != '') {
          textSpans.add(TextSpan(
            text: '$removedString ',
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
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
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, Routes.USER_PROFILE,
                  arguments: {
                    "searchedUserName": removeDot.substring(1)
                  });
            },
        ));
        if (removedString != '') {
          textSpans.add(TextSpan(
            text: '$removedString ',
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            )
          ));
        }
      } else {
        textSpans.add(TextSpan(text: '$value ', style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),));
      }
    });
    return RichText(text: TextSpan(children: textSpans));
  }
}
