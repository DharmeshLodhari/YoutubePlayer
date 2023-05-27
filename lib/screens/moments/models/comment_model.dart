import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../more_apps/yarn/models/Topics/yarn_model.dart';

class BasePaginationModel<T> {
  T result;
  int count;
  String? next;
  String? previous;

  BasePaginationModel(
      {required this.next,
      required this.count,
      required this.previous,
      required this.result});

  factory BasePaginationModel.fromJson(Map<String, dynamic> json, T t) {
    return BasePaginationModel(
      result: t,
      next: json['next'],
      count: json['count'],
      previous: json['previous'],
    );
  }
}

class CommentModel extends Equatable {
  String? id;
  String? authorAvatar;
  String? comment;
  String? authorUsername;
  String? authorName;
  bool? isReply;
  int? replyCount;
  String? createdAt;
  bool? isApproved;
  String? replyTo;
  String? socialLikes;
  String? socialDislikes;
  int? likes;
  int? dislikes;
  bool? userLike = false;
  bool? userDisLike = false;
  bool? pinned = false;
  List<YarnMedia> media = [];
  Map<String, dynamic>? attachment;
  String? attachmentType;

  @override
  List<Object?> get props => [
        id,
        authorAvatar,
        comment,
        authorUsername,
        authorName,
        isReply,
        replyCount,
        createdAt,
        isApproved,
        replyTo,
        socialLikes,
        socialDislikes,
        likes,
        dislikes,
        userLike,
        userDisLike,
        media,
        attachment,
        attachmentType
      ];

  CommentModel({
    this.id,
    this.authorAvatar,
    this.comment,
    this.authorUsername,
    this.authorName,
    this.isReply,
    this.replyCount,
    this.createdAt,
    this.isApproved,
    this.replyTo,
    this.socialLikes,
    this.likes,
    this.dislikes,
    this.userLike,
    this.userDisLike,
    this.socialDislikes,
    this.media = const [],
    this.attachment,
    this.attachmentType,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    authorAvatar = json['author_avatar'];
    comment = json['comment'];
    authorUsername = json['author_username'];
    authorName = json['author_name'];
    isReply = json['is_reply'];
    replyCount = json['reply_count'];
    createdAt = json['created_at'];
    isApproved = json['is_approved'];
    replyTo = json['reply_to'];
    socialLikes = json['social_likes'];
    likes = json['likes'] ?? 0;
    dislikes = json['dislikes'] ?? 0;
    socialDislikes = json['social_dislikes'];
    userLike = json['user_liked'];
    userDisLike = json['user_disliked'];
    pinned = json['pinned'] ?? false;
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media.add(YarnMedia.fromJson(v));
      });
    }

    if (json['attachment'] != null) {
      if (json['attachment'] is String) {
        json['attachment'] = jsonDecode(json['attachment']);
      }

      if (json['attachment']['service'] != null) {
        attachmentType = 'service';
        attachment = json['attachment']['service'];
      } else if (json['attachment']['blog'] != null) {
        attachmentType = 'blog';
        attachment = json['attachment']['blog'];
      } else if (json['attachment']['product'] != null) {
        attachmentType = 'product';
        attachment = json['attachment']['product'];
      } else if (json['attachment']['profile'] != null) {
        attachmentType = 'profile';
        attachment = json['attachment']['profile'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['author_avatar'] = authorAvatar;
    data['comment'] = comment;
    data['author_username'] = authorUsername;
    data['author_name'] = authorName;
    data['is_reply'] = isReply;
    data['reply_count'] = replyCount;
    data['created_at'] = createdAt;
    data['is_approved'] = isApproved;
    data['reply_to'] = replyTo;
    data['social_likes'] = socialLikes;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    data['social_dislikes'] = socialDislikes;
    data['user_liked'] = userLike;
    data['user_disliked'] = userDisLike;
    data['pinned'] = pinned;
    data['media'] = media.map((v) => v.toJson()).toList();

    if (data['attachment'] != null) {
      if (data['attachment'] is String) {
        data['attachment'] = jsonDecode(data['attachment']);
      }

      if (data['attachment']['service'] != null) {
        attachmentType = 'service';
        attachment = data['attachment']['service'];
      } else if (data['attachment']['blog'] != null) {
        attachmentType = 'blog';
        attachment = data['attachment']['blog'];
      } else if (data['attachment']['product'] != null) {
        attachmentType = 'product';
        attachment = data['attachment']['product'];
      } else if (data['attachment']['profile'] != null) {
        attachmentType = 'profile';
        attachment = data['attachment']['profile'];
      }
    }
    return data;
  }
}
