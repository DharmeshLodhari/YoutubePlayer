import 'dart:async';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_user_model.dart';

/// For Performing all the db operation related to user connection's message count
class ChatUserManager {
  final DatabaseHelper _db = DatabaseHelper();

  void addUsers(List<ChatConversation> users) {
    final List<ChatUserModel> dbUsers = [];

    /// Converting CustomerProfile in to Chat Users
    for (var user in users) {
      dbUsers.add(ChatUserModel.fromChatConversation(user));
    }

    /// adding Chat User into DataBase
    _db.saveChatUserCount(dbUsers);
  }

  Future<void> addUser({String? conversationId}) async {
    /// Converting CustomerProfile in to Chat Users

    final ChatUserModel chatUserModel =
        ChatUserModel.fromConversationId(conversationId);

    /// adding Chat User into DataBase
    await _db.saveChatUser(chatUserModel);
    return;
  }

  Future<ChatUserModel?> getUser(String? conversationId) async {
    final Map<String, dynamic>? user = await _db.getChatUser(conversationId);

    if (user != null) {
      final ChatUserModel chatUserModel = ChatUserModel.fromJson(user);

      return chatUserModel;
    }
    return null;
  }

  Future<int> clearChatUsers() async {
    return await _db.deleteChatUsers();
  }

  Future<void> updateChatUserMessageCount(
      {String? conversationId, String? hashedMessage}) async {
    await _db.updateChatUserMessageCount(
        conversationId: conversationId, hashedMessage: hashedMessage);
    return;
  }

  void clearChatUserMessageCount({String? conversationId}) async {
    await _db.clearChatUserMessageCount(conversationId: conversationId);
    return;
  }

  Future<bool> checkForChatMessagesCount() async {
    final int count = await _db.getChatMessageCount();

    if (count > 0) return true;

    return false;
  }
}
