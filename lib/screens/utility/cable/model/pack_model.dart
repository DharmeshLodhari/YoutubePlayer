class PackModel {
  String? image;
  String? name;

  PackModel({this.image, this.name});

  factory PackModel.fromJson(Map<String, dynamic> json) {
    return PackModel(
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
