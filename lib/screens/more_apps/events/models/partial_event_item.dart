class PartialEventItem {
  String? currency;
  String? dateTime;
  String? image;
  String? location;
  String? name;
  String? price;
  String? shortDescription;
  String? title;

  PartialEventItem(
      {this.currency,
      this.dateTime,
      this.image,
      this.location,
      this.name,
      this.price,
      this.shortDescription,
      this.title});

  factory PartialEventItem.fromJson(Map<String, dynamic> json) {
    return PartialEventItem(
      currency: json['currency'],
      dateTime: json['date_time'],
      image: json['image'],
      location: json['location'],
      name: json['name'],
      price: json['price'],
      shortDescription: json['short_description'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['date_time'] = dateTime;
    data['image'] = image;
    data['location'] = location;
    data['name'] = name;
    data['price'] = price;
    data['short_description'] = shortDescription;
    data['title'] = title;
    return data;
  }
}
