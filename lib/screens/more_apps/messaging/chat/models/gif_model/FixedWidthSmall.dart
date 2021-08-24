class FixedWidthSmall {
  String height;
  String mp4;
  String mp4Size;
  String size;
  String url;
  String webp;
  String webpSize;
  String width;

  FixedWidthSmall(
      {this.height,
      this.mp4,
      this.mp4Size,
      this.size,
      this.url,
      this.webp,
      this.webpSize,
      this.width});

  factory FixedWidthSmall.fromJson(Map<String, dynamic> json) {
    return FixedWidthSmall(
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['mp4'] = this.mp4;
    data['mp4_size'] = this.mp4Size;
    data['size'] = this.size;
    data['url'] = this.url;
    data['webp'] = this.webp;
    data['webp_size'] = this.webpSize;
    data['width'] = this.width;
    return data;
  }
}
