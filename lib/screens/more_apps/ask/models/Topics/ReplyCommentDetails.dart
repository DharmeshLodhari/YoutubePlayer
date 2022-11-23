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
      String? id, 
      String? authorAvatar, 
      String? comment, 
      String? authorUsername, 
      String? authorName,
      bool? isReply,
      num? replyCount, 
      String? createdAt, 
      bool? isApproved, 
      dynamic socialLikes, 
      dynamic socialDislikes, 
      List<String>? replies,}){
    _id = id;
    _authorAvatar = authorAvatar;
    _comment = comment;
    _authorUsername = authorUsername;
    _authorName = authorName;
    _isReply = isReply;
    _replyCount = replyCount;
    _createdAt = createdAt;
    _isApproved = isApproved;
    _socialLikes = socialLikes;
    _socialDislikes = socialDislikes;
    _replies = replies;
}

  ReplyCommentDetails.fromJson(dynamic json) {
    _id = json['id'];
    _authorAvatar = json['author_avatar'];
    _comment = json['comment'];
    _authorUsername = json['author_username'];
    _authorName = json['author_name'];
    _isReply = json['is_reply'];
    _replyCount = json['reply_count'];
    _createdAt = json['created_at'];
    _isApproved = json['is_approved'];
    _socialLikes = json['social_likes'];
    _socialDislikes = json['social_dislikes'];
    _replies = json['replies'] != null ? json['replies'].cast<String>() : [];
  }
  String? _id;
  String? _authorAvatar;
  String? _comment;
  String? _authorUsername;
  String? _authorName;
  bool? _isReply;
  num? _replyCount;
  String? _createdAt;
  bool? _isApproved;
  dynamic _socialLikes;
  dynamic _socialDislikes;
  List<String>? _replies;
ReplyCommentDetails copyWith({  String? id,
  String? authorAvatar,
  String? comment,
  String? authorUsername,
  String? authorName,
  bool? isReply,
  num? replyCount,
  String? createdAt,
  bool? isApproved,
  dynamic socialLikes,
  dynamic socialDislikes,
  List<String>? replies,
}) => ReplyCommentDetails(  id: id ?? _id,
  authorAvatar: authorAvatar ?? _authorAvatar,
  comment: comment ?? _comment,
  authorUsername: authorUsername ?? _authorUsername,
  authorName: authorName ?? _authorName,
  isReply: isReply ?? _isReply,
  replyCount: replyCount ?? _replyCount,
  createdAt: createdAt ?? _createdAt,
  isApproved: isApproved ?? _isApproved,
  socialLikes: socialLikes ?? _socialLikes,
  socialDislikes: socialDislikes ?? _socialDislikes,
  replies: replies ?? _replies,
);
  String? get id => _id;
  String? get authorAvatar => _authorAvatar;
  String? get comment => _comment;
  String? get authorUsername => _authorUsername;
  String? get authorName => _authorName;
  bool? get isReply => _isReply;
  num? get replyCount => _replyCount;
  String? get createdAt => _createdAt;
  bool? get isApproved => _isApproved;
  dynamic get socialLikes => _socialLikes;
  dynamic get socialDislikes => _socialDislikes;
  List<String>? get replies => _replies;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['author_avatar'] = _authorAvatar;
    map['comment'] = _comment;
    map['author_username'] = _authorUsername;
    map['author_name'] = _authorName;
    map['is_reply'] = _isReply;
    map['reply_count'] = _replyCount;
    map['created_at'] = _createdAt;
    map['is_approved'] = _isApproved;
    map['social_likes'] = _socialLikes;
    map['social_dislikes'] = _socialDislikes;
    map['replies'] = _replies;
    return map;
  }

}