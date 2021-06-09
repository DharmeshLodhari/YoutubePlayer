import 'dart:ffi';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';

class ConnectionListManager {
  DatabaseHelper _db = DatabaseHelper();

  ///Store Connections in to the db
  Future<void> saveConnectionsToDB({List<ChatConversation> connections}) async {
    await _db.saveUserConnections(connections);
    return Future.value();
  }

  ///Store Missed connection in the  db
  Future<void> saveMissedConnectionsToDB(
      {List<ChatConversation> connections}) async {
    await _db.saveMissedUserConnections(connections);
    return;
  }

  ///Store Single Connection to db
  Future<int> addConnectionToDB({ChatConversation chatConversation}) async {
    return await _db.addUserConnection(chatConversation: chatConversation);
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

  Future<int> updateChatConversation(
      {ChatConversation chatConversation}) async {
    return await _db.updateChatConversation(chatConversation: chatConversation);
  }

  Future<int> deleteChatConversation({String conversationId}) async {
    return await _db.deleteChatConversation(conversationId: conversationId);
  }

  Future<ChatConversation> getLastChatConversation() async {
    return await _db.getLastChatConversation();
  }

  ///Get Searched Connections From db
  Future<List<ChatConversation>> getSearchedConnectionsFromDB(
      {String searchedText}) async {
    return await _db.getSearchedUserConnections(searchedText: searchedText);
  }
}
