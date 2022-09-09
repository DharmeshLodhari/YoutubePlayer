// This model is to show the moments on the moment's homepage.
import 'package:equatable/equatable.dart';

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
  int views;
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
  String? payMeLabel;
  String? payMeButtonColor;

  MomentsModel({
    this.id,
    this.views = 0,
    this.payMe = true,
    this.tags,
    this.mediaPoster,
    this.enableLikes = false,
    this.enableCommenting = false,
    this.payMeButtonColor,
    this.payMeLabel,
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

  // factory MomentsModel.fromExploreMoments(ExploreMomentsModel exploreMomentsModel) {
  //
  //   String? owner;
  //   String? avatar;
  //   String? ownerName;
  //   List<MomentsModel>? moments;
  //   return MomentsModel(
  //     id: exploreMomentsModel.id,
  //     views: json['views'] ?? 0,
  //     payMeLabel: json['pay_me_label'],
  //     payMeButtonColor: json['payme_button_color'],
  //     payMe: json['enable_payme'],
  //     tags: json['tags'],
  //     enableLikes: json['enable_like'],
  //     enableCommenting: json['enable_commenting'],
  //     likes: json['likes'] ?? 0,
  //     dislikes: json['dislikes'] ?? 0,
  //     mediaType: json['media_type'],
  //     attachment: json['attachment'] ?? {},
  //     numberOfComments: json['number_of_comments'] ?? 0,
  //     avatar: json['avatar'],
  //     ownerName: json['owner_name'],
  //     media: json['media'],
  //     mediaPoster: json['media_poster'],
  //     gif: json['gif'],
  //     text: json['text'],
  //     owner: exploreMomentsModel.owner,
  //     createdAt: json['created_at'],
  //     expireAt: json['expire_at'],
  //     isPublic: json['is_public'],
  //   );
  // }

  factory MomentsModel.fromJson(Map<String, dynamic> json) {
    return MomentsModel(
      id: json['id'],
      views: json['views'] ?? 0,
      payMeLabel: json['pay_me_label'],
      payMeButtonColor: json['payme_button_color'],
      payMe: json['enable_payme'],
      tags: json['tags'],
      enableLikes: json['enable_like'],
      enableCommenting: json['enable_commenting'],
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      mediaType: json['media_type'],
      attachment: json['attachment'] ?? {},
      numberOfComments: json['number_of_comments'] ?? 0,
      avatar: json['avatar'],
      ownerName: json['owner_name'],
      media: json['media'],
      mediaPoster: json['media_poster'],
      gif: json['gif'],
      text: json['text'],
      owner: json['owner'],
      createdAt: json['created_at'],
      expireAt: json['expire_at'],
      isPublic: json['is_public'],
    );
  }
}

class SearchMomentModel extends Equatable {
  String? id;
  String? text;
  String? media;
  String? owner;
  String? avatar;
  String? createdAt;
  String? mediaType;
  String? ownerName;
  List<String>? tags;
  String? mediaPoster;

  @override
  List<Object?> get props => [
        id,
        text,
        media,
        owner,
        avatar,
        createdAt,
        mediaType,
        ownerName,
        tags,
        mediaPoster
      ];

  SearchMomentModel({
    this.id,
    this.tags,
    this.text,
    this.owner,
    this.media,
    this.avatar,
    this.mediaType,
    this.createdAt,
    this.ownerName,
    this.mediaPoster,
  });

  SearchMomentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    media = json['media'];
    owner = json['owner'];
    avatar = json['avatar'];
    mediaType = json['media_type'];
    createdAt = json['created_at'];
    mediaType = json['media_type'];
    ownerName = json['owner_name'];
    mediaPoster = json['media_poster'];
    tags = json['tags'].cast<String>();
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
