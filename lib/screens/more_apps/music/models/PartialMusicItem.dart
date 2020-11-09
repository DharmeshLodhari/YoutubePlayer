class PartialMusicItem {
  String currency;
  int id;
  String name;
  String poster;
  String price;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['id'] = this.id;
    data['name'] = this.name;
    data['poster'] = this.poster;
    data['price'] = this.price;
    return data;
  }
}
