class PartialMusicAlbum {
  int? id;
  String? name;
  String? poster;

  PartialMusicAlbum({this.id, this.name, this.poster});

  factory PartialMusicAlbum.fromJson(Map<String, dynamic> json) {
    return PartialMusicAlbum(
      id: json['id'],
      name: json['name'],
      poster: json['poster'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['poster'] = poster;
    return data;
  }
}
