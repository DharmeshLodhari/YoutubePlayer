import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';

class ChatUserManager {
  DatabaseHelper _db = DatabaseHelper();

  void addUsers(List<CustomerProfile> users) {
    List<ChatUserModel> dbUsers = [];

    /// Converting CustomerProfile in to Chat Users
    users.forEach(
        (user) => dbUsers.add(ChatUserModel.fromCustomerProfile(user)));

    /// adding Chat User into DataBase
    _db.saveChatUsers(dbUsers);
  }

  void addUser(CustomerProfile user) {
    /// Converting CustomerProfile in to Chat Users
    ChatUserModel chatUserModel = ChatUserModel.fromCustomerProfile(user);

    /// adding Chat User into DataBase
    _db.saveChatUser(chatUserModel);
  }

  Future<ChatUserModel> getUser(String conversationId) async {
    Map<String, dynamic> user = await _db.getChatUser(conversationId);

    ChatUserModel chatUserModel = ChatUserModel.fromJson(user);

    return chatUserModel;
  }

  void clearChatUsers() async {
    await _db.deleteChatUsers();
  }

  void updateChatUserMessageCount(
      {String conversationId, String hashedMessage}) async {
    await _db.updateChatUserMessageCount(
        conversationId: conversationId, hashedMessage: hashedMessage);
  }

  void clearChatUserMessageCount({String conversationId}) async {
    var result =
        await _db.clearChatUserMessageCount(conversationId: conversationId);
    debugPrint("Result:--------- $result");
  }
}
