class PartialMusicItem {
  String? currency;
  int? id;
  String? name;
  String? poster;
  String? price;

  PartialMusicItem(
      {this.currency, this.id, this.name, this.poster, this.price});

  factory PartialMusicItem.fromJson(Map<String, dynamic> json) {
    return PartialMusicItem(
      currency: json['currency'],
      id: json['id'],
      name: json['name'],
      poster: json['poster'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['id'] = id;
    data['name'] = name;
    data['poster'] = poster;
    data['price'] = price;
    return data;
  }
}
