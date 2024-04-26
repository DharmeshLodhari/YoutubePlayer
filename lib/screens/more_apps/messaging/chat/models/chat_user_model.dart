import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:crypto/crypto.dart';

class ChatUserModel {
  String? conversationId;
  int? messageCount;
  String? hashedMessage;

  ChatUserModel(
      {String? conversationId, int? messageCount, String? hashedMessage}) {
    this.conversationId = conversationId;
    this.messageCount = messageCount;
    this.hashedMessage =
        hashedMessage ?? generateHashedMessage(input: conversationId!);
  }

  String generateHashedMessage({String input = ""}) {
    return md5.convert(utf8.encode(input)).toString();
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
        conversationId: json['conversationId'],
        messageCount: json['messageCount'],
        hashedMessage: json['hashedMessage']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationId'] = conversationId;
    data['messageCount'] = messageCount;
    data['hashedMessage'] = hashedMessage;
    return data;
  }

  factory ChatUserModel.fromChatConversation(ChatConversation user) {
    return ChatUserModel(
      conversationId: user.conversationId,
      messageCount: 0,
    );
  }
  factory ChatUserModel.fromConversationId(String? conversationId) {
    return ChatUserModel(
      conversationId: conversationId,
      messageCount: 0,
    );
  }
}
