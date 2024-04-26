class EventPoster {
  String? image;
  String? name;

  EventPoster({this.image, this.name});

  factory EventPoster.fromJson(Map<String, dynamic> json) {
    return EventPoster(
      image: json['image'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}
