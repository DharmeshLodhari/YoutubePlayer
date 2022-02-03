class Pack {
  String? image;
  String? name;

  Pack({this.image, this.name});

  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      image: json['image'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}
