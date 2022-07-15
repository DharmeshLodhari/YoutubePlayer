import 'package:equatable/equatable.dart';

class BasePaginationModel<T> {
  int count;
  String? next;
  String? previous;
  T result;

  BasePaginationModel(
      {required this.count,
      required this.next,
      required this.previous,
      required this.result});

  factory BasePaginationModel.fromJson(Map<String, dynamic> json, T t) {
    return BasePaginationModel(
      next: json['next'],
      count: json['count'],
      result: t,
      previous: json['previous'],
    );
  }
}

class CommentModel extends Equatable {
  String? id;
  String? authorAvatar;
  String? comment;
  String? authorUsername;
  bool? isReply;
  int? replyCount;
  String? createdAt;
  bool? isApproved;
  String? replyTo;
  int? socialLikes;
  int? socialDislikes;

  @override
  List<Object?> get props => [
    id,
    authorAvatar,
    comment,
    authorUsername,
    isReply,
    replyCount,
    createdAt,
    isApproved,
    replyTo,
    socialLikes,
    socialDislikes,
  ];


  CommentModel(
      {this.id,
      this.authorAvatar,
      this.comment,
      this.authorUsername,
      this.isReply,
      this.replyCount,
      this.createdAt,
      this.isApproved,
      this.replyTo,
      this.socialLikes,
      this.socialDislikes});



  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    authorAvatar = json['author_avatar'];
    comment = json['comment'];
    authorUsername = json['author_username'];
    isReply = json['is_reply'];
    replyCount = json['reply_count'];
    createdAt = json['created_at'];
    isApproved = json['is_approved'];
    replyTo = json['reply_to'];
    socialLikes = json['social_likes'];
    socialDislikes = json['social_dislikes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['author_avatar'] = this.authorAvatar;
    data['comment'] = this.comment;
    data['author_username'] = this.authorUsername;
    data['is_reply'] = this.isReply;
    data['reply_count'] = this.replyCount;
    data['created_at'] = this.createdAt;
    data['is_approved'] = this.isApproved;
    data['reply_to'] = this.replyTo;
    data['social_likes'] = this.socialLikes;
    data['social_dislikes'] = this.socialDislikes;
    return data;
  }
}
