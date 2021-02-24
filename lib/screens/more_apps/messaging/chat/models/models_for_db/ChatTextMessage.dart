class ChatTextMessage {
  String author;
  String checkId;
  String conversationId;
  String createdAt;
  bool delivered;
  String kind;
  String message;
  bool readByAuthor;
  bool readByRecipient;
  String type;

  ChatTextMessage(
      {this.author,
      this.checkId,
      this.conversationId,
      this.createdAt,
      this.delivered,
      this.kind,
      this.message,
      this.readByAuthor,
      this.readByRecipient,
      this.type});

  factory ChatTextMessage.fromJson(Map<String, dynamic> json) {
    return ChatTextMessage(
      author: json['author'],
      checkId: json['check_id'],
      conversationId: json['conversation_id'],
      createdAt: json['created_at'],
      delivered: json['delivered'] == 1 ? true : false,
      kind: json['kind'],
      message: json['message'],
      readByAuthor: json['read_by_author'] == 1 ? true : false,
      readByRecipient: json['read_by_recipient'] == 1 ? true : false,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['author'] = this.author;
    data['check_id'] = this.checkId;
    data['conversation_id'] = this.conversationId;
    data['created_at'] = this.createdAt;
    data['delivered'] = this.delivered ? 1 : 0;
    data['kind'] = this.kind;
    data['message'] = this.message;
    data['read_by_author'] = this.readByAuthor ? 1 : 0;
    data['read_by_recipient'] = this.readByRecipient ? 1 : 0;
    data['type'] = this.type;
    return data;
  }
}
