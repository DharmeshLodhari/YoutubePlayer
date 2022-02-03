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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['actions'] = this.actions;
    data['author'] = this.author;
    data['author_avatar'] = this.authorAvatar;
    data['check_id'] = this.checkId;
    data['conversation_id'] = this.conversationId;
    data['created_at'] = this.createdAt;
    data['notification_id'] = this.notificationId;
    data['recipient'] = this.recipient;
    data['recipient_username'] = this.recipientUsername;
    data['type'] = this.type;
    return data;
  }
}
