import 'Media.dart';

class ChatMessage {
  String author;
  String conversation;
  DateTime createdAt;
  String id;
  bool isRead;
  Media media;
  String text;
  DateTime updatedAt;
  bool edited;

  ChatMessage(
      {this.author,
      this.conversation,
      this.createdAt,
      this.id,
      this.isRead,
      this.media,
      this.text,
      this.updatedAt,
      this.edited});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      author: json['author'],
      conversation: json['conversation'],
      createdAt: DateTime(json['created_at']),
      id: json['id'],
      isRead: json['is_read'],
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      text: json['text'],
      updatedAt: DateTime(json['updated_at']),
      edited: json['was_edited'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['author'] = this.author;
    data['conversation'] = this.conversation;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['is_read'] = this.isRead;
    data['text'] = this.text;
    data['updated_at'] = this.updatedAt;
    data['was_edited'] = this.edited;
    if (this.media != null) {
      data['media'] = this.media.toJson();
    }
    return data;
  }
}
