class Review {
  String? date;
  String? detail;
  String? name;
  int? star;
  String? userAvatar;

  Review({this.date, this.detail, this.name, this.star, this.userAvatar});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      date: json['date'],
      detail: json['detail'],
      name: json['name'],
      star: json['star'],
      userAvatar: json['user_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['detail'] = detail;
    data['name'] = name;
    data['star'] = star;
    data['user_avatar'] = userAvatar;
    return data;
  }
}
