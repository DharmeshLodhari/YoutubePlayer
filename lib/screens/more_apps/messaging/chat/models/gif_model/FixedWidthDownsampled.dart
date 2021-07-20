class FixedWidthDownsampled {
  String height;
  String size;
  String url;
  String webp;
  String webp_size;
  String width;

  FixedWidthDownsampled(
      {this.height,
      this.size,
      this.url,
      this.webp,
      this.webp_size,
      this.width});

  factory FixedWidthDownsampled.fromJson(Map<String, dynamic> json) {
    return FixedWidthDownsampled(
      height: json['height'],
      size: json['size'],
      url: json['url'],
      webp: json['webp'],
      webp_size: json['webp_size'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['size'] = this.size;
    data['url'] = this.url;
    data['webp'] = this.webp;
    data['webp_size'] = this.webp_size;
    data['width'] = this.width;
    return data;
  }
}
