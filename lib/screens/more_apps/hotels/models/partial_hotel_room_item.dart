class PartialHotelRoomItem {
  String? currency;
  String? image;
  String? name;
  String? price;
  String? shortDescription;

  PartialHotelRoomItem(
      {this.currency,
      this.image,
      this.name,
      this.price,
      this.shortDescription});

  factory PartialHotelRoomItem.fromJson(Map<String, dynamic> json) {
    return PartialHotelRoomItem(
      currency: json['currency'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      shortDescription: json['short_description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['image'] = image;
    data['name'] = name;
    data['price'] = price;
    data['short_description'] = shortDescription;
    return data;
  }
}
