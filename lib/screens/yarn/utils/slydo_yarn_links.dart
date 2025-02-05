import 'package:Slydo/screens/yarn/utils/regular_expression.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:hash_at_links_detector/hash_at_links_detector.dart';

import '../../../../utils/colors.dart';

abstract class CustomSmartTextElement {}

///Represents an element containing a link
class SlydoYarnLinks extends CustomSmartTextElement {
  SlydoYarnLinks(this.url);

  final String url;

  @override
  String toString() {
    return 'LinkElement: $url';
  }
}

/// Represents an element containing a hashTag
class HashTagElement extends CustomSmartTextElement {
  HashTagElement(this.tag);

  final String tag;

  @override
  String toString() {
    return "HashTagElement: $tag";
  }
}

/// Represents an element containing a At
class AtElement extends CustomSmartTextElement {
  AtElement(this.at);

  final String at;

  @override
  String toString() {
    return "AtElement: $at";
  }
}

/// Represents an element containing text
class TextElement extends CustomSmartTextElement {
  TextElement(this.text);

  final String text;

  @override
  String toString() {
    return "TextElement: $text";
  }
}

final _linkRegex = RegExp(
    r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
    caseSensitive: false);

final dotDot = RegExp(r'\.\.+');

/// Turns [text] into a list of [SmartTextElement]
List<CustomSmartTextElement> _smartify(
  String text,
  bool link,
  bool hashTag,
  bool at,
) {
  final List<CustomSmartTextElement> span = [];
  final lines = text.split('\n');

  for (int i = 0; i < lines.length; i++) {
    final words = lines[i].split(' ');
    for (final word in words) {
      if (link && _linkRegex.hasMatch(word) && !word.contains("..")) {
        span.add(SlydoYarnLinks("$word "));
      } else if (hashTag &&
          hashTagRegExp.hasMatch(word) &&
          !word.contains("..")) {
        span.add(HashTagElement("$word "));
      } else if (at && atSignRegExp.hasMatch(word) && !word.contains("..")) {
        span.add(AtElement("$word "));
      } else {
        span.add(TextElement("$word "));
      }
    }
    if (i != lines.length - 1) {
      span.add(TextElement('\n'));
    }
  }
  return span;
}

/// Callback with URL to open
typedef void StringCallback(String url);

/// Turns URLs into links
class YarnSmartText extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  /// Style of HashTag text
  final TextStyle? tagStyle;

  /// Style of At text
  final TextStyle? atStyle;

  /// Callback for tapping a link
  final StringCallback? onUrlClicked;

  /// Callback for tapping a tag
  final StringCallback? onTagClick;
  final int? maxLines;

  /// Callback for tapping a at
  final StringCallback? onAtClick;

  final bool disableLinks;
  final bool disableAt;
  final bool disableHashTag;

  const YarnSmartText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.tagStyle,
    this.atStyle,
    this.maxLines,
    this.onUrlClicked,
    this.onAtClick,
    this.onTagClick,
    this.disableLinks = false,
    this.disableAt = false,
    this.disableHashTag = false,
  });

  /// Raw TextSpan builder for more control on the RichText
  TextSpan _buildTextSpan({
    required String text,
    TextStyle style = const TextStyle(color: Colors.blue),
    TextStyle linkStyle = const TextStyle(color: Colors.blue),
    TextStyle tagStyle = const TextStyle(color: Colors.blue),
    TextStyle atStyle = const TextStyle(color: Colors.blue),
    StringCallback? onOpen,
    StringCallback? onTagClick,
    StringCallback? onAtClick,
  }) {
    void onOpen0(String url) {
      if (onOpen != null) {
        onOpen(url);
      }
    }

    void onTagClick0(String url) {
      if (onTagClick != null) {
        onTagClick(url);
      }
    }

    void onAtClick0(String url) {
      if (onAtClick != null) {
        onAtClick(url);
      }
    }

    final elements =
        _smartify(text, !disableLinks, !disableHashTag, !disableAt);

    return TextSpan(
      children: elements.map<TextSpan>((element) {
        if (element is TextElement) {
          return TextSpan(
            text: element.text,
            style: style,
          );
        } else if (element is SlydoYarnLinks) {
          return LinkTextSpan(
            text: '',
            style: linkStyle,
            onPressed: () => onOpen0(element.url),
          );
        } else if (element is HashTagElement) {
          return LinkTextSpan(
            text: element.tag,
            style: tagStyle,
            onPressed: () => onTagClick0(element.tag),
          );
        } else if (element is AtElement) {
          return LinkTextSpan(
            text: element.at,
            style: atStyle,
            onPressed: () => onAtClick0(element.at),
          );
        }
        final e = element as TextElement;
        return TextSpan(
          text: e.text,
          style: style,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      softWrap: true,
      text: _buildTextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyMedium!.merge(style),
        linkStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .merge(style)
            .copyWith(
              color: navyBlue,
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
        tagStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .merge(style)
            .copyWith(
              color: navyBlue,
            )
            .merge(tagStyle),
        atStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .merge(style)
            .copyWith(
              color: navyBlue,
            )
            .merge(atStyle),
        onOpen: onUrlClicked,
        onTagClick: onTagClick,
        onAtClick: onAtClick,
      ),
    );
    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //
    //   ],
    // );
  }
}

class LinkTextSpan extends TextSpan {
  LinkTextSpan({
    required TextStyle style,
    required VoidCallback onPressed,
    required String text,
  }) : super(
          style: style,
          text: text,
          recognizer: TapGestureRecognizer()..onTap = onPressed,
        );
}
