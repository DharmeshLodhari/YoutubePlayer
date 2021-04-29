import 'dart:ffi';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';

class ConnectionListManager {
  DatabaseHelper _db = DatabaseHelper();

  ///Store Connections in to the db
  Future<void> saveConnectionsToDB({List<ChatConversation> connections}) async {
    await _db.saveUserConnections(connections);
  }

  ///Clear stored connections From db
  Future<void> clearConnections() async {
    await _db.clearUserConnections();
    return Future.value(Void);
  }

  ///Get Connections From db
  Future<List<ChatConversation>> getConnectionsFromDB() async {
    return await _db.getUserConnections();
  }

  ///Get Connections Count
  Future<int> getConnectionsCount() async {
    return await _db.getUserConnectionsCount();
  }

  ///Update LastMessage time in Db
  Future<int> updateLastMessageTime({String conversationId, int time}) async {
    return await _db.updateConnectionListLastMessageTime(
        conversationId: conversationId, time: time);
  }

  Future<int> updateChatConversation({ChatConversation chatConversation}) async{
    return await _db.updateChatConversation(chatConversation:chatConversation);
  }
}
