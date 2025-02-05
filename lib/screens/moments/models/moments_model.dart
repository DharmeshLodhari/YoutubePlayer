// This model is to show the moments on the moment's homepage.
import 'dart:io';

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
    this.ownerName,
  });
  factory ExploreMomentsModel.fromJson(Map<String, dynamic> json) {
    final List moments = json['moments'];

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
  bool enableCommenting;
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
  int numberOfComments;
  Map<String, dynamic>? attachment;
  String? payMeLabel;
  String? payMeButtonColor;
  bool? isPermanent;
  bool? userSupported;
  int? duration;

  MomentsModel(
      {this.id,
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
      this.numberOfComments = 0,
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
      this.userSupported,
      this.duration,
      this.isPermanent = false});

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

  String get displayComment => (enableCommenting && numberOfComments > 0)
      ? numberOfComments.toString()
      : '';

  factory MomentsModel.fromJson(Map<String, dynamic> json) {
    return MomentsModel(
      id: json['id'],
      views: json['views'] ?? 0,
      payMeLabel: json['pay_me_label'],
      payMeButtonColor: json['payme_button_color'],
      payMe: json['enable_payme'],
      tags: json['tags'],
      enableLikes: json['enable_like'],
      enableCommenting: json['enable_commenting'] ?? false,
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
      duration: json['duration'] ?? 30000,
      userSupported: json['user_supported'] ?? false,
      isPublic: json['is_public'] ?? false,
      isPermanent: json['is_permanent'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['views'] = views;
    map['pay_me_label'] = payMeLabel;
    map['payme_button_color'] = payMeButtonColor;
    map['enable_payme'] = payMe;
    map['tags'] = tags;
    map['enable_like'] = enableLikes;
    map['enable_commenting'] = enableCommenting;
    map['likes'] = likes;
    map['dislikes'] = dislikes;
    map['media_type'] = mediaType;
    map['attachment'] = attachment;
    map['number_of_comments'] = numberOfComments;
    map['avatar'] = avatar;
    map['owner_name'] = ownerName;
    map['media'] = media;
    map['media_poster'] = mediaPoster;
    map['gif'] = gif;
    map['text'] = text;
    map['owner'] = owner;
    map['created_at'] = createdAt;
    map['expire_at'] = expireAt;
    map['is_public'] = isPublic;
    map['user_supported'] = userSupported;
    map['duration'] = duration ?? 30000;
    map['is_permanent'] = isPermanent;
    return map;
  }
}

// ignore: must_be_immutable
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['owner'] = owner;
    data['created_at'] = createdAt;
    data['tags'] = tags;
    data['media_type'] = mediaType;
    data['avatar'] = avatar;
    data['owner_name'] = ownerName;
    return data;
  }
}

class MomentMedia {
  File? mediaFile;
  File? posterFile;
  String? mediaType;
  String? mediaPoster;
  String? id;
  String? mediaUrl;

  MomentMedia({
    this.mediaFile,
    this.mediaType,
    this.mediaPoster,
    this.posterFile,
  });

  MomentMedia.fromJson(dynamic json) {
    id = json['id'];
    mediaUrl = json['file'] ?? json['mediaUrl'];
    mediaType = json['type'] ?? json['mediaType'];
    mediaPoster = json['image_poster'] ?? json['mediaPoster'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "mediaUrl": mediaUrl,
      "mediaType": mediaType,
      "mediaPoster": mediaPoster,
    };
  }
}
