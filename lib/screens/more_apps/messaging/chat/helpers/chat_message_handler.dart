import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';

class ChatMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  Future<List<ChatMessage>> saveChatMessages({List<String> messages}) async {
    List<ChatMessage> chatMessages = [];

    /// Converting CustomerProfile in to Chat Users
    messages.forEach((message) =>
        chatMessages.add(ChatMessage.fromJson(jsonDecode(message))));

    /// adding Chat User into DataBase
    List<ChatMessage> insertedMessages =
        await _db.saveChatMessage(chatMessages);
    return insertedMessages;
  }

  Future<List> insertMissedChatMessages({List<ChatMessage> messages}) async {
    /// adding Chat User into DataBase

    return await _db.insertMissedMessages(messages);
  }

  Future<int> insertMissedChatMessage({ChatMessage chatMessage}) async {
    /// adding Chat User into DataBase

    return await _db.insertMissedMessage(chatMessage);
  }

  Future<List<ChatMessage>> getChatMessages(
      {ChatConversation chatConversation}) async {
    List<ChatMessage> chatMessages;

    chatMessages =
        await _db.getChatMessages(chatConversation: chatConversation);
    return chatMessages;
  }

  Future<List<ChatMessage>> getLimitedChatMessages(
      {String conversationId, int limit}) async {
    List<ChatMessage> chatMessages;

    chatMessages = await _db.getLimitedChatMessages(
        conversationId: conversationId, limit: limit);
    return chatMessages;
  }

  Future<int> updateReadByRecipientChatMessage(
      {String checkId, String conversationId}) async {
    return await _db.updateChatMessageReadByRecipient(checkId, conversationId);
  }

  Future<int> updateDeliverStatusOfChatMessage(
      {String checkId, String conversationId}) async {
    return await _db.updateChatMessageDeliverStatus(checkId, conversationId);
  }

  Future<int> addChatMessage({ChatMessage chatMessage}) async {
    return await _db.insertSingleChatMessage(chatMessage);
  }

  Future<void> updateChatMessage({ChatMessage chatMessage}) async {
    return await _db.updateSingleChatMessage(chatMessage);
  }

  Future<int> deleteChatMessages() async {
    return await _db.deleteChatMessages();
  }

  Future<int> deleteChatMessage({String checkId, String conversationId}) async {
    return await _db.deleteChatMessage(checkId, conversationId);
  }

  Future<int> updateEditedChatMessage(
      {String checkId,
      String conversationId,
      bool wasEdited,
      String text}) async {
    return await _db.updateEditedChatMessage(
        checkId, conversationId, wasEdited, text);
  }

  Future<ChatMessagePagination> getChatMessagePagination(
      {String conversationId}) async {
    ChatMessagePagination chatMessagePagination =
        await _db.getChatMessagePagination(conversationId);
    return chatMessagePagination;
  }

  Future<void> saveChatMessagePagination(
      {ChatMessagePagination chatMessagePagination}) async {
    return await _db.saveChatMessagePagination(chatMessagePagination);
  }

  Future<void> updateChatMessagePagination(
      {ChatMessagePagination chatMessagePagination}) async {
    await _db.updateChatMessagePagination(chatMessagePagination);
    return Future.value();
  }

  Future<List<ChatMessage>> getLastChatMessage() async {
    return await _db.getLastChatMessage();
  }
}
