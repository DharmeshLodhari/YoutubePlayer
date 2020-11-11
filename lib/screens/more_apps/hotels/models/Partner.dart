class Partner {
  String name;
  String star;
  String user_avatar;
  String user_tag;

  Partner({this.name, this.star, this.user_avatar, this.user_tag});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      name: json['name'],
      star: json['star'],
      user_avatar: json['user_avatar'],
      user_tag: json['user_tag'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['star'] = this.star;
    data['user_avatar'] = this.user_avatar;
    data['user_tag'] = this.user_tag;
    return data;
  }
}
