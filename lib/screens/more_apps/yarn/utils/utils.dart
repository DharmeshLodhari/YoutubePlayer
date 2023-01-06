import 'dart:typed_data';
import 'package:Slydo/main.dart';
import 'package:flutter/foundation.dart';
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
  return toTimeAgoLabel(dateTime: DateTime.parse(dateTime));
}

List<String> getAllHashtags(String text) {
  text = messageDecoderWithEmoji(text) ?? "";
  text = text.replaceAll(RegExp(r'\n'), ' ');
  var new_list = text.split(" ");
  new_list.removeWhere((item) => ["", " ", null, false, 0].contains(item));
  List<String> hashtags = [];
  for (var i in new_list){
    if(i.startsWith("#")) {
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

