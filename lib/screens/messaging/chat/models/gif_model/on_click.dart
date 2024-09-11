class Onclick {
  String? url;

  Onclick({this.url});

  factory Onclick.fromJson(Map<String, dynamic> json) {
    return Onclick(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
