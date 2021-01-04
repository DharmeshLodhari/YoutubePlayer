import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class ChatUserModel {
  String conversationId;
  int isRead;

  /// isRead  0 = unread  1 = read
  int messageCount;

  ChatUserModel({this.conversationId, this.isRead = 0, this.messageCount = 0});

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      conversationId: json['id'],
      isRead: json['isRead'],
      messageCount: json['messageCount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['conversationId'] = this.conversationId;
    data['isRead'] = this.isRead;
    data['messageCount'] = this.messageCount;
    return data;
  }

  factory ChatUserModel.fromCustomerProfile(CustomerProfile user) {
    return ChatUserModel(
      conversationId: user.conversationId,
      isRead: 1,
      messageCount: 0,
    );
  }
}
