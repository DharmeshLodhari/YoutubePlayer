class PartialCelebrityItem {
  String? image;
  String? name;

  PartialCelebrityItem({this.image, this.name});

  factory PartialCelebrityItem.fromJson(Map<String, dynamic> json) {
    return PartialCelebrityItem(
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
