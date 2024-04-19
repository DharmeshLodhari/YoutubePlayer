import 'dart:convert';

class MainSocketMessageModel {
  String? author;
  String? conversation;
  String? createdAt;
  bool? deletedForAuthor;
  bool? deletedForRecipient;
  bool? delivered;
  String? id;
  String? kind;
  bool? readByAuthor;
  bool? readByRecipient;
  String? text;
  String? type;
  String? updatedAt;
  bool? wasEdited;

  MainSocketMessageModel(
      {this.author,
      this.conversation,
      this.createdAt,
      this.deletedForAuthor,
      this.deletedForRecipient,
      this.delivered,
      this.id,
      this.kind,
      this.readByAuthor,
      this.readByRecipient,
      this.text,
      this.type,
      this.updatedAt,
      this.wasEdited});

  factory MainSocketMessageModel.fromJson(Map<String, dynamic> json) {
    return MainSocketMessageModel(
      author: json['author'],
      conversation: json['conversation'] ?? json['conversation_id'],
      createdAt: json['created_at'],
      deletedForAuthor: json['deleted_for_author'],
      deletedForRecipient: json['deleted_for_recipient'],
      delivered: json['delivered'],
      id: json['id'],
      kind: json['kind'],
      readByAuthor: json['read_by_author'],
      readByRecipient: json['read_by_recipient'],
      text: json['text'] is String ? json['text'] : jsonEncode(json['text']),
      type: json['type'],
      updatedAt: json['updated_at'],
      wasEdited: json['was_edited'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['author'] = this.author;
    data['conversation'] = this.conversation;
    data['created_at'] = this.createdAt;
    data['deleted_for_author'] = this.deletedForAuthor;
    data['deleted_for_recipient'] = this.deletedForRecipient;
    data['delivered'] = this.delivered;
    data['id'] = this.id;
    data['kind'] = this.kind;
    data['read_by_author'] = this.readByAuthor;
    data['read_by_recipient'] = this.readByRecipient;
    data['text'] = this.text;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['was_edited'] = this.wasEdited;
    return data;
  }

  Map<String, dynamic> toHashedJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['author'] = this.author;
    data['conversation'] = this.conversation;
    data['created_at'] = generateCreatedAt();
    data['updated_at'] = generateUpdatedAt();
    data['deleted_for_author'] = this.deletedForAuthor;
    data['deleted_for_recipient'] = this.deletedForRecipient;
    data['delivered'] = this.delivered;
    data['kind'] = this.kind;
    data['read_by_author'] = this.readByAuthor;
    data['read_by_recipient'] = this.readByRecipient;
    data['text'] = this.text;
    data['type'] = this.type;
    data['was_edited'] = this.wasEdited;
    return data;
  }

  String generateCreatedAt() {
    final DateTime createdAtDate =
        DateTime.parse(createdAt ?? DateTime.now().toString());

    final DateTime messageDateTillSecond = DateTime(
      createdAtDate.year,
      createdAtDate.month,
      createdAtDate.day,
      createdAtDate.hour,
      createdAtDate.minute,
      createdAtDate.second,
    );

    return messageDateTillSecond.toString();
  }

  String generateUpdatedAt() {
    final DateTime updatedAtDate =
        DateTime.parse(updatedAt ?? DateTime.now().toString());

    final DateTime messageDateTillSecond = DateTime(
      updatedAtDate.year,
      updatedAtDate.month,
      updatedAtDate.day,
      updatedAtDate.hour,
      updatedAtDate.minute,
      updatedAtDate.second,
    );

    return messageDateTillSecond.toString();
  }
}
