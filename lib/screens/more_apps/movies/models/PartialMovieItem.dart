class PartialMovieItem {
  int? id;
  String? poster;

  PartialMovieItem({this.id, this.poster});

  factory PartialMovieItem.fromJson(Map<String, dynamic> json) {
    return PartialMovieItem(
      id: json['id'],
      poster: json['poster'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['poster'] = this.poster;
    return data;
  }
}
