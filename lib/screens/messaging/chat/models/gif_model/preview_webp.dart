class PreviewWebp {
  String? height;
  String? size;
  String? url;
  String? width;

  PreviewWebp({this.height, this.size, this.url, this.width});

  factory PreviewWebp.fromJson(Map<String, dynamic> json) {
    return PreviewWebp(
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
