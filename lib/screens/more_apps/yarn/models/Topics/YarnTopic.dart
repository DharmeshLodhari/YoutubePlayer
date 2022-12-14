import 'dart:io';

import '../ask_categories_model.dart';

class Yarn {
  Yarn(
      {this.id,
      this.tags,
      this.authorName,
      this.authorAvatar,
      this.createdAt,
      this.updatedAt,
      this.title,
      this.body,
      this.media = const [],
      this.author,
      this.status,
      this.numberOfAnswers,
      this.viewersAvatars,
      this.isQuestion = false,
      this.numberOfComments,
      this.enablePayMe,
      this.voteCount,
      this.downVoteCount,
      this.authorIsVerified,
      this.enableCommenting,
      this.category});

  Yarn.fromJson(dynamic json) {
    id = json['id'];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    if (json['category'] != null) {
      category = YarnCategories.fromJson(json['category']);
    }
    authorName = json['author_name'];
    authorAvatar = json['author_avatar'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    title = json['title'];
    if (json['body'] == null) {
      if (json['description'] != null) {
        body = json['description'];
      }
    } else {
      body = json['body'];
    }

    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media.add(MediaFiles.fromJson(v));
      });
    } else if (json['image'] != null) {
      media = [];
      json['image'].forEach((v) {
        media.add(MediaFiles.fromJson(v));
      });
    }
    if (json['author'] == null) {
      if (json['author_username'] != null) {
        author = json['author_username'];
      }
    } else {
      author = json['author'];
    }
    status = json['status'];
    numberOfAnswers = json['number_of_answers'];
    if (json['viewers_avatars'] != null) {
      viewersAvatars = [];
      json['viewers_avatars'].forEach((v) {
        viewersAvatars?.add(ViewersAvatars.fromJson(v));
      });
    }
    isQuestion = json['is_question'] ?? false;
    numberOfComments = json['number_of_comments'];
    enablePayMe = json['enable_payme'];
    voteCount = json['vote_count'];
    downVoteCount = json['down_vote_count'];
    authorIsVerified = json['author_is_verified'];
    enableCommenting = json['enable_commenting'];
    isSensitiveContent = json['is_sensitive_content'];
    isAdultContent = json['is_adult_content'];
    ageRestriction = json['age_restriction'];
    numberOfReYarn = json['numbers_of_reyarn'];
    if (json['reyarn'] != null) {
      reYarn = Yarn.fromJson(json['reyarn']);
    }
  }

  String? id;
  List<String>? tags;
  YarnCategories? category;
  String? authorName;
  String? authorAvatar;
  String? createdAt;
  dynamic updatedAt;
  String? title;
  String? body;
  List<MediaFiles> media = [];
  String? author;
  String? status;
  int? numberOfAnswers;
  List<ViewersAvatars>? viewersAvatars;
  bool isQuestion = false;
  int? numberOfComments;
  bool? enablePayMe;
  int? voteCount;
  int? downVoteCount;
  bool? authorIsVerified;
  bool? enableCommenting;
  bool? isSensitiveContent;
  bool? isAdultContent;
  int? ageRestriction;
  Yarn? reYarn;
  int? numberOfReYarn;

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

    map['media'] = media.map((v) => v.toJson()).toList();

    map['author'] = author;
    map['status'] = status;
    map['number_of_answers'] = numberOfAnswers;
    if (viewersAvatars != null) {
      map['viewers_avatars'] = viewersAvatars?.map((v) => v.toJson()).toList();
    }
    map['is_question'] = isQuestion;
    map['number_of_comments'] = numberOfComments;
    map['enable_payme'] = enablePayMe;
    map['vote_count'] = voteCount;
    map['down_vote_count'] = downVoteCount;
    map['author_is_verified'] = authorIsVerified;
    map['enable_commenting'] = enableCommenting;
    map['category'] = category;
    map['is_sensitive_content'] = isSensitiveContent;
    map['is_adult_content'] = isAdultContent;
    map['age_restriction'] = ageRestriction;
    map['numbers_of_reyarn'] = numberOfReYarn;
    if (reYarn != null) {
      map['reyarn'] = reYarn!.toJson();
    }
    return map;
  }
}

class MediaFiles {
  MediaFiles({
    this.file,
  });

  MediaFiles.fromJson(dynamic json) {
    file = json['file'];
    imagePoster = json['image_poster'];
    mediaType = json['type'];
  }
  String? file;
  String? imagePoster;
  String? mediaType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['file'] = file;
    map['image_poster'] = imagePoster;
    map['type'] = mediaType;
    return map;
  }
}

class ViewersAvatars {
  ViewersAvatars({
    this.username,
    this.avatar,
  });

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
  List<AddMediaForYarn>? localImages;
  List<String>? tags;
  String? categoryId;
  String? title;
  String? body;
  String? author;
  bool? isQuestion;
  bool? enablePayme;
  bool? enableCommenting;

  AddYarnAndQuestion(
      {this.localImages,
      this.tags,
      this.categoryId,
      this.title,
      this.body,
      this.isQuestion,
      this.author,
      this.enablePayme,
      this.enableCommenting});

  Map<String, dynamic> toAddMap() {
    return {
      "tags": tags,
      "title": title,
      "body": body,
      "category": categoryId,
      "author": author,
      "is_question": isQuestion,
      "enable_payme": enablePayme,
      "enable_commenting": enableCommenting
    };
  }
}

class AddMediaForYarn {
  File? mediaFile;
  String? mediaType;
  String? mediaPoster;

  AddMediaForYarn({this.mediaFile, this.mediaType, this.mediaPoster});
}
