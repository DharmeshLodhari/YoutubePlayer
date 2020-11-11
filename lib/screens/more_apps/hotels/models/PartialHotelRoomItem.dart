class PartialHotelRoomItem {
  String currency;
  String image;
  String name;
  String price;
  String short_description;

  PartialHotelRoomItem(
      {this.currency,
      this.image,
      this.name,
      this.price,
      this.short_description});

  factory PartialHotelRoomItem.fromJson(Map<String, dynamic> json) {
    return PartialHotelRoomItem(
      currency: json['currency'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      short_description: json['short_description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['image'] = this.image;
    data['name'] = this.name;
    data['price'] = this.price;
    data['short_description'] = this.short_description;
    return data;
  }
}
