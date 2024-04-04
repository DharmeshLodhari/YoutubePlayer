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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['date'] = this.date;
    data['detail'] = this.detail;
    data['name'] = this.name;
    data['star'] = this.star;
    data['user_avatar'] = this.userAvatar;
    return data;
  }
}
