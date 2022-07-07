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
  bool? payMe;
  String? id;
  int? likes;
  bool? enableLikes;
  bool? enableCommenting;
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
  int? numberOfComments;
  Map<String, dynamic>? attachment;

  MomentsModel({
    this.id,
    this.payMe = true,
    this.tags,
    this.enableLikes = false,
    this.enableCommenting = false,
    this.likes,
    this.dislikes,
    this.attachment,
    this.numberOfComments,
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
    payMe = json['enable_payme'];
    tags = json['tags'];
    enableLikes = json['enable_like'];
    enableCommenting = json['enable_commenting'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    mediaType = json['media_type'];
    attachment = json['attachment'] ?? {};
    numberOfComments = json['number_of_comments'];
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

class SearchMomentModel {
  String? id;
  String? owner;
  String? avatar;
  String? createdAt;
  String? mediaType;
  String? ownerName;
  List<String>? tags;

  SearchMomentModel(
      {this.id,
      this.owner,
      this.createdAt,
      this.tags,
      this.mediaType,
      this.avatar,
      this.ownerName});

  SearchMomentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'];
    createdAt = json['created_at'];
    tags = json['tags'].cast<String>();
    mediaType = json['media_type'];
    avatar = json['avatar'];
    ownerName = json['owner_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['owner'] = this.owner;
    data['created_at'] = this.createdAt;
    data['tags'] = this.tags;
    data['media_type'] = this.mediaType;
    data['avatar'] = this.avatar;
    data['owner_name'] = this.ownerName;
    return data;
  }
}
