import 'dart:convert';
import 'dart:io';

import '../../../../../main.dart';
import '../ask_categories_model.dart';

class Yarn {
  Yarn({
    this.id,
    this.tags,
    this.authorName,
    this.authorAvatar,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.body,
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
    this.category,
    this.media = const [],
    this.attachment,
    this.attachmentType,
    this.userUpvoted = false,
    this.userReyarned = false,
    this.userSupported = false,
    this.userDownVoted = false,
    this.ageRestriction,
    this.isAdultContent = false,
    this.isSensitiveContent = false,
    this.factChecked = false,
  });

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
        media.add(YarnMedia.fromJson(v));
      });
    } else if (json['image'] != null) {
      media = [];
      json['image'].forEach((v) {
        media.add(YarnMedia.fromJson(v));
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
    factChecked = json['fact_checked'];
    ageRestriction = json['age_restriction'];
    numberOfReYarn = json['numbers_of_reyarn'];
    if (json['reyarn'] != null) {
      reYarn = Yarn.fromJson(json['reyarn']);
    }
    if (json['attachment'] != null) {
      Map<String, dynamic> item;

      if (json['attachment'] is String) {
        item = jsonDecode(json['attachment']);
      } else if (json['attachment'] is Map) {
        item = json['attachment'];
      } else {
        item = {};
      }

      if (item['service'] != null) {
        attachmentType = 'service';
        attachment = item['service'];
      } else if (item['blog'] != null) {
        attachmentType = 'blog';
        attachment = item['blog'];
      } else if (item['product'] != null) {
        attachmentType = 'product';
        attachment = item['product'];
      } else if (item['profile'] != null) {
        attachmentType = 'profile';
        attachment = item['profile'];
      }
    }
    if (json['user_upvoted'] != null) {
      userUpvoted = json['user_upvoted'];
    }
    if (json['user_reyarned'] != null) {
      userReyarned = json['user_reyarned'];
    }
    if (json['user_supported'] != null) {
      userSupported = json['user_supported'];
    }
    if (json['user_down_voted'] != null) {
      userDownVoted = json['user_down_voted'];
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
  Yarn? reYarn;
  int? numberOfReYarn;
  List<YarnMedia> media = <YarnMedia>[];
  Map<String, dynamic>? attachment = {};
  String? attachmentType;
  bool userUpvoted = false;
  bool userReyarned = false;
  bool userSupported = false;
  bool userDownVoted = false;
  bool? enableCommenting;
  bool? isSensitiveContent;
  bool? isAdultContent;
  dynamic ageRestriction;
  bool? factChecked;

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
    map['fact_checked'] = factChecked;
    map['age_restriction'] = ageRestriction;
    map['numbers_of_reyarn'] = numberOfReYarn;
    if (reYarn != null) {
      map['reyarn'] = reYarn!.toJson();
    }
    map['user_upvoted'] = userUpvoted;
    map['user_reyarned'] = userReyarned;
    map['user_supported'] = userSupported;
    map['user_down_voted'] = userDownVoted;

    if (attachment != null) {
      map['attachment'] = attachment;
    }



    return map;
  }

  Map<String, dynamic> toAddMap() {
    return {
      if (tags != null) "tags": tags,
      if (title != null) "title": title,
      if (body != null) "body": body,
      if (category != null) "category": category,
      if (author != null) "author": author,
      if (isQuestion != null) "is_question": isQuestion,
      if (enablePayMe != null) "enable_payme": enablePayMe,
      if (enableCommenting != null) "enable_commenting": enableCommenting,
      if (attachment != null) "attachment": attachment,
      if (isSensitiveContent != null)
        "is_sensitive_content": isSensitiveContent,
      if (isAdultContent != null) "is_adult_content": isAdultContent,
      if (ageRestriction != null) "age_restriction": ageRestriction
    };
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

class YarnMedia {
  File? mediaFile;
  File? posterFile;
  String? mediaType;
  String? mediaPoster;
  String? id;
  String? mediaUrl;

  YarnMedia({
    this.mediaFile,
    this.mediaType,
    this.mediaPoster,
    this.posterFile,
  });

  YarnMedia.fromJson(dynamic json) {
    id = json['id'];
    mediaUrl = json['file'] ??  json['mediaUrl'];
    mediaType = json['type'] ??  json['mediaType'];
    mediaPoster = json['image_poster'] ??  json['mediaPoster'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "mediaUrl": mediaUrl,
      "mediaType": mediaType,
      "mediaPoster": mediaPoster,
    };
  }
}
