class FixedHeightSmall {
  String? height;
  String? mp4;
  String? mp4Size;
  String? size;
  String? url;
  String? webp;
  String? webpSize;
  String? width;

  FixedHeightSmall(
      {this.height,
      this.mp4,
      this.mp4Size,
      this.size,
      this.url,
      this.webp,
      this.webpSize,
      this.width});

  factory FixedHeightSmall.fromJson(Map<String, dynamic> json) {
    return FixedHeightSmall(
      height: json['height'],
      mp4: json['mp4'],
      mp4Size: json['mp4_size'],
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
    data['mp4'] = mp4;
    data['mp4_size'] = mp4Size;
    data['size'] = size;
    data['url'] = url;
    data['webp'] = webp;
    data['webp_size'] = webpSize;
    data['width'] = width;
    return data;
  }
}
