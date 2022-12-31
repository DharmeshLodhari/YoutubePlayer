import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';

class YarnComment {
  YarnComment({
    this.id,
    this.authorAvatar,
    this.comment,
    this.authorUsername,
    this.authorName,
    this.isReply,
    this.userLike,
    this.userDisLike,
    this.replyCount,
    this.createdAt,
    this.isApproved,
    this.replies,
    this.socialLikes,
    this.socialDislikes,
    this.likes,
    this.dislike,
    this.enablePayMe,
    this.media = const [],
    this.attachment,
    this.attachmentType,
  });

  YarnComment.fromJson(dynamic json) {
    id = json['id'];
    authorAvatar = json['author_avatar'];
    comment = json['comment'];
    authorUsername = json['author_username'];
    authorName = json['author_name'];
    isReply = json['is_reply'];
    userLike = json['user_liked'];
    userDisLike = json['user_disliked'];
    replyCount = json['reply_count'];
    createdAt = json['created_at'];
    isApproved = json['is_approved'];
    replies = json['replies'] != null ? json['replies'].cast<String>() : [];
    socialLikes = json['social_likes'];
    socialDislikes = json['social_dislikes'];
    likes = json['likes'] != null ? json['likes'] : 0;
    dislike = json['dislikes'] != null ? json['dislikes'] : 0;
    enablePayMe = json['enable_payme'] != null ? json['enable_payme'] : false;
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media.add(YarnMedia.fromJson(v));
      });
    }
    if (json['attachment'] != null) {
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
  bool? userLike = false;
  bool? userDisLike = false;
  List<YarnMedia> media = [];
  Map<String, dynamic>? attachment;
  String? attachmentType;

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
    map['user_liked'] = userLike;
    map['user_disliked'] = userDisLike;
    map['media'] = media.map((v) => v.toJson()).toList();
    return map;
  }
}
