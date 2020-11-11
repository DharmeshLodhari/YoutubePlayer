class Review {
  String date;
  String detail;
  String name;
  int star;
  String user_avatar;

  Review({this.date, this.detail, this.name, this.star, this.user_avatar});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      date: json['date'],
      detail: json['detail'],
      name: json['name'],
      star: json['star'],
      user_avatar: json['user_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['detail'] = this.detail;
    data['name'] = this.name;
    data['star'] = this.star;
    data['user_avatar'] = this.user_avatar;
    return data;
  }
}
