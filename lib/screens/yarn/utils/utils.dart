import 'package:Slydo/screens/yarn/utils/yarn_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../utils/util.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

enum Types { Yarn, Question }

Future<Uint8List?> getVideoThumbnailFromUrl(String videoPath) async {
  final uInt8list = await VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: ImageFormat.JPEG,
    maxWidth:
        512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );
  return uInt8list;
}

String getGetYarnQuestionDateTime(String dateTime) {
  return toTimeAgoLabelYarn(dateTime: DateTime.parse(dateTime));
}

List<String> getAllHashtags(String text) {
  text = messageDecoderWithEmoji(text) ?? "";
  text = text.replaceAll(RegExp(r'\n'), ' ');
  final new_list = text.split(" ");
  new_list.removeWhere((item) => ["", " ", null, false, 0].contains(item));
  final List<String> hashtags = [];
  for (var i in new_list) {
    if (i.startsWith("#")) {
      // debugPrint("NaI:$i");
      hashtags.add(i);
    }
  }

  // final regexp = RegExp(r'\#[a-zA-Z0-9._-]+\b()');
  // regexp.allMatches(text).forEach((element) {
  //   if (element.group(0) != null) {
  //     hashtags.add(element.group(0).toString());
  //   }
  // });

  return hashtags;
}

List<String> getAllMentions(String text) {
  final regexp = RegExp(r'\@[a-zA-Z0-9._-]+\b()');

  final List<String> mentions = [];
  final List<String> filterMention = [];

  regexp.allMatches(text.replaceAll("\n", " ")).forEach((element) {
    if (element.group(0) != null) {
      mentions.add(element.group(0).toString());
    }
  });

  for (var mention in mentions) {
    String removeDot = mention.trim();
    while (removeDot.endsWith(".")) {
      removeDot = removeDot.substring(0, removeDot.length - 1);
    }
    filterMention.add(removeDot);
  }

  return filterMention;
}

double getItemHeight(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return MediaQuery.of(context).size.width / 1.5;
    case TileRenderPlace.YarnComment:
      return MediaQuery.of(context).size.width / 2.0;
    case TileRenderPlace.YarnProductService:
      return MediaQuery.of(context).size.width / 2.0;
    case TileRenderPlace.Thiny:
      return MediaQuery.of(context).size.width / 3.0;
  }
}

double getSizeBoxHeight(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 10;
    case TileRenderPlace.YarnComment:
      return 6;
    case TileRenderPlace.YarnProductService:
      return 6;
    case TileRenderPlace.Thiny:
      return 4;
  }
}

double getFontSize(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 12;
    case TileRenderPlace.YarnComment:
      return 12;
    case TileRenderPlace.YarnProductService:
      return 10;
    case TileRenderPlace.Thiny:
      return 12;
  }
}

double getContainerHeight(
    TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 120;
    case TileRenderPlace.YarnComment:
      return 120;
    case TileRenderPlace.YarnProductService:
      return 100;
    case TileRenderPlace.Thiny:
      return 80;
  }
}

double getWallPaperCoverHeight(
    TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 130;
    case TileRenderPlace.YarnComment:
      return 110;
    case TileRenderPlace.YarnProductService:
      return 100;
    case TileRenderPlace.Thiny:
      return 80;
  }
}

double getAvatarTop(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 100;
    case TileRenderPlace.YarnComment:
      return 80;
    case TileRenderPlace.YarnProductService:
      return 60;
    case TileRenderPlace.Thiny:
      return 40;
  }
}

double getButtonSize(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 36;
    case TileRenderPlace.YarnComment:
      return 36;
    case TileRenderPlace.YarnProductService:
      return 30;
    case TileRenderPlace.Thiny:
      return 20;
  }
}

Widget assignTitleToAction({required String text, required Widget child}) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 60),
    child: Column(
      children: [
        child,
        const SizedBox(height: 10),
        Center(
          child: Text(text,
              style: TextStyle(
                color: blackFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center),
        )
      ],
    ),
  );
}

String removeLinksAndWords(String text, List<String> wordsToRemove) {
  // Check for links and remove them with expect to @ and hash
  final linkRegExp =
      RegExp(r'\bhttps?://[^\s<>"]+|www\.[^\s<>"]+\b', caseSensitive: false);
  text = text.replaceAll(linkRegExp, '');

  // Remove any words that match any of the words in the list, ignoring case
  for (String word in wordsToRemove) {
    final wordRegExp = RegExp(
        r'\b(?<![/:.\d])(?<!\d\.)\d*[.\/:]\d+\b(?!\d)|\b(?<!\d)' +
            word +
            r'(?!\d)\b',
        caseSensitive: false);
    text = text.replaceAll(wordRegExp, '');
  }

  return text;
}

Widget getUserProfilePic(String image, String fullName) {
  if (image == "" ||
      image ==
          "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
    return CircleAvatar(
      backgroundColor: navyBlue,
      radius: 15,
      child: Text(
        getInitials(fullName).toUpperCase(),
        style: TextStyle(color: white, fontWeight: FontWeight.w600),
      ),
    );
  } else {
    return SizedBox(
      width: 25,
      child: getCircularUserAvatar(image),
    );
  }
}
