import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// allowed message types
List<String> imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"];
List<String> videoExtensions = [
  "mp4",
  "mov",
  "wmv",
  "flv",
  "avi",
  "webm",
  "mkv",
  "temp",
];
List<String> fileExtensions = ['txt', 'pdf', 'apk', 'zip', 'xls'];
List<String> audioExtensions = ["m4a", "mp3", "ogg", "aac"];

Future<String?> getVideoThumbnail(File file) async {
  final String? path = await VideoThumbnail.thumbnailFile(
    video: file.path,
    imageFormat: ImageFormat.JPEG,
    maxWidth:
        512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );
  // debugPrint(" PATH:-  ===> $path");
  return path;
}

String? getFileTypeByPath({required String path}) {
  if (path.isEmpty) return null;

  final List<String> splitName = path.split(".");

  if (splitName.isNotEmpty) {
    final String extension = splitName.last.toLowerCase();

    if (fileExtensions.contains(extension)) return "file";
    if (imageExtensions.contains(extension)) return "image";
    if (videoExtensions.contains(extension)) return "video";
    if (audioExtensions.contains(extension)) return "audio";
  }
  return null;
}

String getFileType(FilePickerResult pickedMedia) {
  // debugPrint("File path :- ${pickedMedia.files.single.path}");
  // debugPrint("File name :- ${pickedMedia.files.single.name}");
  // debugPrint("File extension :- ${pickedMedia.files.single.extension}");
  final String? extension = pickedMedia.files.single.extension;
  // debugPrint(
  //     " pickedMedia.files.single.path => ${pickedMedia.files.single.path}");

  if (fileExtensions.contains(extension)) return "file";
  if (imageExtensions.contains(extension)) return "image";
  if (videoExtensions.contains(extension)) return "video";
  if (audioExtensions.contains(extension)) return "audio";
  return "";
}

String getFileExtension(FilePickerResult pickedMedia) {
  // debugPrint("File path :- ${pickedMedia.files.single.path}");
  // debugPrint("File name :- ${pickedMedia.files.single.name}");
  // debugPrint("File extension :- ${pickedMedia.files.single.extension}");
  final String? extension = pickedMedia.files.single.extension;

  if (imageExtensions.contains(extension)) return "image";
  if (videoExtensions.contains(extension)) return "video";
  if (audioExtensions.contains(extension)) return "audio";
  return "";
}

Color getMessageTickColor({required Map<String, dynamic> message}) {
  return message['delivered']
      ? message['read_by_recipient'] ?? false
          ? navyBlue
          : darkGrey
      : darkGrey;
}

Widget getMessageTick({required Map<String, dynamic> message}) {
  return Icon(
    message['delivered']
        ? Icons.check_circle_rounded
        : Icons.check_circle_outline_outlined,
    size: 12,
    color: getMessageTickColor(message: message),
  );
}

String? getAuthorName(
    {required Map<String, dynamic> message, required User currentUser}) {
  final bool isSend = currentUser.userName == message["author"];

  if (isSend) {
    return "You";
  } else {
    return message["author_full_name"] ?? message["author"];
  }
}

String getCurrency(String title, String? symbol) {
  if (title.contains("CURRENCY") && symbol != null) {
    return title.replaceAll("CURRENCY", worldCurrencies[symbol]!);
  } else {
    return title;
  }
}
