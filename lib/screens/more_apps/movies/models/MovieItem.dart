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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['currency'] = this.currency;
    data['genre'] = this.genre;
    data['id'] = this.id;
    data['name'] = this.name;
    data['poster'] = this.poster;
    data['price'] = this.price;
    data['rating'] = this.rating;
    data['year'] = this.year;
    return data;
  }
}
