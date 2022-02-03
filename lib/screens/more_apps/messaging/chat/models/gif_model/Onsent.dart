class Onsent {
  String? url;

  Onsent({this.url});

  factory Onsent.fromJson(Map<String, dynamic> json) {
    return Onsent(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}
