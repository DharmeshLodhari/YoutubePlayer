import 'dart:typed_data';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../utils/util.dart';

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
  var new_list = text.split(" ");
  new_list.removeWhere((item) => ["", " ", null, false, 0].contains(item));
  List<String> hashtags = [];
  for (var i in new_list) {
    if (i.startsWith("#")) {
      print("NaI:$i");
      hashtags.add(i);
    }
  }

  final regexp = RegExp(r'\#[a-zA-Z0-9._-]+\b()');
  // regexp.allMatches(text).forEach((element) {
  //   if (element.group(0) != null) {
  //     hashtags.add(element.group(0).toString());
  //   }
  // });

  return hashtags;
}

List<String> getAllMentions(String text) {
  final regexp = RegExp(r'\@[a-zA-Z0-9._-]+\b()');

  List<String> mentions = [];
  List<String> filterMention = [];

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
      return MediaQuery.of(context).size.width / 2.7;
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
  }
}

double getFontSize(TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 14;
    case TileRenderPlace.YarnComment:
      return 12;
    case TileRenderPlace.YarnProductService:
      return 10;
  }
}

double getContainerHeight(
    TileRenderPlace tileRenderPlace, BuildContext context) {
  switch (tileRenderPlace) {
    case TileRenderPlace.YarnTimeLine:
      return 140;
    case TileRenderPlace.YarnComment:
      return 120;
    case TileRenderPlace.YarnProductService:
      return 100;
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
  }
}
