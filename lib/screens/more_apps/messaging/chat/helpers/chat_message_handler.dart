import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:flutter/foundation.dart';

/// This helper will perform all db operation related to chat message
class ChatMessageHandler {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<ChatMessage>> saveChatMessages(
      {required List<String> messages}) async {
    debugPrint('SAVE CHAT MESSAGE --->');

    final List<ChatMessage> chatMessages = [];

    /// Converting CustomerProfile in to Chat Users
    messages.forEach((message) =>
        chatMessages.add(ChatMessage.fromJson(jsonDecode(message))));

    /// adding Chat User into DataBase
    final List<ChatMessage> insertedMessages =
        await _db.saveChatMessage(chatMessages);

    return insertedMessages;
  }

  Future<List> insertMissedChatMessages(
      {required List<ChatMessage> messages}) async {
    /// adding Chat User into DataBase

    return await _db.insertMissedMessages(messages);
  }

  Future<int> insertMissedChatMessage(
      {required ChatMessage chatMessage}) async {
    /// adding Chat User into DataBase

    return await _db.insertMissedMessage(chatMessage);
  }

  Future<List<ChatMessage>> getChatMessages(
      {required ChatConversation chatConversation}) async {
    List<ChatMessage> chatMessages;

    chatMessages =
        await _db.getChatMessages(chatConversation: chatConversation);
    return chatMessages;
  }

  Future<List<ChatMessage>> getLimitedChatMessages(
      {String? conversationId, int? limit}) async {
    List<ChatMessage> chatMessages;

    chatMessages = await _db.getLimitedChatMessages(
        conversationId: conversationId, limit: limit);
    return chatMessages;
  }

  Future<int> updateReadByRecipientChatMessage(
      {String? checkId, String? conversationId}) async {
    return await _db.updateChatMessageReadByRecipient(checkId, conversationId);
  }

  Future<int> updateDeliverStatusOfChatMessage(
      {String? checkId, String? conversationId}) async {
    return await _db.updateChatMessageDeliverStatus(checkId, conversationId);
  }

  Future<int> addChatMessage({required ChatMessage chatMessage}) async {
    return await _db.insertSingleChatMessage(chatMessage);
  }

  Future<int> updateChatMessage({required ChatMessage chatMessage}) async {
    return await _db.updateSingleChatMessage(chatMessage);
  }

  Future<int> deleteChatMessages() async {
    return await _db.deleteChatMessages();
  }

  Future<int> deleteChatMessage(
      {String? checkId, String? conversationId}) async {
    return await _db.deleteChatMessage(checkId, conversationId);
  }

  Future<bool> checkIfMessageExist(
      {required String checkId, required String conversationId}) async {
    final List<ChatMessage> messages =
        await _db.getChatMessagesByConversationIdAndCheckId(
      checkId: checkId,
      conversationId: conversationId,
    );

    if (messages.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<int> updateEditedChatMessage(
      {String? checkId,
      String? conversationId,
      bool? wasEdited,
      String? text}) async {
    return await _db.updateEditedChatMessage(
        checkId, conversationId, wasEdited, text);
  }

  Future<ChatMessagePagination> getChatMessagePagination(
      {String? conversationId}) async {
    final ChatMessagePagination chatMessagePagination =
        await _db.getChatMessagePagination(conversationId);
    return chatMessagePagination;
  }

  Future<int> saveChatMessagePagination(
      {required ChatMessagePagination chatMessagePagination}) async {
    return await _db.saveChatMessagePagination(chatMessagePagination);
  }

  Future<void> updateChatMessagePagination(
      {required ChatMessagePagination chatMessagePagination}) async {
    await _db.updateChatMessagePagination(chatMessagePagination);
    return Future.value();
  }

  Future<List<ChatMessage>?> getLastChatMessage() async {
    return await _db.getLastChatMessage();
  }
}
