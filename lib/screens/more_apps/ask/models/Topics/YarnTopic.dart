import 'dart:io';

class YarnTopic {
  YarnTopic({
      String? id, 
      List<String>? tags, 
      String? authorName, 
      String? authorAvatar, 
      String? createdAt, 
      dynamic updatedAt, 
      String? title, 
      String? body, 
      dynamic image, 
      String? author, 
      String? status, 
      num? numberOfAnswers,
      List<ViewersAvatars>? viewersAvatars,
      bool? isQuestion,
      int? numberOfComments,
  }){
    _id = id;
    _tags = tags;
    _authorName = authorName;
    _authorAvatar = authorAvatar;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _title = title;
    _body = body;
    _image = image;
    _author = author;
    _status = status;
    _numberOfAnswers = numberOfAnswers;
    _viewersAvatars = viewersAvatars;
    _isQuestion = isQuestion;
    _numberOfComments = numberOfComments;
}

  YarnTopic.fromJson(dynamic json) {
    _id = json['id'];
    _tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    _authorName = json['author_name'];
    _authorAvatar = json['author_avatar'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _title = json['title'];
    _body = json['body'];
    _image = json['image'];
    _author = json['author'];
    _status = json['status'];
    _numberOfAnswers = json['number_of_answers'];
    if (json['viewers_avatars'] != null) {
      _viewersAvatars = [];
      json['viewers_avatars'].forEach((v) {
        _viewersAvatars?.add(ViewersAvatars.fromJson(v));
      });
    }
    _isQuestion = json['is_question'];
    _numberOfComments = json['number_of_comments'];
  }
  String? _id;
  List<String>? _tags;
  String? _authorName;
  String? _authorAvatar;
  String? _createdAt;
  dynamic _updatedAt;
  String? _title;
  String? _body;
  dynamic _image;
  String? _author;
  String? _status;
  num? _numberOfAnswers;
  List<ViewersAvatars>? _viewersAvatars;
  bool? _isQuestion;
  int? _numberOfComments;
YarnTopic copyWith({  String? id,
  List<String>? tags,
  String? authorName,
  String? authorAvatar,
  String? createdAt,
  dynamic updatedAt,
  String? title,
  String? body,
  dynamic image,
  String? author,
  String? status,
  num? numberOfAnswers,
  List<ViewersAvatars>? viewersAvatars,
  bool? isQuestion,
  int? numberOfComments
}) => YarnTopic(  id: id ?? _id,
  tags: tags ?? _tags,
  authorName: authorName ?? _authorName,
  authorAvatar: authorAvatar ?? _authorAvatar,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  title: title ?? _title,
  body: body ?? _body,
  image: image ?? _image,
  author: author ?? _author,
  status: status ?? _status,
  numberOfAnswers: numberOfAnswers ?? _numberOfAnswers,
  viewersAvatars: viewersAvatars ?? _viewersAvatars,
  isQuestion: isQuestion ?? _isQuestion,
  numberOfComments: numberOfComments ?? _numberOfComments,
);
  String? get id => _id;
  List<String>? get tags => _tags;
  String? get authorName => _authorName;
  String? get authorAvatar => _authorAvatar;
  String? get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;
  String? get title => _title;
  String? get body => _body;
  dynamic get image => _image;
  String? get author => _author;
  String? get status => _status;
  num? get numberOfAnswers => _numberOfAnswers;
  List<ViewersAvatars>? get viewersAvatars => _viewersAvatars;
  bool? get isQuestion => _isQuestion;
  int? get numberOfComments => _numberOfComments;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['tags'] = _tags;
    map['author_name'] = _authorName;
    map['author_avatar'] = _authorAvatar;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['title'] = _title;
    map['body'] = _body;
    map['image'] = _image;
    map['author'] = _author;
    map['status'] = _status;
    map['number_of_answers'] = _numberOfAnswers;
    if (_viewersAvatars != null) {
      map['viewers_avatars'] = _viewersAvatars?.map((v) => v.toJson()).toList();
    }
    map['is_question'] = _isQuestion;
    map['number_of_comments'] = _numberOfComments;
    return map;
  }
}

class ViewersAvatars {
  ViewersAvatars({
    String? username,
    String? avatar,}){
    _username = username;
    _avatar = avatar;
  }

  ViewersAvatars.fromJson(dynamic json) {
    _username = json['username'];
    _avatar = json['avatar'];
  }
  String? _username;
  String? _avatar;
  ViewersAvatars copyWith({  String? username,
    String? avatar,
  }) => ViewersAvatars(  username: username ?? _username,
    avatar: avatar ?? _avatar,
  );
  String? get username => _username;
  String? get avatar => _avatar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = _username;
    map['avatar'] = _avatar;
    return map;
  }

}

class AddYarnAndQuestion {
  List<File>? localImages;
  List<String>? tags;
  String? categoryId;
  String? title;
  String? body;
  String? author;
  bool? isQuestion;

  AddYarnAndQuestion({this.localImages, this.tags, this.categoryId, this.title, this.body, this.isQuestion, this.author});

  Map<String, dynamic> toAddMap() {
    return {
      "tags": tags,
      "title": title,
      "body": body,
      "category": categoryId,
      "author": null,
      "is_question": isQuestion,
    };
  }
}