import '../ask_categories_model.dart';
import 'YarnTopic.dart';

/// id : "19ba308a-ec0d-4550-9a10-5a7503f2a2d2"
/// user : "japa"
/// type : "mention"
/// data : {"id":"b4e8272f-4c8a-4504-a764-510f55d20001","body":"Watin you dey yarn @japa @kingdavid @abiola.rasheed","tags":[],"media":[],"title":"Slydo to the moon","author":"cameraman","reyarn":null,"status":"Published","category":{"id":"267fd601-1740-46de-a164-029c1e67e282","name":"Health & Lifestyle","color":"#E7E9B9","image":null},"attachment":null,"created_at":"2022-12-12T13:09:32.906511+01:00","updated_at":null,"vote_count":0,"author_name":"Cameraman Limited","is_question":false,"enable_payme":false,"fact_checked":false,"author_avatar":"http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ea18e145-e79d-4c98-a415-8862a32352a4.jpg","age_restriction":13,"down_vote_count":0,"viewers_avatars":[],"is_adult_content":false,"enable_commenting":false,"number_of_answers":0,"author_is_verified":true,"number_of_comments":0,"is_sensitive_content":false}
/// created_at : "2022-12-12T13:09:33.485294+01:00"

class Notifications {
  Notifications({
    this.id,
    this.user,
    this.type,
    this.data,
    this.createdAt,});

  Notifications.fromJson(dynamic json) {
    id = json['id'];
    user = json['user'];
    type = json['type'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    createdAt = json['created_at'];
  }
  String? id;
  String? user;
  String? type;
  Data? data;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user'] = user;
    map['type'] = type;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['created_at'] = createdAt;
    return map;
  }

}

/// id : "b4e8272f-4c8a-4504-a764-510f55d20001"
/// body : "Watin you dey yarn @japa @kingdavid @abiola.rasheed"
/// tags : []
/// media : []
/// title : "Slydo to the moon"
/// author : "cameraman"
/// reyarn : null
/// status : "Published"
/// category : {"id":"267fd601-1740-46de-a164-029c1e67e282","name":"Health & Lifestyle","color":"#E7E9B9","image":null}
/// attachment : null
/// created_at : "2022-12-12T13:09:32.906511+01:00"
/// updated_at : null
/// vote_count : 0
/// author_name : "Cameraman Limited"
/// is_question : false
/// enable_payme : false
/// fact_checked : false
/// author_avatar : "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ea18e145-e79d-4c98-a415-8862a32352a4.jpg"
/// age_restriction : 13
/// down_vote_count : 0
/// viewers_avatars : []
/// is_adult_content : false
/// enable_commenting : false
/// number_of_answers : 0
/// author_is_verified : true
/// number_of_comments : 0
/// is_sensitive_content : false

class Data {
  Data({
    this.id,
    this.body,
    this.tags,
    this.media,
    this.title,
    this.author,
    this.reyarn,
    this.status,
    this.category,
    this.attachment,
    this.createdAt,
    this.updatedAt,
    this.voteCount,
    this.authorName,
    this.isQuestion,
    this.enablePayme,
    this.factChecked,
    this.authorAvatar,
    this.ageRestriction,
    this.downVoteCount,
    this.viewersAvatars,
    this.isAdultContent,
    this.enableCommenting,
    this.numberOfAnswers,
    this.authorIsVerified,
    this.numberOfComments,
    this.isSensitiveContent,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    body = json['body'];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media?.add(MediaFiles.fromJson(v));
      });
    }
    title = json['title'];
    author = json['author'];
    reyarn = json['reyarn'];
    status = json['status'];
    category = json['category'] != null ? YarnCategories.fromJson(json['category']) : null;
    attachment = json['attachment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    voteCount = json['vote_count'];
    authorName = json['author_name'];
    isQuestion = json['is_question'];
    enablePayme = json['enable_payme'];
    factChecked = json['fact_checked'];
    authorAvatar = json['author_avatar'];
    ageRestriction = json['age_restriction'];
    downVoteCount = json['down_vote_count'];
    if (json['viewers_avatars'] != null) {
      viewersAvatars = [];
      json['viewers_avatars'].forEach((v) {
        viewersAvatars?.add(ViewersAvatars.fromJson(v));
      });
    }
    isAdultContent = json['is_adult_content'];
    enableCommenting = json['enable_commenting'];
    numberOfAnswers = json['number_of_answers'];
    authorIsVerified = json['author_is_verified'];
    numberOfComments = json['number_of_comments'];
    isSensitiveContent = json['is_sensitive_content'];
  }
  String? id;
  String? body;
  List<dynamic>? tags;
  List<dynamic>? media;
  String? title;
  String? author;
  dynamic reyarn;
  String? status;
  YarnCategories? category;
  dynamic attachment;
  String? createdAt;
  dynamic updatedAt;
  int? voteCount;
  String? authorName;
  bool? isQuestion;
  bool? enablePayme;
  bool? factChecked;
  String? authorAvatar;
  int? ageRestriction;
  int? downVoteCount;
  List<dynamic>? viewersAvatars;
  bool? isAdultContent;
  bool? enableCommenting;
  int? numberOfAnswers;
  bool? authorIsVerified;
  int? numberOfComments;
  bool? isSensitiveContent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['body'] = body;
    if (tags != null) {
      map['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    if (media != null) {
      map['media'] = media?.map((v) => v.toJson()).toList();
    }
    map['title'] = title;
    map['author'] = author;
    map['reyarn'] = reyarn;
    map['status'] = status;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    map['attachment'] = attachment;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['vote_count'] = voteCount;
    map['author_name'] = authorName;
    map['is_question'] = isQuestion;
    map['enable_payme'] = enablePayme;
    map['fact_checked'] = factChecked;
    map['author_avatar'] = authorAvatar;
    map['age_restriction'] = ageRestriction;
    map['down_vote_count'] = downVoteCount;
    if (viewersAvatars != null) {
      map['viewers_avatars'] = viewersAvatars?.map((v) => v.toJson()).toList();
    }
    map['is_adult_content'] = isAdultContent;
    map['enable_commenting'] = enableCommenting;
    map['number_of_answers'] = numberOfAnswers;
    map['author_is_verified'] = authorIsVerified;
    map['number_of_comments'] = numberOfComments;
    map['is_sensitive_content'] = isSensitiveContent;
    return map;
  }

}