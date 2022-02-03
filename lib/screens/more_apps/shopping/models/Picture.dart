class Picture {
  String? path;
  int? id;
  String? title;

  Picture({this.path, this.id, this.title});

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      path: json['file'],
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.path;
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
