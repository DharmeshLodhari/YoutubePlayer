import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

/// id : "96a0a291-71a8-4b13-9aa8-c26b606287b9"
/// members_details : [{"username":"psami","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"psami"},{"username":"sam","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"sam"},{"username":"boss","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"boss"}]
/// name : "My special cart"
/// shared : true
/// members : ["psami","sam","boss"]
/// customer_username : "psami"
/// created_at : "2023-10-23T17:54:07.089166+01:00"

class SharedCartModel {
  String? id;
  List<UserFollowers>? membersDetails;
  String? name;
  bool? shared;
  List<String>? members;
  String? customerUsername;
  String? createdAt;

  SharedCartModel({
    this.id,
    this.membersDetails,
    this.name,
    this.shared,
    this.members,
    this.customerUsername,
    this.createdAt,
  });

  SharedCartModel.fromJson(dynamic json) {
    id = json['id'];
    if (json['members_details'] != null) {
      membersDetails = [];
      json['members_details'].forEach((v) {
        membersDetails?.add(UserFollowers.fromJson(v));
      });
    }
    name = json['name'];
    shared = json['shared'];
    members = json['members'] != null ? json['members'].cast<String>() : [];
    customerUsername = json['customer_username'];
    createdAt = json['created_at'];
  }

  SharedCartModel copyWith({
    String? id,
    List<UserFollowers>? membersDetails,
    String? name,
    bool? shared,
    List<String>? members,
    String? customerUsername,
    String? createdAt,
  }) =>
      SharedCartModel(
        id: id ?? this.id,
        membersDetails: membersDetails ?? this.membersDetails,
        name: name ?? this.name,
        shared: shared ?? this.shared,
        members: members ?? this.members,
        customerUsername: customerUsername ?? this.customerUsername,
        createdAt: createdAt ?? this.createdAt,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (membersDetails != null) {
      map['members_details'] = membersDetails?.map((v) => v.toJson()).toList();
    }
    map['name'] = name;
    map['shared'] = shared;
    map['members'] = members;
    map['customer_username'] = customerUsername;
    map['created_at'] = createdAt;
    return map;
  }
}

/// username : "psami"
/// avatar : "http://0.0.0.0:8000/static/images/User_Avatar.png"
/// full_name : "psami"

class MembersDetails {
  String? username;
  String? avatar;
  String? fullName;

  MembersDetails({
    this.username,
    this.avatar,
    this.fullName,
  });

  MembersDetails.fromJson(dynamic json) {
    username = json['username'];
    avatar = json['avatar'];
    fullName = json['full_name'];
  }

  MembersDetails copyWith({
    String? username,
    String? avatar,
    String? fullName,
  }) =>
      MembersDetails(
        username: username ?? this.username,
        avatar: avatar ?? this.avatar,
        fullName: fullName ?? this.fullName,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['avatar'] = avatar;
    map['full_name'] = fullName;
    return map;
  }
}
