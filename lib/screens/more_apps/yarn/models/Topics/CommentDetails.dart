class YarnComment {
  YarnComment({
    this.id,
    this.authorAvatar,
    this.comment,
    this.authorUsername,
    this.authorName,
    this.isReply,
    this.replyCount,
    this.createdAt,
    this.isApproved,
    this.replies,
    this.socialLikes,
    this.socialDislikes,
    this.likes,
    this.dislike,
    this.enablePayMe,
  });

  YarnComment.fromJson(dynamic json) {
    id = json['id'];
    authorAvatar = json['author_avatar'];
    comment = json['comment'];
    authorUsername = json['author_username'];
    authorName = json['author_name'];
    isReply = json['is_reply'];
    replyCount = json['reply_count'];
    createdAt = json['created_at'];
    isApproved = json['is_approved'];
    replies = json['replies'] != null ? json['replies'].cast<String>() : [];
    socialLikes = json['social_likes'];
    socialDislikes = json['social_dislikes'];
    likes = json['likes'] != null ? json['likes'] : 0;
    dislike = json['dislikes'] != null ? json['dislikes'] : 0;
    enablePayMe = json['enable_payme'] != null ? json['enable_payme'] : false;
  }
  String? id;
  String? authorAvatar;
  String? comment;
  String? authorUsername;
  String? authorName;
  int? likes;
  int? dislike;
  bool? isReply;
  num? replyCount;
  String? createdAt;
  bool? isApproved;
  List<String>? replies;
  String? socialLikes;
  String? socialDislikes;
  bool? enablePayMe;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['author_avatar'] = authorAvatar;
    map['comment'] = comment;
    map['author_username'] = authorUsername;
    map['author_name'] = authorName;
    map['is_reply'] = isReply;
    map['reply_count'] = replyCount;
    map['created_at'] = createdAt;
    map['is_approved'] = isApproved;
    map['replies'] = replies;
    map['social_likes'] = socialLikes;
    map['social_dislikes'] = socialDislikes;
    map['likes'] = likes;
    map['dislikes'] = dislike;
    return map;
  }
}
