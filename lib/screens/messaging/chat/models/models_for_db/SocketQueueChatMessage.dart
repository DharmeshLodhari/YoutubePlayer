import 'dart:convert';

class SocketQueueChatMessage {
  String? author;
  String? authorName;
  String? authorAvatar;
  String? checkId;
  String? conversationId;
  String? createdAt;
  bool? delivered;
  String? kind;
  String? message;
  bool? readByAuthor;
  bool? readByRecipient;
  String? type;
  String? repliedTo;

  SocketQueueChatMessage(
      {this.author,
      this.authorName,
      this.authorAvatar,
      this.checkId,
      this.conversationId,
      this.createdAt,
      this.delivered,
      this.kind,
      this.message,
      this.readByAuthor,
      this.readByRecipient,
      this.type,
      this.repliedTo});

  factory SocketQueueChatMessage.fromJson(Map<String, dynamic> json) {
    return SocketQueueChatMessage(
        author: json['author'],
        authorAvatar: json['author_avatar'],
        authorName: json['author_full_name'],
        checkId: json['check_id'],
        conversationId: json['conversation_id'],
        createdAt: json['created_at'],
        delivered: json['delivered'] == 1 ? true : false,
        kind: json['kind'],
        message: json['message'],
        readByAuthor: json['read_by_author'] == 1 ? true : false,
        readByRecipient: json['read_by_recipient'] == 1 ? true : false,
        type: json['type'],
        repliedTo: json['replied_to'] is Map
            ? jsonEncode(json['replied_to'])
            : json['replied_to']);
  }

  Map<String, dynamic> toJson({bool isForSendingToSocket = false}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['author_avatar'] = authorAvatar;
    data['author_full_name'] = authorName;
    data['check_id'] = checkId;
    data['conversation_id'] = conversationId;
    data['created_at'] = createdAt;
    data['delivered'] = delivered!
        ? isForSendingToSocket
            ? true
            : 1
        : isForSendingToSocket
            ? false
            : 0;
    data['kind'] = kind;
    data['message'] = message;
    data['read_by_author'] = readByAuthor!
        ? isForSendingToSocket
            ? true
            : 1
        : isForSendingToSocket
            ? false
            : 0;
    data['read_by_recipient'] = readByRecipient!
        ? isForSendingToSocket
            ? true
            : 1
        : isForSendingToSocket
            ? false
            : 0;
    data['type'] = type;
    data['replied_to'] = repliedTo;
    return data;
  }
}
