import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/navigation_util.dart';
import '../utils/utils.dart';
import '../yarn_search_screen.dart';

class RichTextForTitle extends StatelessWidget {
  String? description;
  double? fontSize;
  FontWeight? fontWeight;
  RichTextForTitle(
      {Key? key,
      this.description,
      this.fontSize = 14,
      this.fontWeight = FontWeight.w400})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildHighlightedText2(context, description ?? '');
    // return buildHighlightedText(description!, context);
  }

  RichText buildHighlightedText(String text, BuildContext context) {
    final List<String> hashtags = getAllHashtags(text);
    final List<String> mentions = getAllMentions(text);

    final List<TextSpan> textSpans = [];

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
          text: messageDecoderWithEmoji('$removeDot$addSpace'),
          style: TextStyle(
            color: navyBlue,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              NavigationUtil.push(context,
                  screen: SearchScreen(searchText: removeDot));
            },
        ));
        if (removedString != '') {
          textSpans.add(TextSpan(
            text: messageDecoderWithEmoji('$removedString '),
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
          text: messageDecoderWithEmoji('$removeDot$addSpace'),
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
              text: messageDecoderWithEmoji('$removedString '),
              style: TextStyle(
                color: blackFont,
                fontSize: fontSize,
                fontWeight: fontWeight,
              )));
        }
      } else {
        textSpans.add(TextSpan(
          text: messageDecoderWithEmoji('$value '),
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

  Text buildHighlightedText2(BuildContext context, String text) {
    final List<InlineSpan> textSpans = [];
    final RegExp regex = RegExp(r"[#@](\w+)");
    final Iterable<Match> matches = regex.allMatches(text);
    int start = 0;
    for (final Match match in matches) {
      textSpans.add(TextSpan(
          text: messageDecoderWithEmoji(text.substring(start, match.start)),
          // text: text.substring(start, match.start),
          style: TextStyle(
              color: blackFont, fontSize: fontSize, fontWeight: fontWeight)));
      textSpans.add(WidgetSpan(
          child: GestureDetector(
              onTap: () {
                if (match.group(0)!.startsWith('@')) {
                  Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                    "searchedUserName": match.group(0)?.replaceFirst("@", "")
                  });

                  return;
                }
                NavigationUtil.push(context,
                    screen: SearchScreen(searchText: match.group(0)));
              },
              child: Text(
                '${match.group(0)}',
                style: TextStyle(
                    color: navyBlue,
                    fontSize: fontSize,
                    fontWeight: fontWeight),
              ))));
      start = match.end;
    }
    textSpans.add(TextSpan(
        text: messageDecoderWithEmoji(text.substring(start, text.length)),
        // text: text.substring(start, text.length),
        style: TextStyle(
            color: blackFont, fontSize: fontSize, fontWeight: fontWeight)));
    return Text.rich(TextSpan(children: textSpans));
  }
}
