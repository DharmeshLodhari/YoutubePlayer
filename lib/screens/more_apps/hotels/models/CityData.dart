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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}
