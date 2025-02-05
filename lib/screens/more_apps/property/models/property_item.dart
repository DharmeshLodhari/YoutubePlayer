class PropertyItem {
  String? address1;
  String? address2;
  String? currency;
  List<String>? images;
  String? name;
  String? price;
  String? rating;

  PropertyItem(
      {this.address1,
      this.address2,
      this.currency,
      this.images,
      this.name,
      this.price,
      this.rating});

  factory PropertyItem.fromJson(Map<String, dynamic> json) {
    return PropertyItem(
      address1: json['address1'],
      address2: json['address2'],
      currency: json['currency'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      name: json['name'],
      price: json['price'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address1'] = address1;
    data['address2'] = address2;
    data['currency'] = currency;
    data['name'] = name;
    data['price'] = price;
    data['rating'] = rating;
    if (images != null) {
      data['images'] = images;
    }
    return data;
  }
}
