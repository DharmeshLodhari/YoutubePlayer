import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:flutter/material.dart';

class DBSocketMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  void saveMessageToDb({SocketQueueChatMessage message}) async {
    await _db.saveSocketQueueChatMessage(message: message);
    List<SocketQueueChatMessage> socketQueueChatMessage =
        await getSocketQueueChatMessage();
    debugPrint(
        "Length of Pending Messages 1 :- ${socketQueueChatMessage.length}");
  }

  Future<List<SocketQueueChatMessage>> getSocketQueueChatMessage() async {
    return await _db.getSocketQueueChatMessages();
  }

  void deleteSocketQueueChatMessage({SocketQueueChatMessage message}) async {
    // sendPendingQueueMessages();
    await _db.deleteSocketQueueChatMessage(message: message);

    List<SocketQueueChatMessage> socketQueueChatMessage =
        await getSocketQueueChatMessage();
    debugPrint(
        "Length of Pending Messages 2 :- ${socketQueueChatMessage.length}");
  }

  void clearSocketQueueChatMessage() async {
    await _db.clearSocketQueueChatMessage();
    getSocketQueueChatMessage();
  }
}
