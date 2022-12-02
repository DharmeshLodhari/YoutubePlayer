import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../utils/util.dart';

enum Types {Yarn, Question}

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