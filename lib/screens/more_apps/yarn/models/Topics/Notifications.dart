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
    this.yarn,
    this.createdAt,});

  Notifications.fromJson(dynamic json) {
    id = json['id'];
    user = json['user'];
    type = json['type'];
    yarn = json['data'] != null ? Yarn.fromJson(json['data']) : null;
    createdAt = json['created_at'];
  }
  String? id;
  String? user;
  String? type;
  Yarn? yarn;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user'] = user;
    map['type'] = type;
    if (yarn != null) {
      map['data'] = yarn?.toJson();
    }
    map['created_at'] = createdAt;
    return map;
  }

}