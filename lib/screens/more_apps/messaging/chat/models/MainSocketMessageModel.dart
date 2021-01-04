class MainSocketMessageModel {
  String author;
  String conversation;
  String createdAt;
  bool deletedForAuthor;
  bool deletedForRecipient;
  bool delivered;
  String id;
  String kind;
  bool readByAuthor;
  bool readByRecipient;
  String text;
  String type;
  String updatedAt;
  bool wasEdited;

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
      conversation: json['conversation'],
      createdAt: json['created_at'],
      deletedForAuthor: json['deleted_for_author'],
      deletedForRecipient: json['deleted_for_recipient'],
      delivered: json['delivered'],
      id: json['id'],
      kind: json['kind'],
      readByAuthor: json['read_by_author'],
      readByRecipient: json['read_by_recipient'],
      text: json['text'],
      type: json['type'],
      updatedAt: json['updated_at'],
      wasEdited: json['was_edited'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
}
