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
    // print("handler called!!! $message");
    Map<String, dynamic> messageData = jsonDecode(message);
    // print("MEssageData 1:- ${messageData["type"]}");

    if (messageData["type"] == "chatroom_message") {
      // print("MEssageData 2 in if:- ${messageData["type"]}");
      MainSocketMessageModel messageModel =
          MainSocketMessageModel.fromJson(jsonDecode(message));

      String hashedMessage = generateHashedMessage(message);

      ChatUserManager().addUser(
          conversationId:
              messageData["conversation"] ?? messageData["conversation_id"]);

      ChatUserManager().updateChatUserMessageCount(
          conversationId: messageModel.conversation,
          hashedMessage: hashedMessage);
    }
  }
}

String generateHashedMessage(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
