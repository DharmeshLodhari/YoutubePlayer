// This model is to show the moments on the moment's homepage.
class UserMomentModel {
  String? id;
  String? mediaType;
  String? avatar;
  String? ownerName;
  String? media;
  String? gif;
  String? text;
  String? owner;
  String? createdAt;
  String? expireAt;
  bool? isPublic;
  int? socialLikes;
  int? socialDislikes;

  UserMomentModel(
      {this.id,
      this.mediaType,
      this.avatar,
      this.ownerName,
      this.media,
      this.gif,
      this.text,
      this.owner,
      this.createdAt,
      this.expireAt,
      this.isPublic,
      this.socialLikes,
      this.socialDislikes});

  UserMomentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mediaType = json['media_type'];
    avatar = json['avatar'];
    ownerName = json['owner_name'];
    media = json['media'];
    gif = json['gif'];
    text = json['text'];
    owner = json['owner'];
    createdAt = json['created_at'];
    expireAt = json['expire_at'];
    isPublic = json['is_public'];
    socialLikes = json['social_likes'];
    socialDislikes = json['social_dislikes'];
  }
}

class ExploreMomentsModel {
  String? owner;
  String? avatar;
  String? ownerName;
  List<MomentsModel>? moments;

  ExploreMomentsModel({
    required this.owner,
    required this.avatar,
    required this.moments,
    required this.ownerName,
  });
  factory ExploreMomentsModel.fromJson(Map<String, dynamic> json) {
    List moments = json['moments'];
    return ExploreMomentsModel(
      owner: json['owner'],
      avatar: json['avatar'],
      ownerName: json['owner_name'],
      moments: moments.map((e) => MomentsModel.fromJson(e)).toList(),
    );
  }
}

class MomentsModel {
  String? id;
  int? likes;
  int? dislikes;
  String? mediaType;
  String? avatar;
  String? ownerName;
  String? media;
  String? mediaPoster;
  String? gif;
  String? text;
  String? owner;
  String? createdAt;
  String? expireAt;
  bool? isPublic;
  List<dynamic>? tags;

  MomentsModel({
    this.id,
    this.tags,
    this.likes,
    this.dislikes,
    this.mediaType,
    this.avatar,
    this.ownerName,
    this.media,
    this.gif,
    this.text,
    this.owner,
    this.createdAt,
    this.expireAt,
    this.isPublic,
  });

  MomentsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    mediaType = json['media_type'];
    avatar = json['avatar'];
    ownerName = json['owner_name'];
    media = json['media'];
    mediaPoster = json['media_poster'];
    gif = json['gif'];
    text = json['text'];
    owner = json['owner'];
    createdAt = json['created_at'];
    expireAt = json['expire_at'];
    isPublic = json['is_public'];
  }
}
