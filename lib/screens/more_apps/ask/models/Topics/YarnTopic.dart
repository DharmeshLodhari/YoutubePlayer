import 'dart:io';

class YarnTopic {
  YarnTopic({
   this.id,
   this.tags,
   this.authorName,
   this.authorAvatar,
   this.createdAt,
   this.updatedAt,
   this.title,
   this.body,
   this.media,
   this.author,
   this.status,
   this.numberOfAnswers,
   this.viewersAvatars,
   this.isQuestion,
   this.numberOfComments,
   this.enablePayme,
   this.voteCount,
   this.downVoteCount,
   this.authorIsVerified,
   this.enableCommenting
  });
  YarnTopic.fromJson(dynamic json) {
    id = json['id'];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    authorName = json['author_name'];
    authorAvatar = json['author_avatar'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    title = json['title'];
    body = json['body'];
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media?.add(Media.fromJson(v));
      });
    }
    author = json['author'];
    status = json['status'];
    numberOfAnswers = json['number_of_answers'];
    if (json['viewers_avatars'] != null) {
      viewersAvatars = [];
      json['viewers_avatars'].forEach((v) {
        viewersAvatars?.add(ViewersAvatars.fromJson(v));
      });
    }
    isQuestion = json['is_question'];
    numberOfComments = json['number_of_comments'];
    enablePayme = json['enable_payme'];
    voteCount = json['vote_count'];
    downVoteCount = json['down_vote_count'];
    authorIsVerified = json['author_is_verified'];
    enableCommenting = json['enable_commenting'];
  }

  String? id;
  List<String>? tags;
  String? authorName;
  String? authorAvatar;
  String? createdAt;
  dynamic updatedAt;
  String? title;
  String? body;
  List<Media>? media;
  String? author;
  String? status;
  int? numberOfAnswers;
  List<ViewersAvatars>? viewersAvatars;
  bool? isQuestion;
  int? numberOfComments;
  bool? enablePayme;
  int? voteCount;
  int? downVoteCount;
  bool? authorIsVerified;
  bool? enableCommenting;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['tags'] = tags;
    map['author_name'] = authorName;
    map['author_avatar'] = authorAvatar;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['title'] = title;
    map['body'] = body;
    if (media != null) {
      map['media'] = media?.map((v) => v.toJson()).toList();
    }
    map['author'] = author;
    map['status'] = status;
    map['number_of_answers'] = numberOfAnswers;
    if (viewersAvatars != null) {
      map['viewers_avatars'] = viewersAvatars?.map((v) => v.toJson()).toList();
    }
    map['is_question'] = isQuestion;
    map['number_of_comments'] = numberOfComments;
    map['enable_payme'] = enablePayme;
    map['vote_count'] = voteCount;
    map['down_vote_count'] = downVoteCount;
    map['author_is_verified'] = authorIsVerified;
    map['enable_commenting'] = enableCommenting;
    return map;
  }
}

class Media {
  Media({this.file,});

  Media.fromJson(dynamic json) {
    file = json['file'];
  }
  String? file;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['file'] = file;
    return map;
  }

}

class ViewersAvatars {
  ViewersAvatars({
    this.username,
    this.avatar,});

  ViewersAvatars.fromJson(dynamic json) {
    username = json['username'];
    avatar = json['avatar'];
  }
  String? username;
  String? avatar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['avatar'] = avatar;
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