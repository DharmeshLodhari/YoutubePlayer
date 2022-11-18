class CommentDetails {
  CommentDetails({
      String? id, 
      String? authorAvatar, 
      String? comment, 
      String? authorUsername, 
      bool? isReply, 
      num? replyCount, 
      String? createdAt, 
      bool? isApproved, 
      dynamic replyTo, 
      dynamic socialLikes, 
      dynamic socialDislikes,}){
    _id = id;
    _authorAvatar = authorAvatar;
    _comment = comment;
    _authorUsername = authorUsername;
    _isReply = isReply;
    _replyCount = replyCount;
    _createdAt = createdAt;
    _isApproved = isApproved;
    _replyTo = replyTo;
    _socialLikes = socialLikes;
    _socialDislikes = socialDislikes;
}

  CommentDetails.fromJson(dynamic json) {
    _id = json['id'];
    _authorAvatar = json['author_avatar'];
    _comment = json['comment'];
    _authorUsername = json['author_username'];
    _isReply = json['is_reply'];
    _replyCount = json['reply_count'];
    _createdAt = json['created_at'];
    _isApproved = json['is_approved'];
    _replyTo = json['reply_to'];
    _socialLikes = json['social_likes'];
    _socialDislikes = json['social_dislikes'];
  }
  String? _id;
  String? _authorAvatar;
  String? _comment;
  String? _authorUsername;
  bool? _isReply;
  num? _replyCount;
  String? _createdAt;
  bool? _isApproved;
  dynamic _replyTo;
  dynamic _socialLikes;
  dynamic _socialDislikes;
CommentDetails copyWith({  String? id,
  String? authorAvatar,
  String? comment,
  String? authorUsername,
  bool? isReply,
  num? replyCount,
  String? createdAt,
  bool? isApproved,
  dynamic replyTo,
  dynamic socialLikes,
  dynamic socialDislikes,
}) => CommentDetails(  id: id ?? _id,
  authorAvatar: authorAvatar ?? _authorAvatar,
  comment: comment ?? _comment,
  authorUsername: authorUsername ?? _authorUsername,
  isReply: isReply ?? _isReply,
  replyCount: replyCount ?? _replyCount,
  createdAt: createdAt ?? _createdAt,
  isApproved: isApproved ?? _isApproved,
  replyTo: replyTo ?? _replyTo,
  socialLikes: socialLikes ?? _socialLikes,
  socialDislikes: socialDislikes ?? _socialDislikes,
);
  String? get id => _id;
  String? get authorAvatar => _authorAvatar;
  String? get comment => _comment;
  String? get authorUsername => _authorUsername;
  bool? get isReply => _isReply;
  num? get replyCount => _replyCount;
  String? get createdAt => _createdAt;
  bool? get isApproved => _isApproved;
  dynamic get replyTo => _replyTo;
  dynamic get socialLikes => _socialLikes;
  dynamic get socialDislikes => _socialDislikes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['author_avatar'] = _authorAvatar;
    map['comment'] = _comment;
    map['author_username'] = _authorUsername;
    map['is_reply'] = _isReply;
    map['reply_count'] = _replyCount;
    map['created_at'] = _createdAt;
    map['is_approved'] = _isApproved;
    map['reply_to'] = _replyTo;
    map['social_likes'] = _socialLikes;
    map['social_dislikes'] = _socialDislikes;
    return map;
  }

}