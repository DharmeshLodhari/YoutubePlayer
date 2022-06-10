class UserMomentsModel {
  String? owner;
  String? createdAt;
  String? avatar;
  String? ownerName;
  List<MomentsModel>? moments;

  UserMomentsModel({
    required this.moments,
    required this.owner,
    required this.createdAt,
    required this.avatar,
    required this.ownerName,
  });

  UserMomentsModel.fromJson(Map<String, dynamic> json) {
    List? momentsList = json['moments'];
    owner = json['owner'];
    createdAt = json['created_at'];
    avatar = json['avatar'];
    ownerName = json['owner_name'];
    moments = momentsList?.map((json) => MomentsModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['owner'] = this.owner;
    data['created_at'] = this.createdAt;
    data['avatar'] = this.avatar;
    data['owner_name'] = this.ownerName;
    return data;
  }
}

class MomentsModel {
  String? id;
  String? mediaType;
  String? avatar;
  String? ownerName;
  String? media;
  String? text;
  String? owner;
  String? createdAt;
  String? expireAt;
  int? likes;
  int? dislikes;
  bool? isPublic;

  MomentsModel(
      {this.id,
      this.mediaType,
      this.avatar,
      this.ownerName,
      this.media,
      this.text,
      this.owner,
      this.createdAt,
      this.expireAt,
      this.likes,
      this.dislikes,
      this.isPublic});

  MomentsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mediaType = json['media_type'];
    avatar = json['avatar'];
    ownerName = json['owner_name'];
    media = json['media'];
    text = json['text'];
    owner = json['owner'];
    createdAt = json['created_at'];
    expireAt = json['expire_at'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    isPublic = json['is_public'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['media_type'] = this.mediaType;
    data['avatar'] = this.avatar;
    data['owner_name'] = this.ownerName;
    data['media'] = this.media;
    data['text'] = this.text;
    data['owner'] = this.owner;
    data['created_at'] = this.createdAt;
    data['expire_at'] = this.expireAt;
    data['likes'] = this.likes;
    data['dislikes'] = this.dislikes;
    data['is_public'] = this.isPublic;
    return data;
  }
}
