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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['size'] = size;
    data['url'] = url;
    data['width'] = width;
    return data;
  }
}
