/// business_name : "Ultimate Cakes And Events"
/// username : "ultimate"
/// avatar : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
library;

class CompanyName {
  String? businessName;
  String? username;
  String? avatar;

  CompanyName({
    this.businessName,
    this.username,
    this.avatar,
  });

  CompanyName.fromJson(dynamic json) {
    businessName = json['business_name'];
    username = json['username'];
    avatar = json['avatar'];
  }

  CompanyName copyWith({
    String? businessName,
    String? username,
    String? avatar,
  }) =>
      CompanyName(
        businessName: businessName ?? this.businessName,
        username: username ?? this.username,
        avatar: avatar ?? this.avatar,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['business_name'] = businessName;
    map['username'] = username;
    map['avatar'] = avatar;
    return map;
  }
}
