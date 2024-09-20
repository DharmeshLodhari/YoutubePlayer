class FixedWidthSmallStill {
  String? height;
  String? size;
  String? url;
  String? width;

  FixedWidthSmallStill({this.height, this.size, this.url, this.width});

  factory FixedWidthSmallStill.fromJson(Map<String, dynamic> json) {
    return FixedWidthSmallStill(
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
