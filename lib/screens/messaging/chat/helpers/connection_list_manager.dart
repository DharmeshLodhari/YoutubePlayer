import 'dart:ffi';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';

/// For performing all the db operation related to user's connections
class ConnectionListManager {
  final DatabaseHelper _db = DatabaseHelper();

  ///Store Connections in to the db
  Future<void> saveConnectionsToDB(
      {required List<ChatConversation> connections}) async {
    await _db.saveUserConnections(connections);
    return Future.value();
  }

  ///Store Missed connection in the  db
  Future<void> saveMissedConnectionsToDB(
      {required List<ChatConversation> connections}) async {
    await _db.saveMissedUserConnections(connections);
    return;
  }

  ///Store Single Connection to db
  Future<int> addConnectionToDB(
      {required ChatConversation chatConversation}) async {
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
  Future<int> updateLastMessageTime({String? conversationId, int? time}) async {
    return await _db.updateConnectionListLastMessageTime(
        conversationId: conversationId, time: time);
  }

  Future<int> updateChatConversation(
      {required ChatConversation chatConversation}) async {
    return await _db.updateChatConversation(chatConversation: chatConversation);
  }

  Future<int> deleteChatConversation({String? conversationId}) async {
    return await _db.deleteChatConversation(conversationId: conversationId);
  }

  Future<ChatConversation?> getLastChatConversation() async {
    return await _db.getLastChatConversation();
  }

  ///Get Searched Connections From db
  Future<List<ChatConversation>> getSearchedConnectionsFromDB(
      {String? searchedText}) async {
    return await _db.getSearchedUserConnections(searchedText: searchedText);
  }

  Future<List<String>> listConnectionsFromDB() async {
    return await _db.listUserConnections();
  }

  Future<bool> checkUserInConnectionFromDB(
      {required String searchedText}) async {
    return await _db.checkUserInConnection(searchedText: searchedText);
  }
}
