class Partner {
  String name;
  String star;
  String userAvatar;
  String userTag;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['star'] = this.star;
    data['user_avatar'] = this.userAvatar;
    data['user_tag'] = this.userTag;
    return data;
  }
}
