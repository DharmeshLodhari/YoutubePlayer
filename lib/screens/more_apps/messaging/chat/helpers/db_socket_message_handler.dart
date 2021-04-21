import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatTextMessage.dart';
import 'package:flutter/material.dart';

class DBSocketMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  void saveMessageToDb({ChatTextMessage message}) async {
    await _db.saveChatTextMessage(message: message);
    List<ChatTextMessage> chatTextMessage = await getChatTextMessage();
    debugPrint("Length of Pending Messages 1 :- ${chatTextMessage.length}");
  }

  Future<List<ChatTextMessage>> getChatTextMessage() async {
    return await _db.getChatTextMessages();
  }

  void deleteChatTextMessage({ChatTextMessage message}) async {
    // sendPendingQueueMessages();
    await _db.deleteChatTextMessage(message: message);

    List<ChatTextMessage> chatTextMessage = await getChatTextMessage();
    debugPrint("Length of Pending Messages 2 :- ${chatTextMessage.length}");
  }

  void clearChatTextMessage() async {
    await _db.clearChatTextMessage();
    getChatTextMessage();
  }
}
