import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';

class ChatUserManager {
  DatabaseHelper _db = DatabaseHelper();

  void addUsers(List<ChatConversation> users) {
    List<ChatUserModel> dbUsers = [];

    /// Converting CustomerProfile in to Chat Users
    users.forEach(
        (user) => dbUsers.add(ChatUserModel.fromChatConversation(user)));

    /// adding Chat User into DataBase
    _db.saveChatUserCount(dbUsers);
  }

  Future<void> addUser({String conversationId}) async {
    /// Converting CustomerProfile in to Chat Users

    ChatUserModel chatUserModel =
        ChatUserModel.fromConversationId(conversationId);

    /// adding Chat User into DataBase
    await _db.saveChatUser(chatUserModel);
    return;
  }

  Future<ChatUserModel> getUser(String conversationId) async {
    Map<String, dynamic> user = await _db.getChatUser(conversationId);

    ChatUserModel chatUserModel = ChatUserModel.fromJson(user);

    return chatUserModel;
  }

  Future<int> clearChatUsers() async {
    return await _db.deleteChatUsers();
  }

  Future<void> updateChatUserMessageCount(
      {String conversationId, String hashedMessage}) async {
    await _db.updateChatUserMessageCount(
        conversationId: conversationId, hashedMessage: hashedMessage);
    return;
  }

  void clearChatUserMessageCount({String conversationId}) async {
    await _db.clearChatUserMessageCount(conversationId: conversationId);
    return;
  }

  Future<bool> checkForChatMessagesCount() async {
    int count = await _db.getChatMessageCount();

    if (count > 0) return true;

    return false;
  }
}
