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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}
