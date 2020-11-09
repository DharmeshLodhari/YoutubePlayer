class PartialPropertyItem {
  String currency;
  String image;
  String name;
  String price;
  String shortDescription;

  PartialPropertyItem(
      {this.currency,
      this.image,
      this.name,
      this.price,
      this.shortDescription});

  factory PartialPropertyItem.fromJson(Map<String, dynamic> json) {
    return PartialPropertyItem(
      currency: json['currency'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      shortDescription: json['short_description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['image'] = this.image;
    data['name'] = this.name;
    data['price'] = this.price;
    data['short_description'] = this.shortDescription;
    return data;
  }
}
