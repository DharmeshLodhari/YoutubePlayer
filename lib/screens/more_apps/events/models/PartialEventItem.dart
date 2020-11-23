class PartialEventItem {
  String currency;
  String dateTime;
  String image;
  String location;
  String name;
  String price;
  String shortDescription;
  String title;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['date_time'] = this.dateTime;
    data['image'] = this.image;
    data['location'] = this.location;
    data['name'] = this.name;
    data['price'] = this.price;
    data['short_description'] = this.shortDescription;
    data['title'] = this.title;
    return data;
  }
}
