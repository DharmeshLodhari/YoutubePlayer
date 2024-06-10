class MovieDetailItem {
  String? category;
  String? currency;
  String? description;
  String? name;
  String? poster;
  String? price;
  String? rating;
  String? starring;
  String? time;
  String? video;
  String? viewingRating;
  String? year;

  MovieDetailItem(
      {this.category = "",
      this.currency = "",
      this.description = "",
      this.name = "",
      this.poster = "",
      this.price = "",
      this.rating = "",
      this.starring = "",
      this.time = "",
      this.video = "",
      this.viewingRating = "",
      this.year = ""});

  factory MovieDetailItem.fromJson(Map<String, dynamic> json) {
    return MovieDetailItem(
      category: json['category'],
      currency: json['currency'],
      description: json['description'],
      name: json['name'],
      poster: json['poster'],
      price: json['price'],
      rating: json['rating'],
      starring: json['starring'],
      time: json['time'],
      video: json['video'],
      viewingRating: json['viewing_rating'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['currency'] = currency;
    data['description'] = description;
    data['name'] = name;
    data['poster'] = poster;
    data['price'] = price;
    data['rating'] = rating;
    data['starring'] = starring;
    data['time'] = time;
    data['video'] = video;
    data['viewing_rating'] = viewingRating;
    data['year'] = year;
    return data;
  }
}
