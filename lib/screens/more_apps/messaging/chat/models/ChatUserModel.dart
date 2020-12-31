class ChatUserModel {
  String id;
  int isRead;

  /// isRead  0 = unread  1 = read
  int messageCount;

  ChatUserModel({this.id, this.isRead = 0, this.messageCount = 0});

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'],
      isRead: json['isRead'],
      messageCount: json['messageCount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['isRead'] = this.isRead;
    data['messageCount'] = this.messageCount;
    return data;
  }
}
