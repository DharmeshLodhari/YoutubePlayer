class PartialEventItem {
  String currency;
  String date_time;
  String image;
  String location;
  String name;
  String price;
  String short_description;
  String title;

  PartialEventItem(
      {this.currency,
      this.date_time,
      this.image,
      this.location,
      this.name,
      this.price,
      this.short_description,
      this.title});

  factory PartialEventItem.fromJson(Map<String, dynamic> json) {
    return PartialEventItem(
      currency: json['currency'],
      date_time: json['date_time'],
      image: json['image'],
      location: json['location'],
      name: json['name'],
      price: json['price'],
      short_description: json['short_description'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['date_time'] = this.date_time;
    data['image'] = this.image;
    data['location'] = this.location;
    data['name'] = this.name;
    data['price'] = this.price;
    data['short_description'] = this.short_description;
    data['title'] = this.title;
    return data;
  }
}
