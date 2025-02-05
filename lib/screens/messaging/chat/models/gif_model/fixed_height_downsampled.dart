class FixedHeightDownSampled {
  String? height;
  String? size;
  String? url;
  String? webp;
  String? webpSize;
  String? width;

  FixedHeightDownSampled(
      {this.height, this.size, this.url, this.webp, this.webpSize, this.width});

  factory FixedHeightDownSampled.fromJson(Map<String, dynamic> json) {
    return FixedHeightDownSampled(
      height: json['height'],
      size: json['size'],
      url: json['url'],
      webp: json['webp'],
      webpSize: json['webp_size'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['size'] = size;
    data['url'] = url;
    data['webp'] = webp;
    data['webp_size'] = webpSize;
    data['width'] = width;
    return data;
  }
}
