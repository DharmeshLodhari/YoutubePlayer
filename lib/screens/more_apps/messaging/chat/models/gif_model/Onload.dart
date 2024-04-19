class Onload {
  String? url;

  Onload({this.url});

  factory Onload.fromJson(Map<String, dynamic> json) {
    return Onload(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}
