class OriginalStill {
  String? height;
  String? size;
  String? url;
  String? width;

  OriginalStill({this.height, this.size, this.url, this.width});

  factory OriginalStill.fromJson(Map<String, dynamic> json) {
    return OriginalStill(
      height: json['height'],
      size: json['size'],
      url: json['url'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['height'] = this.height;
    data['size'] = this.size;
    data['url'] = this.url;
    data['width'] = this.width;
    return data;
  }
}
