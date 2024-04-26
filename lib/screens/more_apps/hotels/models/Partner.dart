class Partner {
  String? name;
  String? star;
  String? userAvatar;
  String? userTag;

  Partner({this.name, this.star, this.userAvatar, this.userTag});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      name: json['name'],
      star: json['star'],
      userAvatar: json['user_avatar'],
      userTag: json['user_tag'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['star'] = star;
    data['user_avatar'] = userAvatar;
    data['user_tag'] = userTag;
    return data;
  }
}
