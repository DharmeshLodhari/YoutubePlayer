import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/MainSocketMessageModel.dart';
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

      var massegeHash = hashMessage(jsonDecode(message));

      ChatUserManager().updateChatUser(messageModel.conversation);
    }
  }
}

hashMessage(jsonDecode) {
  var data = {};

  data['conversationId'] = jsonDecode['conversationId'];
  data['text'] = jsonDecode['text'];
  data['check_id'] = jsonDecode['check_id'];
}
