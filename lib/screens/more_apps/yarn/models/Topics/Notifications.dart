class Notifications {
  Notifications({
    this.id,
    this.authorUserName,
    this.authorName,
    this.authorAvatar,
    this.type,
    this.title,
    this.body,
    this.createdAt,
    this.yarn,});

  Notifications.fromJson(dynamic json) {
    id = json['id'];
    authorUserName = json['author_username'];
    authorName = json['author_name'];
    authorAvatar = json['author_avatar'];
    type = json['type'];
    title = json['title'];
    body = json['body'];
    createdAt = json['created_at'];
    yarn = json['yarn'];
  }
  String? id;
  String? authorUserName;
  String? authorName;
  String? authorAvatar;
  String? type;
  String? title;
  String? body;
  String? createdAt;
  String? yarn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['author_username'] = authorUserName;
    map['author_name'] = authorName;
    map['author_avatar'] = authorAvatar;
    map['type'] = type;
    map['title'] = title;
    map['body'] = body;
    map['created_at'] = createdAt;
    map['yarn'] = yarn;
    return map;
  }

}