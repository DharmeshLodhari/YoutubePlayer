import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/MainSocketMessageModel.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';

class MainSocketMessageHandler {
  final String message;

  MainSocketMessageHandler({@required this.message}) {
    handleMessageAccordingToType();
  }

  void handleMessageAccordingToType() {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (messageData["type"] == "chatroom_message") {
      MainSocketMessageModel messageModel =
          MainSocketMessageModel.fromJson(jsonDecode(message));

      String hashedMessage = generateHashedMessage(message);

      // ChatUserManager().addUser();

      ChatUserManager().updateChatUserMessageCount(
          conversationId: messageModel.conversation,
          hashedMessage: hashedMessage);
    }
  }
}

String generateHashedMessage(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
