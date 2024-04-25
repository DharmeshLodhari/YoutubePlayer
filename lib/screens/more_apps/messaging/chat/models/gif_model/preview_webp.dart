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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['height'] = this.height;
    data['size'] = this.size;
    data['url'] = this.url;
    data['width'] = this.width;
    return data;
  }
}
