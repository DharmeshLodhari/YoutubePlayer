/// id : "72fa53ee-9e45-449c-85f2-259d659a2e72"
/// author_avatar : "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg"
/// comment : "absdjabda"
/// author_username : "blackstriker"
/// is_reply : true
/// reply_count : 0
/// created_at : "2022-11-22T08:07:11.825351+01:00"
/// is_approved : false
/// social_likes : null
/// social_dislikes : null
/// replies : ["33532aa0-7aac-42c0-bead-0fe87fdb3681"]

class ReplyCommentDetails {
  ReplyCommentDetails({
    this.id,
    this.authorAvatar,
    this.comment,
    this.authorUsername,
    this.authorName,
    this.isReply,
    this.replyCount,
    this.createdAt,
    this.isApproved,
    this.socialLikes,
    this.socialDislikes,
    this.replies,
      });

  ReplyCommentDetails.fromJson(dynamic json) {
    id = json['id'];
    authorAvatar = json['author_avatar'];
    comment = json['comment'];
    authorUsername = json['author_username'];
    authorName = json['author_name'];
    isReply = json['is_reply'];
    replyCount = json['reply_count'];
    createdAt = json['created_at'];
    isApproved = json['is_approved'];
    socialLikes = json['social_likes'];
    socialDislikes = json['social_dislikes'];
    replies = json['replies'] != null ? json['replies'].cast<String>() : [];
  }
  String? id;
  String? authorAvatar;
  String? comment;
  String? authorUsername;
  String? authorName;
  bool? isReply;
  int? replyCount;
  String? createdAt;
  bool? isApproved;
  int? socialLikes;
  int? socialDislikes;
  List<String>? replies;


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
    map['social_likes'] = socialLikes;
    map['social_dislikes'] = socialDislikes;
    map['replies'] = replies;
    return map;
  }

}