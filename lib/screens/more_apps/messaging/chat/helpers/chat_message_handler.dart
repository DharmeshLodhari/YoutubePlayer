import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';

class ChatMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  void saveChatMessages({List<String> messages}) {
    List<ChatMessage> chatMessages = [];

    /// Converting CustomerProfile in to Chat Users
    messages.forEach((message) =>
        chatMessages.add(ChatMessage.fromJson(jsonDecode(message))));

    /// adding Chat User into DataBase
    _db.saveChatMessage(chatMessages);
  }

  Future<List<ChatMessage>> getChatMessages(
      {ChatConversation chatConversation}) async {
    List<ChatMessage> chatMessages;

    chatMessages =
        await _db.getChatMessages(chatConversation: chatConversation);
    return chatMessages;
  }
}
