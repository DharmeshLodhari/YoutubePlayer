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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['poster'] = poster;
    return data;
  }
}
