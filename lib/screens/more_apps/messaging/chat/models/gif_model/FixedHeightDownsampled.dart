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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['size'] = this.size;
    data['url'] = this.url;
    data['webp'] = this.webp;
    data['webp_size'] = this.webpSize;
    data['width'] = this.width;
    return data;
  }
}
