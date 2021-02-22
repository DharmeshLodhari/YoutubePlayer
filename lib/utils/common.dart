import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';
import 'global_key.dart';

String messageDecoderWithEmoji(String text) {
  try {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  } catch (error) {
    return text;
  }
}

Future<bool> sendDataToSocket(Map<String, dynamic> data) async {
  MainSocketProvider mainSocketProvider = Provider.of<MainSocketProvider>(
      myGlobals.scaffoldKey.currentContext,
      listen: false);

  await mainSocketProvider.add(data);

  return true;
}

Color getUserTypeColor({CustomerProfile user}) {
  return user.type.toLowerCase() != "user"
      ? user.type.toLowerCase() != "business"
          ? starYellow
          : naturalGreen
      : navyBlue;
}

Color getUserTypeColorByType({String type}) {
  return type.toLowerCase() != "user"
      ? type.toLowerCase() != "business"
          ? starYellow
          : naturalGreen
      : navyBlue;
}
