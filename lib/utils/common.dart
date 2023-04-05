import 'dart:convert';
import 'dart:typed_data';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';
import 'global_key.dart';

String? messageDecoderWithEmoji(String? text) {
  try {
    List<int> bytes = text!.codeUnits;

    return utf8.decode(bytes);
    // return utf8.decode(base64.decode(text!));
    // return latin1.decode(base64.decode(text.toString()));
  } catch (error) {
    logger.e('An error occurred: $error');
    return text;
  }
}

String? messageDecoder(Uint8List data) {
  return utf8.decode(data);
}

Future<bool> sendDataToSocket(Map<String, dynamic> data) async {
  MainSocketProvider mainSocketProvider = Provider.of<MainSocketProvider>(
      myGlobals.navigationKey.currentContext!,
      listen: false);
  await mainSocketProvider.add(data);

  return true;
}

Color getUserTypeColor({required CustomerProfile user}) {
  return user.type!.toLowerCase() != "user"
      ? user.type!.toLowerCase() != "business"
          ? starYellow
          : naturalGreen
      : navyBlue;
}

Color getUserTypeColorByType({required String type}) {
  return type.toLowerCase() != "user"
      ? type.toLowerCase() != "business"
          ? starYellow
          : naturalGreen
      : navyBlue;
}

String trimString(String input) {
  List<String> words = input.split(' ');
  if (words.length > 30) {
    words = words.sublist(0, 30);
    input = words.join(' ') + '...';
  }
  return input;
}

String appendStringDot(String input, int maxLength) {
  // int maxLength = 20;
  String shortText =
      input.length > maxLength ? input.substring(0, maxLength) + "..." : input;
  return shortText;
}
