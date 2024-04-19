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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['poster'] = this.poster;
    return data;
  }
}
