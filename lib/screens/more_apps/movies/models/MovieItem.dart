class MovieItem {
  String? currency;
  String? genre;
  int? id;
  String? name;
  String? poster;
  String? price;
  String? rating;
  String? year;

  MovieItem(
      {this.currency,
      this.genre,
      this.id,
      this.name,
      this.poster,
      this.price,
      this.rating,
      this.year});

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      currency: json['currency'],
      genre: json['genre'],
      id: json['id'],
      name: json['name'],
      poster: json['poster'],
      price: json['price'],
      rating: json['rating'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['genre'] = genre;
    data['id'] = id;
    data['name'] = name;
    data['poster'] = poster;
    data['price'] = price;
    data['rating'] = rating;
    data['year'] = year;
    return data;
  }
}
