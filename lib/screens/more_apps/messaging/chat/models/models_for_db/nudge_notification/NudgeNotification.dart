class NudgeNotification {
  String? actions;
  String? author;
  String? authorAvatar;
  String? checkId;
  String? conversationId;
  String? createdAt;
  String? notificationId;
  String? recipient;
  String? recipientUsername;
  String? type;

  NudgeNotification(
      {this.actions,
      this.author,
      this.authorAvatar,
      this.checkId,
      this.conversationId,
      this.createdAt,
      this.notificationId,
      this.recipient,
      this.recipientUsername,
      this.type});

  factory NudgeNotification.fromJson(Map<String, dynamic> json) {
    return NudgeNotification(
      actions: json['actions'],
      author: json['author'],
      authorAvatar: json['author_avatar'],
      checkId: json['check_id'],
      conversationId: json['conversation_id'],
      createdAt: json['created_at'],
      notificationId: json['notification_id'],
      recipient: json['recipient'],
      recipientUsername: json['recipient_username'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['actions'] = actions;
    data['author'] = author;
    data['author_avatar'] = authorAvatar;
    data['check_id'] = checkId;
    data['conversation_id'] = conversationId;
    data['created_at'] = createdAt;
    data['notification_id'] = notificationId;
    data['recipient'] = recipient;
    data['recipient_username'] = recipientUsername;
    data['type'] = type;
    return data;
  }
}
