class CityData {
  String? image;
  String? name;

  CityData({this.image, this.name});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
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
